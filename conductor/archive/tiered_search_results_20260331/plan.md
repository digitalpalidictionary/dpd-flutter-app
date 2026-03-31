# Plan: Tiered Search Results

## Phase 1: External Dictionary Partial Search (DAO)

- [x] Task: Add new `searchDictPartial` method to DAO
  - [x] Add new method `searchDictPartial(String word, {int limit = 50})` to `lib/database/dao.dart`
  - [x] Query `dict_entries.word LIKE '$word%'`
  - [x] Exclude exact matches at DB level with `t.word.equals(word).not()`
  - [x] Keep the query limited to avoid large prefix result sets

- [x] Task: Add DAO tests for dictionary partial tier behavior
  - [x] Modify `test/database/dao_test.dart`
  - [x] Verify partial matches literal headword prefix (case-insensitive via lowercased input)
  - [x] Verify partial excludes exact rows (handled by DAO query, not in-memory)
  - [x] Verify fuzzy remains separate from partial semantics

## Phase 2: Provider Three-Tier Results (DPD + Dictionary)

- [x] Task: Extend dictionary result models with `partial` field
  - [x] Add `partial` field to `DictSearchResults` (`lib/providers/dict_provider.dart`)
  - [x] Add `partial` field to `DictRawSearchResults` (`lib/providers/dict_provider.dart`)
  - [x] Update `DictRawSearchResults.fromRows` to accept `partialRows` parameter
  - [x] In `fromRows`: do NOT re-filter partial against exact IDs in memory — the DAO already excludes exact via `t.word.equals(word).not()`
  - [x] In `fromRows`: filter fuzzy rows against exact + partial row IDs (fuzzy DAO does not exclude at DB level)
  - [x] Update `presentDictSearchResults` to present partial tier using same visibility/ordering logic as exact and fuzzy

- [x] Task: Query dictionary partial results in provider pipeline
  - [x] Update `_dictRawResultsProvider(query)` in `lib/providers/dict_provider.dart`
  - [x] Keep exact query unchanged
  - [x] Add partial query via `dao.searchDictPartial(query.toLowerCase())`
  - [x] Keep fuzzy query via `dao.searchDictFuzzy(stripDiacritics(query.toLowerCase()))`
  - [x] Pass `partialRows` to `DictRawSearchResults.fromRows`

- [x] Task: Ungate DPD fuzzy results and add provider-level deduplication
  - [x] Remove the `dpdEmpty` conditional that suppresses fuzzy when exact/partial exist
  - [x] Always read `fuzzyResultsProvider(query)` for non-empty queries and pass to `_SplitResultsList`
  - [x] Deduplication step inline in search screen build method — filters DPD fuzzy headword IDs against exact + partial IDs before passing to the UI
  - [x] UI receives already-deduplicated lists

- [x] Task: Add logic tests for dictionary and DPD tiering
  - [x] Modify `test/providers/dict_provider_test.dart`
  - [x] Verify exact, partial, and fuzzy buckets populated correctly
  - [x] Verify fuzzy excludes exact and partial duplicates (in-memory dedup)
  - [x] Verify partial does NOT re-filter exact (DAO handles it)
  - [x] Verify dictionary order respected across all three tiers
  - [x] Verify disabled dictionaries hidden across all three tiers

## Phase 3: Aggregate State Update

- [x] Task: Update aggregate search-state computation for three-tier model
  - [x] Modify `lib/providers/search_state_provider.dart`
  - [x] Remove `shouldShowFuzzyFallback` entirely from `SearchAggregateState`
  - [x] Add `hasDictPartial = dictData.partial.isNotEmpty` to `computeSearchState()`
  - [x] Include `hasDictPartial` in the `hasResults` computation
  - [x] Treat DPD fuzzy as a normal third-tier source, not a fallback special case
  - [x] Keep `shouldShowNoResults` tied to all sources being empty after loading

- [x] Task: Add aggregate-state logic tests
  - [x] Modify `test/providers/search_state_provider_test.dart`
  - [x] Verify `hasResults` is true when only dictionary partial exists
  - [x] Verify `hasResults` is true when only DPD fuzzy results exist (no exact/partial)
  - [x] Verify `shouldShowNoResults` is false whenever any tier has content
  - [x] Verify no-results only appears when DPD, dictionary, root, and secondary sources are all empty
  - [x] Verify `shouldShowFuzzyFallback` is gone — no references to it anywhere

