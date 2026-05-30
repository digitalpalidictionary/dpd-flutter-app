## Thread
- **ID:** 20260530_suriya_warmth
- **Objective:** Adjust sūriya dark palette to match the warmth and saturation of the Anki DPD card theme

## Files Changed
- `lib/theme/schemes/suriya.dart` — updated 8 HSL values in `suriyaDark` only
- `lib/screens/search_screen.dart` — `_BarIconButton` icon colour changed from `palette.light` to `palette.dark`

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | minor | `search_screen.dart:922` | Icon colour was `light` (cream) on `primary` (amber) button bg — low contrast | `primary` sat/lightness change made the contrast worse | Changed to `palette.dark` — dark icon on amber; verified contrast holds across all themes |

## Fixes Applied
- `_BarIconButton` icon colour switched from `palette.light` to `palette.dark` after user reported unreadable X/←/→ buttons

## Test Evidence
- `flutter analyze lib/theme/schemes/suriya.dart` → No issues found
- `flutter analyze lib/screens/search_screen.dart` → No issues found
- Visual confirmation by user: warmth improved, button icons readable

## Verdict
PASSED
- Review date: 2026-05-30
- Reviewer: kamma (inline)
