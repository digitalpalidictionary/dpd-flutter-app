# Review: Closest Matches on No Results

- **Date:** 2026-04-07
- **Reviewer:** kamma (inline)

## Spec coverage
- No-results state shows closest matches: ✓
- Matches are clickable and trigger a new search: ✓
- Results sorted in Pāḷi alphabetical order via `paliSortKey`: ✓
- No-result searches added to history (bonus scope addition, user-confirmed): ✓
- Normal search performance unaffected: ✓ (provider only called from no-results widget)

## Plan completion
All tasks marked done. One in-scope addition (history for no-result searches) added and confirmed by user.

## Code correctness
- `searchClosestMatches` correctly deduplicates candidates via a `Set<String>` before sorting
- Candidate cap of 50 prevents runaway DB reads on short queries
- `fuzzyKey` strategy handles diacritics-insensitive input (Velthuis/ASCII)
- `_NoResultsWithSuggestions` is a `ConsumerWidget` — correct for watching a provider
- `historyProvider.notifier.add()` deduplicates, so double-add from debounce + Enter is harmless

## Findings
No findings.

## Verdict: PASSED
