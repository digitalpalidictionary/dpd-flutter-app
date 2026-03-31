# Specification: Tiered Search Results

## Overview

Unify DPD headword results and external dictionary results under the same three-tier search model in the main search screen:

1. exact results
2. partial results (`starts with`)
3. fuzzy results

With a no-results fallback when all tiers and sources are empty.

Today, the app uses an uneven search presentation model. DPD headwords already have exact, partial, and fuzzy query paths, but DPD fuzzy is only shown in a fallback flow when primary DPD results are empty. External dictionaries expose exact and fuzzy matching only, with no dedicated partial tier. This track makes the search behavior consistent and legible: both DPD headwords and external dictionaries should present exact, partial, and fuzzy matches in a predictable order, while roots and secondary results remain top-level result types outside this tiering model.

## Background

- DPD exact results are sourced from `lookup.lookup_key == normalized query`
- DPD partial results are sourced from `lookup.lookup_key LIKE '$normalized%'` excluding exact
- DPD fuzzy results are sourced from `lookup.fuzzy_key LIKE '$normalizedFuzzy%'`
- External dictionary exact results are sourced from `dict_entries.word == query`
- External dictionary partial results are sourced from `dict_entries.word LIKE '$queryLower%'` excluding exact (normalization: lowercase only)
- External dictionary fuzzy results are sourced from `dict_entries.word_fuzzy LIKE '$fuzzyKey%'`
- The main search screen currently mixes:
  - top-level DPD exact results
  - top-level dictionary exact results
  - a generic `more results` tier
  - a separate fuzzy fallback screen for DPD when primary results are empty
- Dictionary order and visibility are already controlled through `DictVisibility`
- Roots and secondary result types are already integrated and should not be redefined by this track

## Functional Requirements

### FR1: Explicit Three-Tier Search For DPD Headwords

- DPD headword search must expose exact, partial, and fuzzy tiers as first-class result buckets
- DPD exact matching behavior must remain unchanged
- DPD partial matching behavior must remain unchanged
- DPD fuzzy matching behavior must remain unchanged
- DPD fuzzy results must no longer be hidden simply because exact or partial DPD results exist
- DPD fuzzy results must be rendered as a third tier below partial results when present
- DPD fuzzy deduplication must happen in the provider layer, not in the UI — the UI receives already-deduplicated lists

### FR2: Explicit Three-Tier Search For External Dictionaries

- External dictionary search must expose exact, partial, and fuzzy tiers as first-class result buckets
- External dictionary exact matching behavior must remain unchanged
- External dictionary partial results must be added using literal headword prefix matching on `dict_entries.word`
- External dictionary partial normalization: lowercase the query only (no diacritic stripping)
- External dictionary partial results must be limited (default 50) to avoid large prefix result sets
- External dictionary partial exclusion of exact matches must happen at the DAO/SQL level, not in-memory
- External dictionary fuzzy matching must remain the current normalized-prefix behavior on `dict_entries.word_fuzzy`
- External dictionary fuzzy deduplication against exact + partial must happen in-memory in the provider (since the fuzzy DAO does not exclude at DB level)
- External dictionary exact, partial, and fuzzy results must all respect dictionary order and visibility settings

### FR3: Partial Matching Semantics

- For this track, `partial` means the stored headword starts with the normalized user query
- For DPD, this remains the current `lookup.lookup_key LIKE '$normalized%'` behavior
- For external dictionaries, this means `dict_entries.word LIKE '$queryLower%'` (lowercase only, no diacritic stripping)
- Partial results must exclude entries already shown in exact results

### FR4: Fuzzy Matching Semantics

- For this track, `fuzzy` keeps the current algorithm and must not be redesigned
- For DPD, fuzzy remains the normalized-prefix search on `lookup.fuzzy_key`
- For external dictionaries, fuzzy remains the normalized-prefix search on `dict_entries.word_fuzzy`
- Fuzzy results must exclude entries already shown in exact or partial results

### FR5: Tier Ordering In The Search Screen

- The main search screen must render results in this order:
  1. top-level results including exact DPD headwords, exact dictionary results, roots, and secondary cards
  2. partial DPD headwords and partial dictionary results
  3. fuzzy DPD headwords and fuzzy dictionary results
