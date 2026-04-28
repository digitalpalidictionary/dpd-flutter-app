## Thread
- **ID:** 20260428_variant_rows
- **Objective:** Sync grammar table variant display with GoldenDict Jinja template (var_phonetic, var_text)

## Files Changed
- `lib/widgets/grammar_table.dart` — replaced `_buildVariantRow` with `_buildVariantRows` returning a list of up to 3 rows

## Findings
No findings.

## Fixes Applied
None

## Test Evidence
- `flutter analyze lib/widgets/grammar_table.dart` → no issues

## Verdict
PASSED
- Review date: 2026-04-28
- Reviewer: kamma (inline)
