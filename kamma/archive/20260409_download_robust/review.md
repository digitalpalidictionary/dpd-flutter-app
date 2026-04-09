# Review: Robust Download Experience

**Date:** 2026-04-09
**Reviewer:** kamma (inline) + coderabbit review --agent

## Findings

- **nit** (spec.md) — ForegroundDownloadController interface not fully documented in spec. Code is correct; spec is a documentation artifact only.
- **nit** (spec.md) — onStatusLabel callback signature not fully documented in spec. Code is correct; spec is a documentation artifact only.
- **minor** (database_update_service.dart:148) — `_foregroundController.updateProgress(progress)` Future not awaited in progress callback. **Fixed:** wrapped with `unawaited()`.
- **major** (download_screen.dart) — `DatabaseUpdateService()` instantiated directly for `formatBytes`, creating a redundant Dio client on every build. **Fixed:** `formatBytes` made static.
- **major** (database_update_provider_test.dart) — background-cancel test claimed to test `_backgroundDownload()` but never triggered it (kDebugMode=true in tests). **Fixed:** removed misleading test, added explanatory comment.

## Verdict: PASSED