- Within each tier, results follow the user's dictionary visibility ordering (`DictVisibility.order`)
- Tier 2 must be preceded by a "Partial Results" divider label
- Tier 3 must be preceded by a "Fuzzy Results" divider label
- Each divider only renders if the respective tier actually contains items
- Classic and compact display modes must preserve their existing card widgets within each tier

### FR6: No-Results Logic

- The app must show `no results found` only when:
  - DPD exact, partial, and fuzzy results are all empty
  - external dictionary exact, partial, and fuzzy results are all empty
  - root results are empty
  - secondary results are empty
- The old fuzzy-only fallback screen (`_buildFuzzyFallback`) must be removed entirely and consolidated into the unified tiered-results path
- The old `shouldShowFuzzyFallback` field must be removed from `SearchAggregateState`
- Loading states must not flash `no results found` before all relevant providers have settled

### FR7: Dictionary Order And Visibility

- Existing dictionary order and enable/disable behavior must continue to apply
- Order and visibility must affect exact, partial, and fuzzy dictionary tiers consistently
- Disabling a dictionary must remove it from all three tiers immediately
- Reordering dictionaries must reorder them consistently inside all three tiers

### FR8: Deduplication Across Tiers

- No entry may appear in more than one tier for the same query
- DPD partial must exclude exact DPD headword IDs
- DPD fuzzy must exclude DPD headword IDs already shown in exact or partial (provider-level dedup)
- Dictionary partial must exclude dictionary entry IDs already shown in exact (DAO-level exclusion)
- Dictionary fuzzy must exclude dictionary entry IDs already shown in exact or partial (provider-level dedup)

### FR9: Tier Visibility Settings

- Users must be able to independently show or hide each tier (exact, partial, fuzzy) via settings
- Three boolean settings: `showExactResults`, `showPartialResults`, `showFuzzyResults` — all default `true`
- Settings must be persisted via `SharedPreferences`
- When a tier is disabled, its results are suppressed from the search screen (empty lists passed to the UI)
- Roots and secondary results are NOT affected by these toggles — they always show in tier 1
- If all three tiers are disabled (and no roots/secondary exist), the no-results state must apply
- The aggregate search state must respect these toggles when computing `hasResults` / `shouldShowNoResults`
- Settings UI: three Hide/Show toggles in the settings panel, following the existing `CompactSegmented<bool>` pattern

## Non-Functional Requirements

- Preserve the existing Flutter, Riverpod, Drift, and SharedPreferences stack
- Do not redesign the fuzzy algorithm in this track
- Do not alter root or secondary matching behavior
- Keep the implementation localized to search DAO methods, providers, aggregate-state logic, and the search screen
- Preserve current dictionary rendering, settings persistence, and offline-first behavior
- Keep search queries bounded with limits where currently used or newly introduced
- Tests cover logic only (DAO, provider, state) — no UI/widget tests required

## Acceptance Criteria

1. A query that has exact, partial, and fuzzy DPD headword matches shows all three tiers in order in the same search screen
2. A query that has exact, partial, and fuzzy external dictionary matches shows all three tiers in order in the same search screen
3. External dictionary partial results use literal `starts with` matching on lowercased headwords, not fuzzy-key matching
4. Fuzzy results continue using the existing normalized-prefix behavior for both DPD and external dictionaries
5. No result appears in more than one tier for the same query
6. Dictionary order and visibility settings apply correctly to exact, partial, and fuzzy dictionary results
7. Roots and secondary results remain visible in the top-level section and are not forced into partial or fuzzy tiers
8. `no results found` appears only when all DPD, dictionary, root, and secondary result sources are empty
9. Tier 2 is labeled "Partial Results" and tier 3 is labeled "Fuzzy Results" — labels only render when their tier has items
10. Tier visibility toggles in settings independently hide/show exact, partial, and fuzzy results
11. Disabling all three tier toggles shows no-results (unless roots/secondary are present)

## Out of Scope

- Changing the fuzzy matching algorithm
- Adding edit-distance or typo-tolerance search
- Redesigning root or secondary result matching
- Changing autocomplete behavior
- Changing dictionary import/export behavior
- Changing dictionary HTML rendering or settings UI beyond what is required for tier placement
- UI/widget tests — only logic tests (DAO, provider, state) are in scope