## Phase 4: Tier Visibility Settings

- [x] Task: Add tier visibility settings to `Settings` class
  - [x] Add three boolean fields to `Settings` in `lib/providers/settings_provider.dart`:
    - [x] `showExactResults` (default `true`)
    - [x] `showPartialResults` (default `true`)
    - [x] `showFuzzyResults` (default `true`)
  - [x] Update `copyWith`, `==`, `hashCode` to include the new fields
  - [x] Add `_load` entries reading from `SharedPreferences` keys: `show_exact_results`, `show_partial_results`, `show_fuzzy_results`
  - [x] Add setter methods: `setShowExactResults`, `setShowPartialResults`, `setShowFuzzyResults`

- [x] Task: Add tier visibility toggles to settings UI
  - [x] Add three `ListTile` + `CompactSegmented<bool>` rows to `lib/widgets/settings_panel.dart`
  - [x] Labels: "Exact results", "Partial results", "Fuzzy results" — each with Hide/Show segments
  - [x] Place them together as a group, after the "Summary" toggle and before the "Audio gender" toggle
  - [x] Follow the existing `CompactSegmented` pattern used by `showSummary`, `showSandhiApostrophe`, etc.

## Phase 5: Search Screen Three-Tier UI

- [x] Task: Remove `_buildFuzzyFallback` and consolidate into single rendering path
  - [x] Modify `lib/screens/search_screen.dart`
  - [x] Remove `_buildFuzzyFallback()` method entirely
  - [x] Remove the branching that routes to the fallback when all primary results are empty
  - [x] All non-empty queries use the single `_SplitResultsList` rendering path
  - [x] No-results fallback now uses `_NoResults` directly

- [x] Task: Add `dictPartial` to `_SplitResultsList` and refactor to three display buckets
  - [x] Add `final List<DictResult> dictPartial;` to the `_SplitResultsList` constructor
  - [x] Replace the two-bucket model (tier1/tier2) with three buckets:
    - [x] tier 1 (exact): exact DPD headwords, roots, secondary, exact dictionary results
    - [x] tier 2 (partial): partial DPD headwords, partial dictionary results
    - [x] tier 3 (fuzzy): fuzzy DPD headwords, fuzzy dictionary results
  - [x] Route DPD and dictionary results into correct tiers following `DictVisibility.order` within each tier

- [x] Task: Add labeled dividers for partial and fuzzy tiers
  - [x] Replace `_MoreResultsDivider` with `_TierDivider` (takes a `label` parameter)
  - [x] "Partial Results" — between tier 1 and tier 2
  - [x] "Fuzzy Results" — between tier 2 and tier 3
  - [x] Each divider only renders if the respective bucket actually contains items
  - [x] Compact and classic styling consistent with existing design

- [x] Task: Apply tier visibility settings to search results
  - [x] Read `settings.showExactResults`, `settings.showPartialResults`, `settings.showFuzzyResults` in the search screen build method
  - [x] When a tier is disabled, pass empty lists to `_SplitResultsList` for that tier
  - [x] No-results check excludes disabled tiers
  - [x] Roots and secondary results are NOT affected by these toggles

## Phase 6: Final Manual Verification

- [x] Task: Run `dart analyze lib test` — confirmed no warnings

- [x] Task: Manual verification on real search queries (GUI)
  - [x] Search for a query with exact, partial, and fuzzy DPD results — all three tiers visible in order with correct "Partial Results" and "Fuzzy Results" labels
  - [x] Search for a query with exact, partial, and fuzzy dictionary results — all three tiers visible in order
  - [x] Search for a query with no exact or partial but some fuzzy — fuzzy tier shown with label, no empty dividers
  - [x] Search for a query with only partial results — partial tier shown with label, no fuzzy divider
  - [x] Search for a query with no matches at all — "no results found" shown
  - [x] Search for a 1-2 character query — partial results bounded by limit, no performance issues
  - [x] Verify roots and secondary remain in the top-level section
  - [x] Verify dictionary settings (enable/disable, reorder) update all three tiers immediately
  - [x] Verify no headword or dictionary entry appears in more than one tier
  - [x] Toggle each tier visibility setting off/on and verify results update immediately
  - [x] Disable all three tier toggles and verify "no results found" appears (roots/secondary still show if present)
