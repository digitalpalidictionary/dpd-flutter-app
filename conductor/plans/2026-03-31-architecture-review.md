# DPD Flutter App Architecture Review

## Purpose

This document maps the current architecture of the app, identifies where responsibilities are spread across too many files or hidden behind conventions, and recommends a consolidation path toward self-contained feature modules with minimal "magic".

The review is based on the current code in `lib/`, project docs, and the active Conductor structure on 2026-03-31.

---

## Executive Summary

The app is already built on sensible primitives:

- Flutter for UI
- Riverpod for state
- Drift for local SQLite access
- SharedPreferences for lightweight persistence
- A clear offline-first product model
- External dictionary scope currently integrated: Cone, CPD, and MW

The core problem is not that the architecture is missing. The problem is that the architecture is distributed.

Responsibilities are spread across:

- very large screen/widget files
- provider files that mix domain logic, data access, presentation shaping, and persistence
- extension methods and mixins that contain business rules away from the feature that uses them
- string-based conventions shared across multiple providers and widgets

So the system works, but it is harder than it should be to answer basic questions like:

- Where does search really live?
- Where is the single place that defines a search result source?
- Where is entry display state owned?
- Where is update orchestration owned?
- Which code is domain logic vs UI shaping vs persistence glue?

My recommendation is to move from "layer-by-file-type" toward "feature modules with explicit internal layers".

---

## Current Architecture Map

## 1. App bootstrap and shell

### Entry and boot flow

- `lib/main.dart`
  - initializes Flutter bindings
  - loads `SharedPreferences`
  - reads initial intent text
  - starts native intent lookup handling
  - injects preferences into Riverpod
- `lib/app.dart`
  - owns theme construction
  - owns navigator and routes
  - defers first frame until DB state is known
  - subscribes to intent streams
  - triggers DB and app update checks
  - gates startup through `_DbGate`

### Shell responsibilities

`DpdApp` is the runtime shell. It currently coordinates:

- theme selection
- route generation
- startup gating
- intent handling
- Linux hotkey hookup
- first-frame release timing
- app update trigger timing

This is functional, but it makes `app.dart` both application shell and startup orchestrator.

---

## 2. Data and persistence layer

### Database schema

- `lib/database/tables.dart`
  - Drift table definitions for:
    - `dpd_headwords`
    - `lookup`
    - `dpd_roots`
    - `db_info`
    - inflection templates
    - family tables
    - `sutta_info`
    - external dictionary metadata and entries

### Database runtime

- `lib/database/database.dart`
  - opens the local DB file
  - defines schema version
  - contains compatibility assumptions for wholesale DB replacement

### Query access

- `lib/database/dao.dart`
  - single large DAO for almost all read concerns:
    - exact search
    - partial search
    - fuzzy search
    - root search
    - single entry fetch
    - family lookups
    - root matrix inputs
    - autocomplete data
    - external dictionary search
    - metadata fetches

### Domain helpers near the DB

- `lib/database/dpd_headword_extensions.dart`
  - headword cleanup logic
  - construction summarization
  - grammar line assembly
  - section/button visibility rules
- `lib/database/sutta_info_extensions.dart`
  - sutta citation formatting helpers

`dpd_headword_extensions.dart` is important: it contains real domain policy, not just cosmetic helpers.

---

## 3. State management

State is primarily split into Riverpod providers under `lib/providers/`.

### Infrastructure providers

- `database_provider.dart`
  - creates `AppDatabase`
  - creates `DpdDao`
  - exposes compound/idiom/root matrix support providers
- `settings_provider.dart`
  - app settings state
  - SharedPreferences persistence
- `history_provider.dart`
  - search history state
  - SharedPreferences persistence

### Search providers

- `search_provider.dart`
  - query state
  - exact / partial / root / fuzzy result providers
- `secondary_results_provider.dart`
  - parses `lookup` row JSON into typed secondary results
- `dict_provider.dart`
  - external dictionary metadata
  - dict visibility and ordering persistence
  - dict search result shaping
- `summary_provider.dart`
  - summary rows assembled from exact/root/secondary results
- `search_state_provider.dart`
  - aggregate "loading / has results / no results / error" computation
- `autocomplete_provider.dart`
  - precomputed index cache on disk
  - in-memory suggestion lookup

