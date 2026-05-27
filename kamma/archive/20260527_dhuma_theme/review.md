## Thread
- **ID:** 20260527_dhuma_theme
- **Objective:** Add dhūma, tiṇa, and sūriya colour schemes; retire kapila

## Files Changed
- `lib/theme/schemes/dhuma.dart` — new smoke/monochrome palette (light + dark)
- `lib/theme/schemes/tina.dart` — new fresh grass-green palette (light + dark)
- `lib/theme/schemes/suriya.dart` — new sunshine-gold palette (light + dark), absorbs kapila
- `lib/theme/dpd_scheme.dart` — enum updated to `{nila, suriya, tina, dhuma}`, kapila removed
- `lib/widgets/settings_panel.dart` — row label "Colour scheme" → "Colour"; help text updated

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | nit | `lib/theme/schemes/kapila.dart` | File modified but no longer imported | kapila was merged into suriya; file is dead code | Delete or leave; no runtime impact |

## Fixes Applied
- dhūma light primary lightened 0.42 → 0.56 (dark text contrast on button)
- tiṇa dark primary darkened 0.62 → 0.40 (light text contrast on button)
- dhūma light gray lightened 0.55 → 0.70 (off-button border too heavy)
- suriya merged from kapila+suriya; hue shifted H=34→45 for genuine sunshine gold
- kapila retired; sūriya replaces it with label correction (long ū)

## Test Evidence
- `flutter analyze lib/theme/schemes/dhuma.dart lib/theme/schemes/tina.dart lib/theme/schemes/suriya.dart lib/theme/dpd_scheme.dart lib/widgets/settings_panel.dart` → no issues
- WCAG contrast ratios verified for all button primary/dark pairs: all ≥ 4.5:1
- User confirmed each scheme visually: dhūma ✓, tiṇa ✓, sūriya ✓

## Verdict
PASSED
- Review date: 2026-05-27
- Reviewer: kamma (inline)
