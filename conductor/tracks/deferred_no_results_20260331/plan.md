# Plan: Defer No-Results Message Until Search Completes

## Phase 1: Model Unified Search State

- [ ] Task: Define the aggregated search-state contract for the search screen
    - [ ] Review the current decision points in `lib/screens/search_screen.dart` and list all async search inputs that affect empty-state rendering
    - [ ] Decide the minimal state shape needed to represent loading, has-results, and loaded-empty outcomes for a query
    - [ ] Document where the aggregation logic will live so the widget no longer owns the final empty-state decision

- [ ] Task: Add logic tests for aggregated search-state behavior
    - [ ] Create or update a logic-focused test file under `test/` for the aggregation rules
    - [ ] Add a failing test proving `No results` is not allowed while any relevant source is still loading
    - [ ] Add a failing test proving fully loaded empty results produce a no-results state
    - [ ] Add a failing test proving delayed dictionary results suppress a premature no-results state
    - [ ] Add a failing test proving any populated source produces a results state instead of a no-results state

- [ ] Task: Conductor - User Manual Verification 'Phase 1: Model Unified Search State' (Protocol in workflow.md)

## Phase 2: Implement Aggregated Provider Logic

- [ ] Task: Create the unified search-state provider or helper
    - [ ] Add the minimal model/helper code needed to aggregate exact, partial, root, secondary, dictionary, and fuzzy search states
    - [ ] Keep loading and empty states distinct instead of collapsing loading into empty collections
    - [ ] Reuse existing search result models where possible instead of introducing redundant structures

- [ ] Task: Make the new logic pass the data/logic tests
    - [ ] Implement the minimal provider logic needed for the new tests to pass
    - [ ] Refactor only if needed for clarity after the tests pass
    - [ ] Run the targeted logic tests again and confirm they pass

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Implement Aggregated Provider Logic' (Protocol in workflow.md)

## Phase 3: Wire Search Screen to the Aggregated State

- [ ] Task: Replace the scattered empty-state checks in `lib/screens/search_screen.dart`
    - [ ] Update the search screen to read the aggregated search state instead of re-deriving completion state inline
    - [ ] Ensure the fallback and no-results branches only trigger when the aggregated provider says the query is fully settled
    - [ ] Preserve current rendering order for exact, partial, roots, secondary, fuzzy, and dictionary results

- [ ] Task: Verify the bug scenario manually
    - [ ] Search for a term that previously showed `No results` before delayed dictionary results
    - [ ] Confirm the screen stays in a loading or transitional state until results arrive or all sources are empty
    - [ ] Confirm a truly empty query result still ends with `No results for "{query}"`

- [ ] Task: Run project verification for this track
    - [ ] Run `flutter analyze`
    - [ ] Run the relevant logic tests for the new aggregation code
    - [ ] Review changed files for accidental UI-only test additions

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Wire Search Screen to the Aggregated State' (Protocol in workflow.md)