### Update and network providers

- `database_update_provider.dart`
  - DB lifecycle state machine
  - release check + download/install orchestration
- `app_update_provider.dart`
  - app release check + APK download/install orchestration
- `internet_provider.dart`
  - DNS-based internet availability probe
- `template_cache_provider.dart`
  - preloads inflection templates

This is a lot of provider surface area. The pieces are useful, but the module boundaries are provider-shaped rather than feature-shaped.

---

## 4. Services layer

- `services/database_update_service.dart`
  - talks to GitHub Releases for DB updates
  - downloads zip
  - extracts and swaps DB
  - checks schema compatibility
- `services/app_update_service.dart`
  - talks to GitHub Releases for APK updates
  - downloads APK
- `services/intent_service.dart`
  - Android/Linux method/event channel integration
- `services/audio_service.dart`
  - playback singleton and URL construction

These services are thin and useful, but the update workflow is split between services and providers in a way that duplicates lifecycle logic.

---

## 5. UI layer

### Screens

- `search_screen.dart`
  - search input
  - debouncing
  - overlays
  - history controls
  - info popup/content
  - desktop side panels
  - search result composition
  - compact/expanded secondary result rendering
  - update footer
- `entry_screen.dart`
  - full headword display
- `root_screen.dart`
  - root detail display
- `download_screen.dart`
  - blocking first-run DB install screen

### Shared widgets and mixins

- `entry_content.dart` (669 lines)
  - summary box
  - section button
  - examples
  - play button
  - general entry building helpers
- `entry_sections_mixin.dart` (202 lines)
  - core entry section state and composition
- `family_state_mixin.dart` (279 lines)
  - family section state and lazy loading
- `inline_entry_card.dart`, `accordion_card.dart`
  - classic vs compact entry result styles
- `inline_root_card.dart`
  - root result styles

### Search-adjacent widgets

- `autocomplete_dropdown.dart` — dropdown overlay for search suggestions
- `double_tap_search_wrapper.dart` — gesture wrapper for double-tap word lookup
- `compact_segmented.dart` — segmented control used in compact result tier layout

### Family rendering widgets

- `family_table.dart` — `FamilyTableWidget`, the shared native table renderer
- `family_section_builders.dart` — section header and row builders for family data
- `family_toggle_section.dart` — collapsible family section with toggle
- `multi_family_section.dart` — multi-family display for entries with several family groups

### Root display widgets

- `root_info_table.dart` — root metadata display (dhatupatha, dhatumanjusa, etc.)
- `root_matrix_builder.dart` — builds root matrix data for rendering
- `root_matrix_table.dart` — native table widget for root matrix

### Dictionary widgets

- `dict_html_card.dart` — HTML card for external dictionary entries (currently Cone, CPD, and MW)
- `dict_settings_widget.dart` — per-dictionary visibility and ordering controls

### Entry section widgets

- `grammar_table.dart` — grammar section native table (354 lines)
- `inflection_section.dart`, `inflection_table.dart` — inflection display
- `frequency_section.dart`, `frequency_table.dart` — frequency corpus display
- `sutta_info_section.dart` — sutta citation display
- `summary_section.dart` — summary box section widget

### Feedback infrastructure

- `feedback_footer.dart` — `DpdFooter` widget, standardized section footer with feedback link
- `feedback_section.dart` — full feedback section with prompts
- `feedback_type.dart` — typed enum for feedback link variants

### Other widgets

- `settings_panel.dart` (501 lines) — settings screen panel
- `history_panel.dart` — search history display panel
- `velthuis_help_popup.dart` — Velthuis input guide popup
- `secondary/secondary_card.dart`, `secondary_result_cards.dart` — compact secondary result rendering
- `secondary/bibliography_card.dart`, `secondary/thanks_card.dart` — static content cards

The UI is functional, but the composition strategy relies heavily on large files plus mixins plus helper files, which makes ownership diffuse.

---

## 6. Supporting layers

- `lib/theme/dpd_colors.dart`
  - `ColorScheme` definitions for light and dark themes
  - applied globally via `app.dart`
- `lib/models/`
  - typed parsed results and small data builders
