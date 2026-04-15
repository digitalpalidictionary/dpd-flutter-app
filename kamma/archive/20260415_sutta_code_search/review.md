## Thread
- **ID:** 20260415_sutta_code_search
- **Objective:** Sutta code searches (mn12, SN3.12, etc.) return direct results instead of fuzzy-only

## Files Changed
- `lib/database/dao.dart` — all lookup_key queries now also check uppercase variant when query contains a digit

## Findings
No findings. All changes are correct and minimal.

## Fixes Applied
- First attempt used `COLLATE NOCASE` — killed the SQLite index, caused 6s search times. Reverted.
- Final approach: digit-in-query = sutta code; add `OR lookup_key = normalized.toUpperCase()` as second indexed lookup. Zero cost for Pali-only queries.

## Test Evidence
- `flutter analyze lib/database/dao.dart` → no issues
- `flutter test` → all tests passed
- Manual: "mn12", "MN12", "sn3.12", "SN3.12" → direct results ✓
- Manual: "dhamma" → instant, unchanged ✓

## Verdict
PASSED
- Review date: 2026-04-15
- Reviewer: kamma (inline)
