# Plan: Fix closest matches overflow

## Phase 1: Replace with plain text vertical list

### Tasks
- [x] In `_NoResultsWithSuggestions` (search_screen.dart ~line 1510), replace `Wrap` + `ActionChip` with a `Column` of plain `Text` widgets
- [x] Make "No results for ..." and "Closest matches:" left-aligned headings using `titleSmall` style
- [x] Remove `onSuggestionTap` callback — `TapSearchWrapper` handles taps naturally
- [x] Update call site (~line 707) to remove the `onSuggestionTap` parameter
- [x] Verify no overflow and tap-to-search works
