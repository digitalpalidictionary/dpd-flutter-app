# Plan: Closest Matches on No Results

## Phase 1: DAO + Provider
- [x] Add `searchClosestMatches(String query)` method to `DpdDao`
  - [x] Try prefix trimming: query lookup table for keys starting with progressively shorter prefixes (min 2 chars), collect candidate keys
  - [x] Also try fuzzy_key prefix trimming for diacritics-insensitive matching
  - [x] Deduplicate and sort by `paliSortKey`
  - [x] Return top 10 as `List<String>`
- [x] Add `closestMatchesProvider` in search_provider.dart
  - [x] FutureProvider keyed by query string; only called from UI when status == noResults
- [x] Verify: flutter analyze — no issues

## Phase 2: UI
- [x] Replace `_NoResults` widget with `_NoResultsWithSuggestions`
  - [x] Shows "No results for X" header
  - [x] Shows "Closest matches:" label + Wrap of ActionChip widgets
  - [x] Each chip taps → calls `_onSuggestionSelected` (sets provider, controller, history)
- [x] Wire the new widget into the no-results check in `_SearchResults.build`
- [x] Verify: flutter analyze — no issues; all existing tests pass
- [ ] Verify: manual test on device
