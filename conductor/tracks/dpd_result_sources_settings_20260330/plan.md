# Plan: Configurable DPD Result Sources In Settings

## Architectural Context

This is not an incremental addition to the current settings. It is a fundamental replacement of the search-result rendering pipeline.

Today, search results are assembled by a hardcoded `itemBuilder` that uses index arithmetic across seven separate typed lists in a fixed order. The `DictVisibility` system only controls external dictionaries. DPD sources are not configurable at all.

After this track, `DictVisibility` becomes the single source of truth for the ordering and visibility of every result that appears on screen — DPD and non-DPD alike. The hardcoded `itemBuilder` pipeline is replaced by a unified, order-driven result-section model.

This means:
- The existing `_SplitResultsList` itemBuilder is **replaced**, not patched
- Every search result flows through the unified ordering model
- The secondary results parser must return results keyed by type, not as one flat list
- Halfway measures (some results configurable, some still hardcoded) are not acceptable — they create exactly the kind of inconsistency this track exists to remove

Treat this as foundational architecture work, not a feature bolt-on.

## Phase 1: Unify DPD result-source ordering, visibility, and settings

- [x] Task: Define code-backed DPD source metadata and canonical ordering (e61d4bb)
    - [ ] Create the canonical code-defined DPD source list rather than relying on DB `dict_meta` rows
    - [ ] Include every configurable DPD source from the spec: `dpd_summary`, `dpd_headwords`, `dpd_roots`, `dpd_abbreviations`, `dpd_deconstructor`, `dpd_grammar`, `dpd_help`, `dpd_epd`, `dpd_variants`, `dpd_spelling`, `dpd_see`
    - [ ] Define the user-facing settings labels using `DPD ...` naming
    - [ ] Define the canonical default order with DPD items above non-DPD dictionaries
    - [ ] Preserve the current effective DPD display sequence when deriving the default order for migration

- [x] Task: Add focused logic tests for configurable result-source ordering and migration (41e6f41)
    - [ ] Identify the smallest test surface for main logic only
    - [ ] Add tests for default order initialization with all DPD items included
    - [ ] Add tests for migration that preserves existing saved order and prepends newly configurable DPD items in the current DPD sequence
    - [ ] Add tests for enabled/disabled filtering of DPD items
    - [ ] Add tests proving `DPD Headwords` exact and partial results move together as one source
    - [ ] Add tests proving `DPD Summary` only includes enabled DPD source types
    - [ ] Add tests for final presentation order across DPD items and existing dictionary items
    - [ ] Run the new targeted tests and confirm the initial failure state before implementation

- [x] Task: Extend the dictionary visibility/order model to support all DPD result sources (b5e3439)
    - [ ] Update the visibility/order state model so DPD result sources can live in the same unified ordering system as other dictionaries
    - [ ] Merge the code-defined DPD sources with DB-backed dictionary sources in one ordering model
    - [ ] Update initialization and migration logic to prepend DPD items for new and existing users without resetting existing preferences
    - [ ] Persist the updated ordering and visibility data using the existing shared-preferences mechanism
    - [ ] Run the focused logic tests and confirm they pass after the state-model changes

- [x] Task: Update settings UI to expose DPD result sources with the existing dictionary controls (12ecfed)
    - [ ] Reuse the existing reorderable dictionary settings UI pattern
    - [ ] Ensure DPD items appear above non-DPD dictionaries by default in the unified list
    - [ ] Render `DPD ...` labels for all DPD items
    - [ ] Keep drag handles, on/off controls, spacing, and styling aligned with the current settings implementation
    - [ ] Verify the settings list still works correctly when both DPD and non-DPD items are present

- [ ] Task: Refactor search-result assembly around unified configurable result sections
    - [ ] Replace the current fixed index-arithmetic ordering with a unified ordered result-section model driven by saved visibility and order
    - [ ] Apply the user-defined order independently to both result tiers: exact results above the "More Results" divider and partial/fuzzy results below it, each rendering their applicable sources in the same saved order
    - [ ] Ensure `DPD Headwords` moves exact and partial headword results together as one configurable source
    - [ ] Route `DPD Summary`, `DPD Roots`, and each DPD secondary type through the same configurable presentation model
    - [ ] Change secondary-results parsing so each secondary type can be independently filtered and positioned instead of only existing in one flat ordered list
    - [ ] Update `summary_provider.dart` so summary entries are filtered by enabled DPD sources
    - [ ] Keep existing result-card widgets and rendering styles unless a small integration change is required
    - [ ] Ensure hidden DPD items are omitted entirely from search results
    - [ ] Ensure reordered DPD items appear in the user-selected order
    - [ ] Run the focused logic tests again after integrating search-result ordering

- [ ] Task: Run project verification for the completed implementation
    - [ ] Run `flutter analyze`
    - [ ] Run the focused test set covering the main ordering and visibility logic
    - [ ] Fix any failures and rerun until clean
    - [ ] Review the implementation for unnecessary complexity and simplify if possible
    - [ ] If a command or approach fails, continue by using another non-destructive approach until the task is fully resolved

- [ ] Task: Final manual verification of configurable DPD result sources
    - [ ] Launch the app and open the settings screen
    - [ ] Verify all DPD result sources, including `DPD Summary`, appear in the unified dictionary settings list
    - [ ] Toggle multiple DPD items off and verify they disappear from search results
    - [ ] Toggle them back on and verify they return
    - [ ] Reorder `DPD Headwords`, `DPD Roots`, `DPD Summary`, and several DPD secondary items and verify search results follow the saved order
    - [ ] Verify exact and partial headword matches move together when `DPD Headwords` is reordered
    - [ ] Verify `DPD Summary` only reflects enabled DPD sources
    - [ ] Confirm persistence after app restart

- [ ] Task: Conductor - User Manual Verification 'Phase 1: Unify DPD result-source ordering, visibility, and settings' (Protocol in workflow.md)

## Key Files Reference

| File | Role |
|------|------|
| `lib/providers/dict_provider.dart` | `DictVisibility` model, `DictVisibilityNotifier.initFromMeta()` (prepend migration logic here), `presentDictSearchResults()` (applies order/visibility to dict results) |
| `lib/widgets/dict_settings_widget.dart` | Reorderable list UI with drag handles and on/off toggles — reuse this pattern for DPD items |
| `lib/screens/search_screen.dart` | `_SplitResultsList` (line ~948) and `itemBuilder` (line ~1033) — the hardcoded index-arithmetic pipeline to replace with unified result sections |
| `lib/providers/secondary_results_provider.dart` | `SecondaryResultsProvider.parse()` — currently returns one flat `List<Object>`, needs to return results keyed by type for independent filtering/positioning |
| `lib/providers/summary_provider.dart` | `buildSummaryEntries()` — needs filtering by enabled DPD sources |
| `lib/providers/search_provider.dart` | DPD search providers: `exactResultsProvider`, `partialResultsProvider`, `rootResultsProvider`, `fuzzyResultsProvider` |
| `lib/screens/settings_panel.dart` | Embeds `DictSettingsWidget()` at line ~232 |
| `lib/models/lookup_results.dart` | Data classes for all secondary result types (AbbreviationResult, GrammarDictResult, etc.) |
| `test/providers/dict_provider_test.dart` | Existing test coverage for dict visibility — extend with DPD ordering/migration tests |
