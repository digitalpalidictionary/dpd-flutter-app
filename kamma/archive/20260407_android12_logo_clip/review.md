# Review: Android 12 splash logo clipped

**Date:** 2026-04-07
**Reviewer:** kamma (inline)

## Spec coverage
All requirements met. Logo is fully visible on Android 12+. Dark variant fixed too.

## Plan completion
All tasks marked done and implemented.

## Code correctness
- `dpd-logo-android12.png` and `dpd-logo-dark-android12.png` are 512×512 with logo scaled to 341px (66.7%), centered — correct for Android 12's 2/3 safe zone rule.
- `pubspec.yaml` `android_12` block correctly references new padded images.
- `flutter_native_splash:create` regenerated all platform assets cleanly.

## Regressions
- Non-Android-12 splash unchanged (uses original `dpd-logo-512.png`).
- iOS and web splash updated to dark variant (dark splash images slightly larger — expected, dark logo has less anti-aliasing padding).

## Findings
No findings.

## Verdict: PASSED
