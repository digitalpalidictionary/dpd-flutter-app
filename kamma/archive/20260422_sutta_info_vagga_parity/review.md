## Thread
- **ID:** 20260422_sutta_info_vagga_parity
- **Objective:** Bring sutta info tab behaviour to parity with the webapp for vagga, saṃyutta, and paṇṇāsaka subdivision entries (`dpd-db` #192)

## Files Changed
- `lib/database/sutta_info_extensions.dart` — added entry-type getters and SC subdivision link builder; fixed uppercase-diacritic slug handling during review
- `lib/database/dao.dart` — expanded `getSuttaInfo()` to match `dpd_sutta_var` aliases
- `lib/widgets/entry_sections_mixin.dart` — derives the section button label from the selected sutta info row
- `lib/widgets/sutta_info_section.dart` — hides row groups by entry type and branches the SC links row for vagga/saṃyutta entries
- `test/database/dao_test.dart` — covers alias lookup through `dpdSuttaVar`
- `test/database/sutta_info_extensions_test.dart` — covers generic SC vagga slug generation with uppercase diacritics

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | major | `lib/database/sutta_info_extensions.dart:6` | `_paliSlug()` only handled lowercase diacritic code points, so rows like `Ādittavagga` produced accented SC slugs instead of webapp-style ASCII slugs. | Generic vagga links could open the wrong SuttaCentral URL even though targeted DN/MN/SN cases looked correct. | Added uppercase rune mappings and a regression test for `scVaggaLink`. |

## Fixes Applied
- Extended `_paliSlug()` to strip uppercase Pāḷi diacritics as well as lowercase ones.
- Added a focused `SuttaInfoExtensions` test for `3. Ādittavagga` → `https://suttacentral.net/sn35-adittavagga`.
- Added a DAO regression test proving `getSuttaInfo()` resolves aliases from `dpdSuttaVar`.

## Test Evidence
- `flutter analyze lib/database/sutta_info_extensions.dart lib/widgets/entry_sections_mixin.dart lib/widgets/sutta_info_section.dart lib/database/dao.dart test/database/sutta_info_extensions_test.dart test/database/dao_test.dart` → pass
- `flutter test test/database/sutta_info_extensions_test.dart test/database/dao_test.dart` → pass
- `coderabbit review --agent` → reported the slug bug above; fixed during review
- GitHub issue check: `digitalpalidictionary/dpd-db#192` matches the thread scope ("DN, MN, SN subsections, saṃyuttas, vaggas, etc.")

## Verdict
PASSED
- Review date: 2026-04-22
- Reviewer: Codex (`kamma-3-review`)
