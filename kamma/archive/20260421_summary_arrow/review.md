## Thread
- **ID:** 20260421_summary_arrow
- **Objective:** Arrow in summary list aligns with item line, not headword heading.

## Files Changed
- `lib/widgets/summary_section.dart` — restructured `_SummaryRow` headword branch to Column[heading, Row[itemLine, ►]].

## Findings
No findings.

## Fixes Applied
- None.

## Test Evidence
- `flutter analyze lib/widgets/summary_section.dart` → No issues found.
- Manual test (user confirmed): arrow now aligns with item lines.

## Verdict
PASSED
- Review date: 2026-04-21
- Reviewer: kamma (inline)
