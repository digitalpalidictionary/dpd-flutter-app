# Plan: Defer No-Results Message Until Search Completes

## Phase 1: Model Unified Search State

- [x] Task: Define the aggregated search-state contract for the search screen
    - [x] Review the current decision points in `lib/screens/search_screen.dart`
    - [x] Enumerate the exact async inputs that affect empty-state rendering for the current query:
        - [x] `exactResultsProvider(query)`
        - [x] `partialResultsProvider(query)`
        - [x] `rootResultsProvider(query)`
        - [x] `secondaryResultsProvider(query)`
        - [x] `dictResultsProvider(query)`
        - [x] `fuzzyResultsProvider(query)`
    - [x] Record how each source currently exposes `loading`, `data`, and `error` state
    - [x] Define the exact output state shape for the aggregator, including:
        - [x] query string identifier
        - [x] any-loading flag
        - [x] any-error flag
        - [x] has-results flag
        - [x] should-show-fuzzy-fallback flag (must only be true if exact/partial/root are empty AND fuzzy is loaded/populated)
        - [x] should-show-no-results flag
        - [x] error-capable final state when no visible results exist and a required provider fails
    - [x] Define the core state precedence: `has-results == true` MUST take precedence over `any-loading == true` to preserve progressive rendering
    - [x] Explicitly account for Riverpod's nuanced loading flags (`isLoading`, `isRefreshing`, `isReloading`) when defining "still loading"
    - [x] Define empty query (`""`) handling to short-circuit to an initial state without triggering unnecessary provider evaluations
    - [x] Keep the query identifier limited to the provider-family query string; do not add debounce metadata unless implementation proves it is necessary
    - [x] Decide where the aggregation logic will live before implementation begins:
        - [x] preferred: `lib/providers/search_state_provider.dart`
        - [ ] acceptable fallback: `lib/providers/search_provider.dart`
    - [x] Document the escalation rule: if the provider cannot be added without broad architectural churn outside search state composition, stop and pivot to the smaller loading-gate fix instead of refactoring unrelated search architecture

- [x] Task: Add logic tests for aggregated search-state behavior
    - [x] Create the logic-focused test file at `test/providers/search_state_provider_test.dart`
    - [x] Prefer `flutter_test` plus Riverpod provider overrides or a pure helper test harness over adding `riverpod_test` or `mocktail`
    - [x] Add a failing test proving `No results` is not allowed while any relevant source is still loading
    - [x] Add a failing test proving fuzzy-provider loading also blocks the no-results state
    - [x] Add a failing test proving fully loaded empty results produce a no-results state
    - [x] Add a failing test proving delayed dictionary results suppress a premature no-results state
    - [x] Add a failing test proving Progressive Rendering: if one source has results but another is still loading, it produces a results state, not a loading state
    - [x] Add a failing test proving an empty query returns an initial/empty state immediately
    - [x] Add a failing test proving any populated source produces a results state instead of a no-results state
    - [x] Add a failing test proving a stale previous query cannot drive the new query state
    - [x] Add a failing test proving provider error is not treated as loaded-empty
    - [x] Add a failing test proving provider error with no visible results blocks the no-results state

- [x] Task: Conductor - User Manual Verification 'Phase 1: Model Unified Search State' (Protocol in workflow.md)

## Phase 2: Implement Aggregated Provider Logic

- [x] Task: Create the unified search-state provider or helper
    - [ ] Add `lib/providers/search_state_provider.dart` unless Phase 1 explicitly documents that `search_provider.dart` is the lower-risk location
    - [ ] Add the minimal model/helper code needed to aggregate exact, partial, root, secondary, dictionary, and fuzzy search states
    - [ ] Implement Progressive Rendering logic: `has-results` takes precedence over `isLoading` to avoid blocking the UI
    - [ ] Short-circuit the logic if `query.isEmpty` to return a safe initial state
    - [ ] Keep loading and empty states distinct instead of collapsing loading into empty collections
    - [ ] Preserve provider-family scoping by query so in-flight results from an old query cannot control the current query state
    - [ ] Preserve provider errors as errors or blocked states instead of treating them as empty success states
    - [ ] Allow visible results from successful sources to render even when another source errors
    - [ ] Keep the query identity limited to the provider-family query string; do not add debounce metadata or cancellation primitives in this track
    - [ ] Reuse existing search result models where possible instead of introducing redundant structures

- [x] Task: Make the new logic pass the data/logic tests
    - [ ] Implement the minimal provider logic needed for the new tests to pass
    - [ ] If the first passing implementation is still hard to reason about, refactor only the aggregation code needed to make loading/error/empty decisions obvious
    - [ ] Run `flutter test test/providers/search_state_provider_test.dart`
    - [ ] Confirm the new test file passes before wiring the screen

- [x] Task: Decide whether to continue with the aggregated-provider approach
    - [ ] If the implementation remains limited to search-state composition and screen consumption, continue to Phase 3
    - [ ] If implementation requires broader architectural changes outside search-state composition, stop and update this track to the smaller loading-gate fix before touching unrelated files

- [x] Task: Conductor - User Manual Verification 'Phase 2: Implement Aggregated Provider Logic' (Protocol in workflow.md)

## Phase 3: Wire Search Screen to the Aggregated State

- [x] Task: Replace the scattered empty-state checks in `lib/screens/search_screen.dart`
    - [x] Update the search screen to read the aggregated search state instead of re-deriving completion state inline
    - [x] Ensure the fallback and no-results branches only trigger when the aggregated provider says the query is fully settled
    - [x] Preserve current rendering order for exact, partial, roots, secondary, fuzzy, and dictionary results
    - [x] Preserve existing debounce behavior by continuing to consume the debounced query provider flow already in use
    - [x] Identify and remove obsolete local loading state variables or ad-hoc timers in `search_screen.dart` that are no longer needed
    - [x] If no visible results exist and a required provider errors, avoid rendering the final no-results state for that query

- [x] Task: Verify the bug scenario manually in the GUI (Only perform this after all wiring is complete)
    - [x] Search for a term that previously showed `No results` before delayed dictionary results
    - [x] Confirm the screen stays in a loading or transitional state until results arrive or all sources are empty
    - [x] Confirm progressive rendering still works: exact/partial results appear immediately while dictionary results are still loading
    - [x] Confirm a truly empty query result still ends with `No results for "{query}"`
    - [x] Change the query while the previous query is still loading and confirm stale state does not drive the new query's empty-state decision

- [x] Task: Run project verification for this track
    - [x] Run `flutter analyze`
    - [x] Run `flutter test test/providers/search_state_provider_test.dart`
    - [x] Review changed files for accidental UI-only test additions

- [x] Task: Create user-facing commit
    - [x] Group all track changes into a single logical commit (do not scatter commits)
    - [x] Write a user-facing commit message subject (e.g., `fix: prevent "No results" flashing during search`) that explains the benefit to the user
    - [x] Put the technical details (unified search state aggregator) in the commit body

- [x] Task: Conductor - User Manual Verification 'Phase 3: Wire Search Screen to the Aggregated State' (Protocol in workflow.md)
