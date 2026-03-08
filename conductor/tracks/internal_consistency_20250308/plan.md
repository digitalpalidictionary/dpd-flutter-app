# Implementation Plan: Internal Consistency Review & Refactoring

## Phase 1: Core UI Consolidation (Footers & HTML)

- [ ] Task: Centralize Google Form URL generation in `DpdFooter`
    - [ ] Add `FeedbackType` enum.
    - [ ] Move date generation and URL string building into `DpdFooter`.
    - [ ] Update all 7 call sites (e.g., `GrammarTable`, `SuttaInfoSection`, `EntryExampleFooter`, `InflectionSection`, `FamilyTableWidget`, `FrequencySection`, `FeedbackSection`) to use the new simplified `DpdFooter` constructor.
- [ ] Task: Standardize HTML parsing in `FrequencySection`
    - [ ] Replace custom `boldRegex` parsing with standard `flutter_html` `Html()` widget or a centralized utility for inline styling.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Core UI Consolidation' (Protocol in workflow.md)

## Phase 2: Table Consolidation

- [ ] Task: Consolidate Family Tables
    - [ ] Extract `_FamilyTable` from `family_table.dart`.
    - [ ] Remove `_FamilySubTable` from `multi_family_section.dart`.
    - [ ] Replace both with a new shared `FamilyEntryTable` widget.
- [ ] Task: Centralize Key-Value Table Row Builders
    - [ ] Create shared row builder functions (`buildTextRow`, `buildLinkRow`, etc.) or a generic `DpdKeyValueTable` widget in `entry_content.dart`.
    - [ ] Refactor `GrammarTable` to use the shared builders.
    - [ ] Refactor `SuttaInfoSection` to use the shared builders.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Table Consolidation' (Protocol in workflow.md)

## Phase 3: Entry Card State & Logic Unification

- [ ] Task: Simplify Expansion State Management
    - [ ] Create an `EntrySectionsState` class or mixin tracking `Set<String> openSections`.
    - [ ] Implement `toggleSection(String sectionId, bool oneButtonAtATime)` logic.
- [ ] Task: Merge `AccordionCard` and `InlineEntryCard` Section Logic
    - [ ] Create a shared `EntrySectionsManager` (or similar widget/mixin) that handles the unified button row and section rendering.
    - [ ] Update `AccordionCard` to use the shared logic.
    - [ ] Update `InlineEntryCard` to use the shared logic.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Entry Card State & Logic Unification' (Protocol in workflow.md)

## Phase 4: Provider Architecture Review

- [ ] Task: Standardize Providers
    - [ ] Review current providers (Settings, History, Search, Database Update).
    - [ ] Ensure consistent use of `StateNotifier` / `Notifier` and eliminate unnecessary boilerplate or disjointed state management where applicable.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Provider Architecture Review' (Protocol in workflow.md)