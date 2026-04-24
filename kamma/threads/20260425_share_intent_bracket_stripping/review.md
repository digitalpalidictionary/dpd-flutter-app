## Thread
- **ID:** 20260425_share_intent_bracket_stripping
- **Objective:** Strip brackets from share/intent text so sutta codes like `(SN12.34)` resolve correctly

## Files Changed
- `lib/services/intent_service.dart` — added `_bracketPattern`, applied in `_clean()`, exposed `clean()` for tests
- `test/services/intent_service_test.dart` — new: 9 unit tests for `IntentService.clean`

## Findings
No findings.

**Residual notes:**
- The pre-existing `_clean(t)!` force-unwrap in `intentStream` is safe: the `where`+`cast` guards guarantee a non-null, non-empty `String` before it reaches `_clean`. Not introduced by this thread.
- `_cleanPali` in `tap_search_wrapper.dart` trims brackets only at word edges (leading/trailing). `IntentService._clean` strips all bracket characters everywhere — the correct behaviour for arbitrary share text.

## Fixes Applied
None — no findings required fixing.

## Test Evidence
- `flutter test test/services/intent_service_test.dart` → 9/9 passed
- `coderabbit review --agent` → 0 findings

## Verdict
PASSED
- Review date: 2026-04-25
- Reviewer: claude-sonnet-4-6
