# Spec: Share Intent Bracket Stripping

## Problem
When a user highlights a sutta code like `(SN12.34)` in another app and shares it to DPD, the brackets are included in the search query and nothing is found.

## Root Cause
`IntentService._clean()` only stripped URLs and quote characters. The bracket-stripping fix in commit 596957c only patched the tap-to-search path (`_cleanPali` in `tap_search_wrapper.dart`), leaving the share/intent path unguarded.

## Fix
- Add `_bracketPattern = RegExp(r'[\[\](){}]')` to `IntentService`
- Apply it in `_clean()` after the quote-stripping step
- Expose `IntentService.clean()` via `@visibleForTesting` for unit tests

## Test Coverage
Add `test/services/intent_service_test.dart` covering:
- `(SN12.34)` → `SN12.34`
- `[SN12.34]` → `SN12.34`
- `{kamma}` → `kamma`
- Mixed quotes + brackets
- Brackets mid-text
- Existing URL and quote stripping

## Files Changed
- `lib/services/intent_service.dart`
- `test/services/intent_service_test.dart` (new)
