# Plan: Live Dictionary Result Updates For Reorder And Visibility

## Phase 0: Prerequisites And Existing-State Verification

- [x] Task: Verify external dictionary integration prerequisites in the current codebase
    - [x] Confirm the app still contains the external dictionary provider, settings, and search integration paths from `dictionary_integration_20260319`
    - [x] Confirm dictionary metadata is sourced from installed dictionary metadata providers rather than a hardcoded dictionary ID list such as `cone` and `mw`
    - [x] Confirm the current search screen keeps exact and fuzzy dictionary results in separate sections

- [x] Task: Conductor - User Manual Verification 'Phase 0: Prerequisites And Existing-State Verification' (Protocol in workflow.md)

## Phase 1: Provider State Separation And Live Ordering

- [x] Task: Add provider tests for live dictionary order and visibility updates
    - [x] Create a new provider test file at `test/providers/dict_provider_test.dart`
    - [x] Add provider-level tests for dictionary result transformations only
    - [x] Run the new provider tests first and confirm they fail before starting the refactor task
    - [x] Add a failing test showing reorder changes immediately affect current exact results without rerunning the query
    - [x] Add a failing test showing toggle-off immediately removes current exact results without rerunning the query
    - [x] Add a failing test showing toggle-on immediately restores current exact results when matches exist
    - [x] Add a failing test showing the same behavior applies to fuzzy dictionary results
    - [x] Add a failing test showing disabled dictionaries are excluded while remaining available in settings state
    - [x] Add a failing test covering unavailable dictionary tables or metadata and confirm graceful empty-result degradation

- [x] Task: Refactor dictionary providers to separate fetched data from live presentation state
    - [x] Keep async database fetching for raw dictionary matches by query
    - [x] Move order and enabled-state application into a derived reactive provider layer
    - [x] Ensure the derived provider watches dictionary visibility state and recomputes synchronously for already-loaded results
    - [x] Ensure the derived provider applies the same rules generically to all installed external dictionaries
    - [x] Preserve graceful degradation when dictionary tables are unavailable
    - [x] Preserve SharedPreferences-backed order and enabled-state persistence

- [~] Task: Verify provider logic quality gates for Phase 1
    - [x] Run targeted provider tests and confirm they pass
    - [ ] Run coverage for the changed dictionary provider logic and confirm greater than 80% coverage
    - [x] Run static analysis for the changed files and confirm no errors

- [ ] Task: Conductor - User Manual Verification 'Phase 1: Provider State Separation And Live Ordering' (Protocol in workflow.md)

## Phase 2: Search Screen Integration And Manual UX Verification

- [x] Task: Update search screen consumers to use live dictionary presentation state
    - [x] Update the main results path to consume the live dictionary result provider
    - [x] Update the fuzzy fallback path to consume the live dictionary result provider
    - [x] Ensure exact dictionary sections remain in the existing exact-results area
    - [x] Ensure fuzzy dictionary sections remain in the existing fuzzy-results area or fallback flow
    - [x] Ensure no extra user action is required for visible updates while the settings panel is open

- [x] Task: Verify persisted behavior and regression boundaries
    - [x] Confirm disabled dictionaries remain excluded from future searches until re-enabled
    - [x] Confirm dictionary rows remain visible in the settings panel when disabled
    - [x] Confirm DPD headword, root, and secondary result rendering remains unchanged
    - [x] Confirm persisted order and enabled-state behavior remains intact after restart
    - [x] Confirm no dictionary-specific logic was introduced for individual sources

- [x] Task: Verify integration quality gates for Phase 2
    - [x] Run relevant tests for changed provider and search integration logic
    - [x] Run `flutter analyze` and confirm no errors
    - [x] Prepare a manual verification flow for Android using `buddha`, `dhamma`, or `sanga`
    - [x] Prepare a manual verification flow for Linux using `buddha`, `dhamma`, or `sanga`

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Search Screen Integration And Manual UX Verification' (Protocol in workflow.md)
