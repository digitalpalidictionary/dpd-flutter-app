# Plan: App update must wait for database download to complete

## Phase 1: Gate app update check and install behind DB readiness

### [x] Task 1.1: Defer app update check until DB is stable
In `lib/app.dart` (`_DpdAppState`):
- Add `bool _appUpdateChecked = false` field.
- Add `ProviderSubscription<DbUpdateState>? _appUpdateGateSub` field.
- In `_releaseFirstFrame()`, remove the `addPostFrameCallback` that unconditionally fires `appUpdateProvider.checkForUpdates()`.
- Instead, set up `_appUpdateGateSub` via `ref.listenManual` with `fireImmediately: true` so it fires immediately if DB is already ready, or waits for the next `ready` transition.
- When fired with `status == DbStatus.ready` and `_appUpdateChecked == false`: set `_appUpdateChecked = true`, close and null `_appUpdateGateSub`, call `checkForUpdates()`.
- Close `_appUpdateGateSub` in `dispose()`.

### [x] Task 1.2: Gate APK install behind DB readiness
In `lib/app.dart` (`_DbGateState`):
- Add `bool _appInstallPending = false` field.
- Add `_maybeInstallAppUpdate()` helper: re-reads `dbUpdateProvider.status`; if busy sets `_appInstallPending = true` and returns; otherwise clears flag and calls `installUpdate()`.
- Change the `ref.listen<AppUpdateState>` install listener to call `_maybeInstallAppUpdate()` instead of `installUpdate()` directly.
- In the existing `ref.listen<DbUpdateState>` listener, when `next.status == DbStatus.ready` and `_appInstallPending`, call `_maybeInstallAppUpdate()`.

### [x] Task 1.3: Add tests for sequencing logic
In `test/app_update_sequencing_test.dart`:
- DB already ready → app update check fires immediately.
- DB downloading on startup → app update check does not fire until DB becomes ready.
- APK reaches `readyToInstall` while DB busy → install deferred (`_appInstallPending` set).
- DB returns to `ready` with pending install → install fires exactly once.

### [x] Task 1.4: Verify phase 1
- Read all changed code and confirm no regressions.
- Confirm manual listeners are cleaned up in dispose().
- Confirm the two invariants hold: no check while DB busy, no install while DB busy.
