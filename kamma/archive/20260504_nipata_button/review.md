## Thread
- **ID:** 20260504_nipata_button
- **Objective:** Show "nipāta" button and "SC Nipāta Card" link for AN nipāta entries, mirroring dpd-db commit 10fc6760

## Files Changed
- `lib/database/sutta_info_extensions.dart` — added `isNipata` getter; added AN nipāta branch in `scVaggaLink`
- `lib/widgets/entry_sections_mixin.dart` — added nipāta label between vagga and sutta
- `lib/widgets/sutta_info_section.dart` — added nipāta branch in SC Links row

## Findings
No findings.

## Fixes Applied
None.

## Test Evidence
- `flutter analyze` on all 3 changed files → 0 issues
- User confirmed nipāta button shows correctly on device after mobile db rebuild
- dao.dart reverted cleanly (incidental partial-search change during session was not part of this thread)

## Verdict
PASSED
- Review date: 2026-05-04
- Reviewer: kamma (inline)
