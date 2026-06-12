# Spec: Visible App Update Download

## Overview
The app-update APK download is currently invisible inside the app: the only signal is a LOW-importance Android notification tucked into the Silent section of the shade, and every failure path is swallowed by `catch (_)`. Live diagnosis on a real device (v0.1.8, 2026-06-12) confirmed users have no idea an update is downloading, and when it fails (e.g. the pre-`ca8220f` concurrent-download race) it fails with zero trace.

Make the app update download visible in-app exactly like the database download, surface download failures, and stop flooding the Android notification with progress updates.

## Repo context
- DB download progress shows in-app via `DownloadFooter` (`lib/widgets/download_footer.dart`), mounted at `lib/screens/search_screen.dart:432`: thin `LinearProgressIndicator` + label `Downloading database… 43% (45 MB)`.
- App update state lives in `lib/providers/app_update_provider.dart` (`AppUpdateState`: status/progress/apkPath/latestTag). `progress` is already tracked — nothing renders it.
- `AppUpdateStatus.error` is declared but **never set** — both `catch` blocks collapse to `idle`.
- `AppUpdateState` does not carry the APK size; `AppReleaseInfo.size` is available at download start.
- Snackbar pattern: `_showUpdateSnackBar()` in `lib/app.dart` (used for "Database updated…" and "Installing app update…").
- `ForegroundDownloadService.updateProgress()` (`lib/services/foreground_download_service.dart:55`) is called on every Dio chunk (25–95×/sec observed); Android rate-limits at 5/sec and logs `Shedding notify` warnings.
- DB and app downloads never run concurrently (gated by `updateCycleComplete` since `ca8220f`).
- `AppUpdateService.formatBytes` is an unused instance method; `DatabaseUpdateService.formatBytes` is the static one used by all existing UI.

## What it should do
1. **Visible download**: while the app update is downloading, the same footer slot above `FeedbackFooter` shows a progress bar + `Downloading app update… 43% (69 MB)` — identical styling to the DB variant. DB download takes precedence if ever both were active.
2. **Visible failure**: a failed APK download sets `AppUpdateStatus.error` (with the error message in state) and shows a snackbar `App update download failed`. The progress bar disappears; the app stays fully usable.
3. **Silent check stays silent**: a failed *update check* (offline launch, GitHub rate limit) still resolves quietly to `idle` — parity with the DB background check, no offline nagging.
4. **Throttled notification**: `ForegroundDownloadService.updateProgress()` only calls the platform when the integer percent changes (max ~100 updates per download instead of thousands). Throttle state resets when a service starts.
5. **Dead code**: remove the unused `AppUpdateService.formatBytes`; the footer reuses `DatabaseUpdateService.formatBytes` for both labels.

## Assumptions & uncertainties
- Label text `Downloading app update… X% (Y MB)` — "app update" rather than just "app", to distinguish from the DB while staying parallel to `Downloading database…`. (User asked for "named app download"; this satisfies the intent — flag at review if the shorter wording is preferred.)
- The Android notification stays at LOW importance — its only job is keeping the foreground service alive once in-app progress exists.
- No state is shown for `checking` or `readyToInstall` in the footer; the existing "Installing app update…" snackbar covers handoff to the installer.
- `AppUpdateNotifier` constructs its service internally and `checkForUpdates` is a no-op in debug (`kDebugMode`), so the download/error path is not drivable from widget-free tests without DI changes — out of scope; state-shape changes are covered by a data-logic test instead (per project policy: no UI tests).

## Constraints
- Reuse the `DownloadFooter` pattern and styling exactly; no new visual language.
- Theme colors only (`colorScheme` / `context.palette`).
- No behavior change to update sequencing, gating, or install flow.

## How we'll know it's done
- Triggering an app update on Android shows the footer progress bar climbing, named for the app update, with the APK size.
- Killing connectivity mid-download produces the failure snackbar instead of silent disappearance.
- `adb logcat` during a download shows no `Shedding notify` warnings.
- `flutter analyze` clean; `flutter test` passes.
