## Thread
- **ID:** 20260415_remove_exact_filter
- **Objective:** Remove the `showExactResults` setting from the app entirely so exact matches are always shown.

## Files Changed
- `lib/providers/settings_provider.dart` — removed `showExactResults` state, persistence, and notifier plumbing.
- `lib/widgets/settings_panel.dart` — removed the "Exact results" settings tile.
- `lib/screens/search_screen.dart` — stopped filtering exact DPD and dict results behind a setting.
- `kamma/threads/20260415_remove_exact_filter/plan.md` — marked implementation and verification tasks complete.

## Findings
No findings.

## Fixes Applied
- None

## Test Evidence
- `rg -n "showExactResults" lib` → pass
- `rg -n "Exact results" lib/widgets/settings_panel.dart` → pass
- `rg -n "visibleExact|visibleDictExact|showExactResults" lib/screens/search_screen.dart` → pass
- `flutter analyze` → pass for this thread's requirement: no new analyzer errors; only pre-existing warnings/infos outside the changed scope

## Verdict
PASSED
- Review date: 2026-04-15
- Reviewer: Codex (same session as implementation; reduced independence)
