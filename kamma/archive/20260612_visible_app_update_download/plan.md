# Plan: Visible App Update Download

## Architecture Decisions
1. **Extend `DownloadFooter`** rather than adding a sibling widget — both downloads share one footer slot; DB takes precedence (they cannot run concurrently anyway).
2. **State carries what the UI needs**: add `sizeBytes` and `errorMessage` to `AppUpdateState`; the footer and snackbar read state, no new plumbing.
3. **Error surfacing only for the download**, not the check — parity with the DB background check, avoids snackbars on every offline launch.
4. **Throttle at the single choke point** — `ForegroundDownloadService.updateProgress()` keeps a static last-percent and skips platform calls until the integer percent changes. Both DB and app downloads benefit with one change.
5. **One formatBytes** — delete the unused instance copy on `AppUpdateService`; UI uses the existing `DatabaseUpdateService.formatBytes` static.

## Phases

### Phase 1 — State & error surfacing
- [x] Add `sizeBytes` and `errorMessage` to `AppUpdateState` (+ `copyWith`); set `sizeBytes` when the download starts; on download failure set `AppUpdateStatus.error` + message instead of `idle`.
  → verify: `flutter analyze` clean.
- [x] Show `App update download failed` snackbar from the existing `appUpdateProvider` listener in `_DbGate.build` on transition into `error`.
  → verify: `flutter analyze` clean.
- [x] Data-logic test: `AppUpdateState.copyWith` round-trips the new fields.
  → verify: `flutter test test/providers/` passes.

### Phase 2 — Visible download footer
- [x] Extend `DownloadFooter` to watch `appUpdateProvider`: when DB is idle and app update is `downloading`, render the same bar with `Downloading app update… X% (Y MB)`.
  → verify: `flutter analyze` clean.
- [x] Remove unused `AppUpdateService.formatBytes`.
  → verify: `flutter analyze` clean; `rg formatBytes lib/` shows only the DB static.

### Phase 3 — Notification throttle
- [x] Skip `FlutterForegroundTask.updateService` unless the integer percent changed; reset the tracker in `startDbDownload`/`startAppDownload`.
  → verify: `flutter analyze` clean.

### Phase 4 — Verification
- [x] `flutter analyze` + full `flutter test`. (297 passed; no analyze findings in changed files, 2026-06-12)
- [ ] Manual on Android (user): trigger an update, watch footer progress + no `Shedding notify` in logcat; kill connectivity mid-download → failure snackbar.
  → verify: DEFERRED (user, 2026-06-12) — will be verified live when the next release (~2026-06-26) downloads through this code; thread finishes without blocking on it.
