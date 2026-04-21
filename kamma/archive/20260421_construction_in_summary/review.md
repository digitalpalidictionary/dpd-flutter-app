## Thread
- **ID:** 20260421_construction_in_summary
- **Objective:** Add a setting to show or hide construction text in summary rows.

## Files Changed
- `lib/providers/settings_provider.dart` — added `showConstructionInSummary` to the settings model, persistence load, and setter.
- `lib/providers/summary_provider.dart` — watched the setting and skipped the summary construction suffix when disabled.
- `lib/widgets/settings_panel.dart` — added the new segmented toggle above the Grammar button row.

## Findings
No findings.

## Fixes Applied
- None.

## Test Evidence
- `dart analyze lib/providers/settings_provider.dart` → No issues found.
- `dart analyze lib/providers/summary_provider.dart` → No issues found.
- `dart analyze lib/widgets/settings_panel.dart` → No issues found.
- `dart analyze lib/` → existing unrelated warnings/info remain in benchmark/transliterator files; no new issues in touched files.

## Verdict
PASSED
- Review date: 2026-04-21
- Reviewer: kamma (inline)
