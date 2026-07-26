# Plan: Share Intent Bracket Stripping

## Status: COMPLETE

## Task 1: Fix IntentService._clean — DONE
- Added `_bracketPattern = RegExp(r'[\[\](){}]')`
- Applied in `_clean()` after quote stripping
- Exposed `IntentService.clean()` with `@visibleForTesting`
- File: `lib/services/intent_service.dart`

## Task 2: Add regression test — DONE
- Created `test/services/intent_service_test.dart`
- 9 tests, all passing
- Covers `(SN12.34)`, `[SN12.34]`, `{kamma}`, mixed, mid-text, URLs, quotes

## Commit Message
```
fix: share intent now strips brackets from sutta codes like (SN12.34)

Added bracket stripping ([](){}) to IntentService._clean so shared text
like "(SN12.34)" resolves to "SN12.34". Added test coverage to prevent
regression.
```
