# Specification: Live Dictionary Result Updates For Reorder And Visibility

## Overview

Fix the external dictionary search results so dictionary visibility and ordering changes are reflected immediately in the current search results. At the moment, changing dictionary order or toggling a dictionary on or off in the settings panel does not visibly affect the search results in real time. This fix applies to Linux desktop and Android and must preserve persisted settings behavior.

## Background

- External dictionary integration already exists under `conductor/tracks/dictionary_integration_20260319/`
- This bug-fix track depends on that integration already being present in the app codebase before implementation begins
- Dictionary order and enabled state are currently managed in Riverpod and persisted with SharedPreferences
- Search results are rendered in the main search screen and include both exact dictionary matches and fuzzy dictionary matches
- The desired user experience is immediate visible response while the settings panel remains open

## In-Scope Dictionary Sources

- This track applies to all installed external dictionaries currently available through the app's dictionary metadata and results pipeline
- The implementation must not special-case individual dictionaries such as Cone or MW
- Any dictionary present in the installed external dictionary metadata must participate in the same order and visibility behavior

## Functional Requirements

### FR1: Immediate Reordering
- Reordering dictionaries in the settings panel must immediately reorder the currently visible dictionary result sections for the active query
- This behavior must apply without closing the settings panel, rerunning the search, or restarting the app

### FR2: Immediate Visibility Updates
- Turning a dictionary off in the settings panel must immediately hide that dictionary's currently visible result sections for the active query
- Turning a dictionary back on must immediately restore that dictionary's result sections for the active query if matches exist
- Disabled dictionaries must remain present in the settings panel

### FR3: Exact And Fuzzy Result Coverage
- The same live order and visibility behavior must apply to both exact dictionary results and fuzzy dictionary results
- Exact dictionary results must remain in the existing exact-results area of the search screen
- Fuzzy dictionary results must remain in the existing fuzzy-results area after the divider or fallback flow
- Exact and fuzzy dictionary results must not be interleaved into a single merged list as part of this fix

### FR4: Persistence
- Dictionary order and enabled state must continue to persist across app restarts
- Disabled dictionaries must continue to be excluded from future searches until re-enabled

### FR5: Scope Boundaries
- The fix must only affect external dictionary result presentation logic
- Existing DPD headword, root, and secondary result behavior must remain unchanged

### FR6: Graceful Degradation
- If external dictionary tables, metadata, or dictionary queries are unavailable, fail, or return no usable dictionary state, the app must degrade gracefully
- In degraded cases, dictionary results may be empty, but the search screen must continue to function for DPD headwords, roots, and secondary results
- The live presentation layer must not crash when dictionary metadata is incomplete or unavailable

## Non-Functional Requirements

- Preserve the current Flutter, Riverpod, Drift, and SharedPreferences stack documented in `conductor/tech-stack.md`
- Favor reactive in-memory state updates for already-loaded dictionary results over delayed async refresh behavior
- Do not add new settings controls, indicators, or visual UI changes beyond the existing reorder and toggle controls
- Maintain offline-first behavior and require no network activity for live dictionary updates
- Behavior must be consistent on Android and Linux
- Preserve the existing search-screen structure and placement of exact and fuzzy dictionary sections
- Avoid introducing dictionary-specific branching in provider logic
- Provider logic added or refactored for this track must follow the workflow coverage requirement for data and logic modules, targeting greater than 80% coverage

## Acceptance Criteria

1. Searching for `buddha`, `dhamma`, or `sanga` with matches in multiple dictionaries shows dictionary sections in the configured order
2. While the settings panel is open, dragging one dictionary above another immediately reorders the currently visible exact dictionary results for the active query
3. While the settings panel is open, dragging one dictionary above another immediately reorders the currently visible fuzzy dictionary results for the active query when fuzzy results are present
4. While the settings panel is open, turning a dictionary off immediately removes that dictionary's currently visible results from the active query
5. While the settings panel is open, turning a dictionary back on immediately restores that dictionary's current-query results if matches exist
6. After restarting the app, the same dictionary order and enabled or disabled state are retained
7. If dictionary metadata or dictionary tables are partially or fully unavailable, the app still shows any external dictionary results that remain available and continues to show non-dictionary search results normally

## Out of Scope

- Adding new dictionaries or changing import/export logic
- Changing dictionary search ranking or matching rules
- Redesigning the search screen layout
- Adding animations, badges, or extra settings feedback
- Interleaving exact and fuzzy dictionary results into a new combined ordering model
- Modifying unrelated result types such as DPD headwords, roots, or secondary cards
