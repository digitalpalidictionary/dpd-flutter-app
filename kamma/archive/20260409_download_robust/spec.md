# Robust Download Experience

## Overview
A user reports the initial database download stuck at 0% indefinitely on a tablet with
a wired connection. The download screen offers no cancel button, no stall detection, and
no useful feedback. The underlying download code has additional issues: zip extraction
loads ~195 MB into RAM, resume fallbacks are silent, corrupt-zip recovery downloads the
file twice without telling the user, and foreground notification management is duplicated
across two provider methods.

This thread consolidates and hardens the entire download pipeline.

## What it should do

### 1. Stall detection
- Track the timestamp of the last received bytes during download.
- A periodic timer (every 5s) checks whether progress has stalled for 60 seconds.
- If stalled, cancel the in-flight Dio request and surface an error:
  "Download stalled — no data received for 60 seconds. Check your connection and
  try again."
- Applies to both `_freshDownload` and `_downloadRange` paths.

### 2. Cancel button
- Show a "Cancel" text button below the progress bar during the initial (blocking)
  download only (not during background updates).
- Cancelling aborts the Dio request via `CancelToken`, stops the foreground service,
  and returns the user to the "Download now" prompt.
- The partial .zip file is preserved so the next attempt can resume.

### 3. Reduce receiveTimeout
- Change the 30-minute `receiveTimeout` in `_freshDownload` to 5 minutes.
- Set the same 5-minute `receiveTimeout` in `_downloadRange` (currently inherits
  the 30s default, which is too short for range downloads and inconsistent).

### 4. Stream zip extraction
- Replace `tempZip.readAsBytes()` + `ZipDecoder().decodeBytes()` with disk-streaming
  extraction using the `archive` package's `InputFileStream` / `ZipDecoder().decodeStream`.
- This avoids loading ~195 MB into RAM, preventing OOM on low-memory devices.

### 5. Remove silent double-download on corrupt zip
- Currently `_extractAndInstall` catches extraction failure, deletes the zip, re-downloads,
  and tries again — all silently. The user unknowingly waits for two full downloads.
- Change: on extraction failure, delete the corrupt zip and throw immediately with a clear
  error message: "Downloaded file was corrupt. Please try again."
- The user presses Retry, and resume logic handles it cleanly from scratch.

### 6. Notify user on resume fallback
- When a range-resume fails and falls back to a fresh download, update the status label
  to "Restarting download…" so the user knows what happened.
- Add an `onStatusLabel` callback so the service can communicate status labels back to the UI.

### 7. Consolidate foreground notification management
- Move foreground service start/updateProgress/stop calls into `DatabaseUpdateService`
  itself, so the provider doesn't manually orchestrate two services.
- `_initialDownload` and `_backgroundDownload` in the provider both contain identical
  foreground service boilerplate (start before download, update in onProgress, stop in
  finally). This moves into the service.
- The provider passes a `ForegroundDownloadController` at construction, and the service
  manages its lifecycle internally alongside the download.

## Constraints
- Do not change background update behavior beyond the consolidation.
- Resume support must still work — partial .zip files are preserved on cancel/stall.
- `ForegroundDownloadService` remains a separate class (it's Android-specific glue),
  but its lifecycle is driven by `DatabaseUpdateService` internally.
- The `archive` package (v4.0.4) already supports `InputFileStream` — no new dependency.
- All error messages must be user-friendly (no stack traces, no technical jargon).

## How we'll know it's done
- Download stuck at 0% for >60s → error screen with retry.
- Download progressing then stalling mid-way for >60s → same.
- Cancel button visible during initial download → tapping it returns to "Download now".
- Corrupt zip → single error, not silent double-download.
- Zip extraction does not spike RAM to 195 MB (stream from disk).
- Provider methods no longer contain duplicated foreground service boilerplate.
- Existing tests still pass.

## What's not included
- Download speed / ETA indicator (nice-to-have, separate thread).
- Automatic retry (user must press retry).
- Changes to the GitHub release-check logic.
