## Thread
- **ID:** 20260415_search_input_fixes
- **Objective:** Fix search bar auto-space, allow numbers/dots, strip ?! from queries

## Files Changed
- `lib/screens/search_screen.dart` — disable autocorrect/suggestions on TextField; strip ?! from query in _onChanged and _onSearch
- `lib/database/dao.dart` — strip ?! in _normalizeQuery (covers all DB search paths)
- `lib/utils/transliteration.dart` — expand ASCII regex to include digits and dots

## Findings
No findings.

## Fixes Applied
None

## Test Evidence
- User tested manually: sn12.1 (no auto-space), ko? (finds ko), Velthuis still works — PASS

## Verdict
PASSED
- Review date: 2026-04-15
- Reviewer: kamma (inline)