- `lib/utils/`
  - `feedback_urls.dart` — feedback URL construction per section
  - `app_feedback_url.dart` — app-level feedback URL helper
  - `date_utils.dart` — `dpdDateStamp()` and `dpdAppLabel()` for feedback form tagging
  - `diacritics.dart`, `velthuis.dart` — Pāli input normalization
  - `pali_sort.dart`, `text_filters.dart` — sorting and filtering utilities
- `lib/data/help_data.dart`
  - bibliography / thanks data loaders
- `scripts/build_mobile_db.py`
  - DB export support
- `conductor/`
  - project/product/planning system

---

## Runtime Data Flows

## Search flow

1. User types in `SearchScreen`
2. UI debounces and writes to `searchQueryProvider`
3. Multiple provider branches fire independently:
   - exact headwords
   - partial headwords
   - roots
   - fuzzy headwords
   - secondary lookup-row parsing
   - external dict search
   - summary shaping
4. `SearchScreen` watches many providers directly and assembles tiers
5. `_SplitResultsList` re-groups results according to visibility/order settings
6. Widgets render classic or compact versions

This flow works, but there is no single "search feature orchestrator". Search is assembled live across many files.

## Entry flow

1. Route navigates to `/entry`
2. `_entryProvider` fetches `DpdHeadwordWithRoot`
3. `EntryScreen` delegates section/family behavior to mixins
4. Mixins fetch related data lazily:
   - sutta info
   - family rows
   - templates
   - frequency parsing
5. UI widgets render sections based on extension-based rules

Again, this works, but the behavior is split between screen, mixins, DB helpers, providers, and extensions.

## Update flow

1. App boot calls `dbUpdateProvider.notifier.checkForUpdates()`
2. DB update provider talks to `DatabaseUpdateService`
3. App first frame is delayed until DB state is acceptable
4. Once startup is released, app update check begins
5. Search screen and download screen also reflect update state

This is a genuine application workflow, but it is spread between `main.dart`, `app.dart`, provider state machines, services, and UI widgets.

---

## What Is Good

- The app is offline-first by design, not as an afterthought.
- Drift gives strong schema visibility and typed access.
- Riverpod is already used in a mostly disciplined way.
- The product model is clear: search, entry, roots, dictionaries, updates.
- There are meaningful tests for providers, parsing, models, DAO behavior, and selected widgets.
- The Conductor docs create good project memory outside the code.

This is a solid base. The next step is not a rewrite. It is consolidation.

---

## Main Architectural Problems

## 1. Feature logic is scattered across file-type buckets

Search behavior is spread across:

- `providers/search_provider.dart`
- `providers/secondary_results_provider.dart`
- `providers/dict_provider.dart`
- `providers/summary_provider.dart`
- `providers/search_state_provider.dart`
- `screens/search_screen.dart`
- several widgets and models

That means "search" is not a module. It is a cross-cutting reconstruction.

The same pattern appears in entry display and updates.

## 2. Some files have become de facto subsystems

The clearest examples, with current line counts:

- `lib/screens/search_screen.dart` — **1507 lines**
- `lib/widgets/entry_content.dart` — 669 lines
- `lib/database/dao.dart` — 618 lines
- `lib/widgets/settings_panel.dart` — 501 lines

These files are carrying too many reasons to change.

## 3. Providers mix domain logic, persistence, and presentation shaping

Examples:

- `dict_provider.dart` contains:
  - source metadata
  - visibility persistence
  - result grouping
  - presentation ordering
- `summary_provider.dart` maps runtime result types to summary entry presentation
- `database_update_provider.dart` contains both state machine logic and install orchestration

These are not just providers. They are mini application services hidden as provider files.

## 4. Important domain rules live in extensions and mixins

`dpd_headword_extensions.dart` is effectively a policy file:

- grammar availability
- example availability
- inflection visibility
- family visibility
- construction summaries

Likewise, `EntrySectionsMixin` and `FamilyStateMixin` encode important behavior for entry rendering and lazy loading.

That means core feature rules are not discoverable from the feature root.

## 5. String-driven architecture creates hidden coupling

The app relies on many string IDs and conventions:

- route names
- source IDs like `dpd_headwords`, `dpd_summary`, `dpd_see`
- summary target IDs like `hw_123`, `root_x`, `sec_help_y`
- section IDs like `grammar`, `examples`, `inflections`, `notes`
- SharedPreferences keys

