## Thread
- **ID:** 20260612_visible_app_update_download
- **Objective:** Make the app-update APK download visible in-app (same footer as the DB download), surface download failures, and throttle the foreground notification spam

## Files Changed
- `lib/providers/app_update_provider.dart` — `AppUpdateState` gains `sizeBytes` + `errorMessage`; download failure now sets `AppUpdateStatus.error` (previously collapsed silently to `idle`)
- `lib/widgets/download_footer.dart` — also watches `appUpdateProvider`; renders `Downloading app update… X% (Y MB)` when the APK is downloading; DB download takes precedence; DB branch output unchanged
- `lib/app.dart` — existing `appUpdateProvider` listener also shows an `App update download failed` snackbar on transition into `error`
- `lib/services/foreground_download_service.dart` — notification updates skipped unless the integer percent changed (Android sheds >5/sec); tracker reset on each service start
- `lib/services/app_update_service.dart` — removed unused instance `formatBytes`; UI reuses `DatabaseUpdateService.formatBytes`
- `test/providers/app_update_state_test.dart` — new: 3 data-logic tests for `AppUpdateState` defaults and `copyWith` round-trips

## Findings
No findings from self-review.

**Residual notes:**
- `dismiss()` resets only `status`, leaving a stale `errorMessage` in state. Harmless: nothing reads it after the one-shot snackbar, and `manualCheck()` performs a full reset.
- Update-*check* failures (offline launch, GitHub rate limit) still resolve quietly to `idle` — deliberate parity with the DB background check; only *download* failures surface.
- `_lastPercent` is a single static shared by DB and app downloads — safe because the `updateCycleComplete` gate (ca8220f) guarantees they never run concurrently, and it resets in both `start*Download` methods.

## Fixes Applied
None — no findings required fixing.

## Test Evidence
- `flutter analyze` → no findings in changed files (94 pre-existing infos elsewhere in the tree)
- `flutter test` → 297/297 passed, including the new `app_update_state_test.dart`
- `coderabbit review --agent` → 0 findings
- Manual on-device verification deferred to the next release (~2026-06-26) per user.

## Verdict
PASSED
- Review date: 2026-06-12
- Reviewer: claude-opus-4-8
