# Review: Fix app update race condition

**Date:** 2026-04-08
**Reviewer:** kamma (inline)

## Findings

No findings.

## Verdict: PASSED

All spec requirements implemented. Both race condition points addressed: app update check gated behind `DbStatus.ready` via `_appUpdateGateSub` with `fireImmediately: true`; APK install gated via `_maybeInstallAppUpdate()` with `_appInstallPending` deferred flag. Listener cleaned up in `dispose()`. No regressions. 4 new tests pass.