These strings are repeated across providers, widgets, and persistence. That is a classic source of "magic".

## 6. The DAO is too broad

`DpdDao` is effectively:

- search repository
- entry repository
- root repository
- family repository
- metadata repository
- dictionary repository
- autocomplete source

A single large DAO is convenient early on, but it becomes a navigation bottleneck and encourages unrelated logic to accumulate.

## 7. Search orchestration is fragmented

There is no single typed search result graph.

Instead:

- each provider produces a slice
- `SearchScreen` manually watches many slices
- screen code deduplicates, filters, and gates visibility
- `_SplitResultsList` then re-sorts into UI tiers

That makes the screen do orchestration work that should belong to a search application layer.

## 8. Update architecture is duplicated

DB update and app update are similar workflows:

- release check
- version comparison
- conditional download
- progress state
- install/apply

But they are implemented as parallel systems rather than one shared update framework with typed specializations.

---

## What I Would Change

## Target direction

Move to feature-first architecture inside `lib/features/`, with each feature containing:

- `domain/`
  - entities
  - typed enums/value objects
  - business rules
- `data/`
  - repositories
  - datasource adapters over Drift/native services
- `application/`
  - controllers / orchestrators / state reducers
  - Riverpod providers for the feature
- `presentation/`
  - screens
  - widgets

Then keep cross-cutting platform/infrastructure code in:

- `lib/app/`
- `lib/core/`
- `lib/platform/`

---

## Proposed module map

## `lib/app/`

- app bootstrap
- routes
- theme
- startup coordinator

## `lib/core/`

- shared result types
- reusable utilities that are truly generic
- common UI primitives only if genuinely cross-feature

## `lib/platform/`

- intent integration
- audio integration
- GitHub release client
- file storage paths
- connectivity probing

## `lib/features/search/`

- search query state
- search orchestration
- autocomplete
- summary generation
- result source ordering/visibility
- search screen and result list widgets

## `lib/features/entry/`

- headword entry repository
- entry section model
- section/family state controller
- entry screen and entry cards

## `lib/features/roots/`

- root repository
- root matrix builder
- root screen/widgets

## `lib/features/updates/`

- app update workflow
- database update workflow
- shared update job abstractions
- startup/update UI pieces

## `lib/features/settings/`

- settings model
- persistence adapter
- settings screen/panel widgets

## `lib/features/history/`

- history state
- history persistence
- history UI

## `lib/features/dictionaries/`

- dictionary metadata
- dictionary visibility/order
- dictionary search
- dictionary result rendering

This is not about purity. It is about making it obvious where a subsystem lives.

---

## Concrete Refactors I Recommend

## 1. Create a single SearchController/SearchState

Replace the current many-provider assembly with one feature entry point:

- `SearchController`
- `SearchState`
- `SearchResultBundle`

The controller should:

- normalize the query
- trigger all search sources
- dedupe headword tiers once
- apply visibility settings once
- produce typed sections ready for rendering

Then `SearchScreen` becomes mostly UI, not orchestration.

This is the highest-value refactor.

## 2. Split `DpdDao` into repositories or query modules

Suggested split:

- `SearchRepository`
- `EntryRepository`
- `RootRepository`
- `DictionaryRepository`
- `MetadataRepository`

These can still share the same `AppDatabase`, but navigation becomes much better and feature ownership becomes explicit.

## 3. Replace string IDs with typed enums/value objects

Examples:

- `SearchSourceId`
- `EntrySectionId`
- `SummaryTarget`
- `PrefKey`

This will remove a large amount of hidden coupling and make refactors safer.

## 4. Move headword/entry business rules out of extensions into domain objects

`dpd_headword_extensions.dart` should not be the secret location for core feature rules.

Instead, create something like:

- `EntryPolicy`
- `EntryViewModelFactory`
- `HeadwordDisplayRules`

Extensions can remain for trivial formatting helpers, but not for major section policy.

## 5. Replace UI mixins with explicit controllers or local state objects

`EntrySectionsMixin` and `FamilyStateMixin` work, but they hide ownership and make behavior harder to trace.

Prefer:

- `EntrySectionController`
- `FamilySectionController`
- or a single `EntryViewState`

