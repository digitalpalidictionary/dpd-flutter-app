# Specification: Defer No-Results Message Until Search Completes

## Overview

Fix the search screen so the `No results for "{query}"` message is shown only after all relevant search sources have finished loading for the current query.

This track follows the long-term solution option: replace the current scattered empty-state checks with a single aggregated search-state model that distinguishes `loading`, `loaded-empty`, and `loaded-with-results` across all search providers.

## Example Scenario

### Before
- User searches for a term with no exact DPD match.
- Fuzzy DPD results finish first and return empty.
- External dictionary results are still loading.
- The screen briefly shows `No results for "{query}"`.
- External dictionary cards appear immediately afterward.

### After
- User searches for the same term.
- Fuzzy DPD results finish first and return empty.
- External dictionary results are still loading.
- The screen stays in a loading or transitional state.
- Only after all required search sources settle does the UI choose between:
  - showing results from any source, or
  - showing `No results for "{query}"`.

## Background

- The current search UI in `lib/screens/search_screen.dart` combines multiple async providers directly in the widget.
- Several providers are read using `valueOrNull ?? []`, which makes `still loading` indistinguishable from `finished with no results`.
- The current fallback path waits for fuzzy DPD results, but can still treat external dictionary results as empty while they are loading.
- This produces a visible false negative: `No results` flashes first, then dictionary results appear.

## Functional Requirements

### FR1: Unified Search Completion State
- Introduce a single aggregated search-state layer for the search screen.
- The aggregated state must combine these required sources for the current query:
  - `exactResultsProvider(query)`
  - `partialResultsProvider(query)`
  - `rootResultsProvider(query)`
  - `secondaryResultsProvider(query)`
  - `dictResultsProvider(query)`
  - `fuzzyResultsProvider(query)`
- The aggregated state must preserve the distinction between:
  - still loading
  - loaded with at least one result
  - fully loaded with no results
- The aggregated state must expose a single final UI decision for the current query only.

### FR1.1: Aggregated State Shape
- The implementation must define an explicit state shape that can represent, at minimum:
  - the query string the state belongs to
  - whether any required provider is still loading
  - whether any required provider failed
  - whether any result source contains visible results
  - whether fuzzy fallback content should be rendered
  - whether the no-results message is allowed to render
- The state shape must support "Progressive Rendering": if `has-results` is true, it must produce a "loaded-with-results" state even if `any-loading` is true, preventing the UI from blocking if fast providers complete while slow providers are still in flight.
- The state must handle an empty query (`""`) gracefully, short-circuiting to an initial/empty state without triggering unnecessary provider evaluations.
- The final design may be an enum-backed model, a sealed set of states, or a compact data object, but it must make `loading`, `results`, and `no-results` mutually distinguishable without relying on `valueOrNull ?? []`.
- The query identifier for this track is the current query string used to instantiate the Riverpod provider families. It does not need extra debounce metadata or cancellation tokens.

### FR2: Correct No-Results Timing
- The `No results for "{query}"` message must only appear after every required provider for that query has settled.
- While any relevant provider is still loading and no visible results have arrived yet, the UI must remain in a loading or transitional state rather than showing a no-results message.
- "Still loading" must accurately reflect Riverpod's loading nuances (e.g., taking into account `isLoading`, `isRefreshing`, or `isReloading` depending on how providers are consumed) to avoid flashing "No results" during provider invalidation/refresh.
- The bug where dictionary cards appear after a premature no-results message must be eliminated.
- `fuzzyResultsProvider(query)` is part of the required completion set for the no-results decision.
- `dictResultsProvider(query)` is part of the required completion set for the no-results decision.

### FR2.1: Query Changes During Loading
- Aggregated search state must be scoped to the current query string.
- If the user changes the query while earlier providers are still in flight, the UI must discard the old query state and render only against the new query's provider family instances.
- This track does not require explicit cancellation primitives or debounce metadata in the state model; Riverpod query scoping is sufficient as long as stale results do not control the empty-state decision for the new query.

### FR2.2: Provider Failure Handling
- A provider error must not be silently treated as a successful empty result.
- If a required provider fails for the current query, the aggregated state must preserve that distinction so the implementation can avoid incorrectly showing `No results`.
- If any source has visible results, those results may still render even if another source has errored.
- If no source has visible results and one or more required providers error, the aggregate state must block the no-results message and surface an error-capable state instead of `loaded-empty`.
- This track may continue to use the screen's existing error presentation for primary failures, but the aggregation logic must not collapse `error` into `empty`.

### FR3: Preserve Current Search Ordering and Content
- Existing result ordering must remain unchanged.
- Existing exact-match, partial-match, root, secondary, and dictionary content must still render as before.
- Existing fuzzy fallback behavior must remain intact, except for the corrected timing of the empty state.
- Fuzzy loading is part of the required completion set for deciding whether `No results` may render.
- `shouldShowFuzzyFallback` should only become true if exact, partial, and root results are empty AND the fuzzy provider has finished loading with results.

### FR3.1: Progressive Rendering
- If primary results (e.g., exact matches) complete quickly, they must be displayed immediately.
- The aggregator must not block the UI (e.g., force a full-screen loading spinner) if at least one source has returned visible results, even if slower providers (like dictionary) are still loading.

### FR4: Logic-Level Test Coverage
- Add or update tests for the aggregated search-state logic only.
- Tests must cover these cases:
  - one or more providers still loading (with no results)
  - progressive rendering: one provider loaded with results while another is still loading
  - empty query (`""`) short-circuiting
  - all providers loaded and empty
  - dictionary results arriving after fuzzy results
  - at least one source returning results
  - stale prior-query state not controlling the current query decision
  - provider error not being treated as a completed empty result
- No widget or UI rendering tests are required for this track.
- The logic tests for this track must live in a dedicated test file under `test/providers/` or `test/models/`, depending on where the aggregation logic is implemented.
- Prefer testing a pure aggregation helper or provider-composition function with `flutter_test` and Riverpod provider overrides rather than introducing a new mocking package unless implementation requires it.

## Non-Functional Requirements

- Keep the implementation minimal and easy to reason about.
- Prefer consolidating state decisions into provider logic instead of duplicating conditional checks in the widget tree.
- Avoid changing the search provider APIs more than necessary.
- Maintain compatibility with the existing Riverpod architecture and current search result models.
- Do not introduce explicit request cancellation infrastructure unless implementation proves it is necessary to satisfy the acceptance criteria.
- Prefer a minimal clear implementation over a broader refactor. If the first passing version is functionally correct but awkward, refactor only when the awkwardness materially harms readability or makes loading/error/empty behavior hard to trust.

## Acceptance Criteria

1. Searching a term with delayed dictionary results never shows `No results` before those dictionary results appear.
2. Searching a term with truly no matches across all search sources shows `No results for "{query}"` only after all search work finishes.
3. Progressive rendering is preserved: exact/partial results appear immediately even if the dictionary is still loading.
4. Searching a term with exact, partial, root, secondary, fuzzy, or dictionary results continues to show those results without regression.
5. Changing the search query while previous providers are still loading does not allow stale state to trigger `No results` for the new query.
6. Provider errors are not incorrectly rendered as a no-results success state.
7. Logic tests cover the loading-versus-empty distinction (and progressive rendering) and pass successfully.
8. No widget tests are added for this track.

## Out of Scope

- Redesigning the visual style of the search screen
- Changing the result ranking or source ordering
- Reworking unrelated search performance behavior
- Adding new result sources
- Adding explicit cancellation tokens or a new debouncing mechanism
