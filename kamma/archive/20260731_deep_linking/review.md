## Thread
- **ID:** 20260731_deep_linking
- **Objective:** Register a custom `dpd://word/<word>` Android scheme so external sites (e.g. dhamma.gift) can deep-link straight to a word lookup, riding the existing intent funnel with zero new Dart code.

## Files Changed
- `android/app/src/main/AndroidManifest.xml` — adds a `VIEW`+`BROWSABLE` intent-filter (`scheme="dpd" host="word"`) to `MainActivity`, matching plan 1.1 verbatim.
- `android/app/src/main/kotlin/net/dpdict/dpd_flutter_app/MainActivity.kt` — adds an `Intent.ACTION_VIEW` arm to `extractText()` that reads `intent.data?.lastPathSegment`, matching plan 1.2 verbatim.
- `README.md` — new "Deep Links" section documenting the format.
- `kamma/tech.md` — dated entry recording the scheme and that it rides the existing funnel.
- `AGENTS.md` — "External Entry Points" list extended to name deep links as a fourth entry point.

Unrelated, out-of-scope changes present in the working tree (`lib/database/sutta_info_extensions.dart`, `test/database/sutta_info_extensions_test.dart`, `assets/help/changelog.json`) belong to a separate parallel session and were excluded from this review, per instruction.

## Findings
No findings.

## Fixes Applied
None — no findings required a fix.

## Test Evidence
- `git diff` review of all 5 changed files (scope: 100% of thread's changed files) → matches spec.md and plan.md exactly; no drift, no scope creep.
- `adb shell cmd package resolve-activity --brief -a android.intent.action.VIEW -d 'dpd://word/test'` (scope: intent-filter resolution on the installed debug build) → resolves to `net.dpdict.dpd_flutter_app.debug/net.dpdict.dpd_flutter_app.MainActivity`, confirming the manifest change is live in the installed APK.
- Independent re-run of all 4 device-testable cases from the plan's verification matrix, on a connected physical device (scope: cold ASCII, warm ASCII, cold multi-byte, malformed/empty — the 5th case, browser `BROWSABLE` tap, was not re-run since no browser/hosted-page harness was set up for this review, but was already verified per plan 1.4 note):
  - Cold `dpd://word/bhavana` (app force-stopped first) → logcat shows `[DPD] Final intent text: "bhavana"` — pass.
  - Warm `dpd://word/dhamma` (app left running) → `am start` returned "intent has been delivered to currently running top-most instance" (no new task in recents) — pass, matches `singleTask` contract.
  - Cold `dpd://word/sa%E1%B9%85kh%C4%81ra` → logcat shows `[DPD] Final intent text: "saṅkhāra"` — correct percent-decoding, no mojibake — pass.
  - Cold `dpd://word/` (empty path) → logcat shows `[DPD] Final intent text: "null"`, no crash, no `FATAL`/`AndroidRuntime` exceptions in logcat — pass.
- `coderabbit review --agent --base main --type uncommitted --dir android` (scope: the two Android source files — the actual code change; docs files were not sent to CodeRabbit since they're prose, not logic) → completed successfully, 0 findings.

## Not Verified
- Case 5 of the plan's matrix (a real `<a href>` tap from a mobile Chrome browser exercising the `BROWSABLE` category end-to-end) was not independently re-run in this review — only re-verified via direct `adb am start`, which does not exercise the `BROWSABLE` resolution path a real browser tap does. The plan's own record for this case (a local HTTP server + `adb reverse` + real Chrome tap) is a legitimate, non-trivial verification method and is taken on trust rather than re-run.
- iOS, desktop, and query-param forms are explicitly out of scope per spec.md and were not expected to be implemented — confirmed absent, as intended.
- No new automated (unit/Kotlin) test was added; this matches the plan's explicit "no test infra" rationale and is not treated as a gap.

## Verdict
PASSED
- Review date: 2026-07-31
- Reviewer: Claude (independent review agent, fresh session)