Then both full-screen and inline cards can reuse the same explicit state object.

## 6. Break up the large screen/widget files

Priority order (with current line counts):

1. `search_screen.dart` — 1507 lines
2. `entry_content.dart` — 669 lines
3. `dao.dart` — 618 lines
4. `settings_panel.dart` — 501 lines

For `search_screen.dart`, I would split into:

- search app bar/header
- query input
- info popup
- info content view
- result list builder
- compact secondary renderers
- footers and empty states

## 7. Introduce a unified update workflow abstraction

Create a shared update framework:

- `ReleaseClient`
- `UpdateJob`
- `DownloadInstaller`
- `UpdateState`

Then specialize for:

- `DatabaseUpdateJob`
- `AppUpdateJob`

This will reduce duplicated version-check and download progress logic.

## 8. Move persistence-backed UI settings into feature-owned stores

Current pattern is reasonable, but feature boundaries would improve if persistence lived closer to ownership:

- settings prefs in settings feature
- history prefs in history feature
- dict visibility prefs in dictionaries feature

The provider can stay. The file ownership should change.

## 9. Introduce typed presentation models at feature boundaries

The UI should consume view models, not raw mixed domain/runtime objects where possible.

Examples:

- `SearchSectionVm`
- `SearchResultCardVm`
- `EntrySectionVm`
- `RootScreenVm`

That reduces widget branching and removes repeated transformation logic from the UI layer.

## 10. Centralize startup orchestration

Create an explicit startup coordinator that owns:

- initial intent text
- DB readiness
- first-frame release
- post-start app update check
- desktop hotkey binding

Then `main.dart` and `app.dart` become much easier to read.

---

## Recommended Refactor Order

## Phase 1: Low-risk clarity gains

- add `lib/features/` structure without changing behavior
- move files into feature folders
- split `search_screen.dart` into presentation-only parts
- split `dao.dart` into repository files over the same DB
- centralize constants for IDs and pref keys

## Phase 2: Remove hidden coupling

- create typed enums/value objects for source IDs and section IDs
- move domain policy out of extensions/mixins into feature classes
- replace mixins with explicit entry state/controller objects

## Phase 3: Orchestration cleanup

- build unified `SearchController`
- build unified startup coordinator
- build shared update workflow abstraction

## Phase 4: Presentation simplification

- have widgets consume feature view models
- reduce direct provider fan-out from screens
- keep screens thin and declarative

---

## Immediate architecture actions (current scope)

- Keep architecture work strictly separate from dictionary-catalog expansion.
- Treat the currently integrated external dictionaries (Cone, CPD, MW) as the stable boundary for this architecture pass.
- Focus changes on module boundaries, orchestration ownership, typed IDs, and file decomposition.
- Defer onboarding additional dictionaries to dedicated feature tracks so architecture progress stays measurable and reviewable.

---

## What I Would Not Change Yet

- I would not replace Riverpod, Drift, or Flutter structure wholesale.
- I would not add heavy architecture frameworks.
- I would not over-abstract the DB layer before splitting it by feature.
- I would not rewrite working entry widgets unless their behavior is being actively consolidated.

This codebase does not need a rewrite. It needs stronger boundaries.

---

## Highest-Value Specific Changes

If I were choosing only five changes:

1. Introduce `lib/features/search/` and move all search-related code under it.
2. Build a single `SearchController` so search stops being assembled in `SearchScreen`.
3. Split `DpdDao` into feature repositories.
4. Replace section/source string literals with typed identifiers.
5. Replace entry/family mixins with explicit controllers or state objects.

Those five changes would eliminate most of the "magic looking here and there".

---

## Bottom Line

The project has a real architecture already, but it is implicit and scattered.

Today the codebase is organized mostly by technical file type:

- providers
- services
- database
- widgets
- screens

For a small app that is fine. For this app, which now has search, roots, dictionaries, updates, history, settings, desktop integration, and multiple result styles, that organization is starting to hide the system.

The next architecture step is to make the system visible:

- group code by feature
- give each feature one obvious home
- give orchestration one obvious owner
- replace repeated strings with typed identifiers
- move policy out of mixins/extensions into explicit domain/application objects

That would make the codebase much easier to study, change, and trust.
