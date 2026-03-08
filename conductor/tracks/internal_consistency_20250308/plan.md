# Implementation Plan: Internal Consistency Review & Refactoring

## Phase 1: Quick Wins (Trivial Deduplication)

- [ ] Task: Extract `dpdDateStamp()` utility
    - [ ] Create utility function in `lib/utils/` returning `yyyy-MM-dd` string.
    - [ ] Replace 5 duplicate date constructions: `EntryExampleFooter`, `_InflectionFooter`, `FrequencySection._buildFooter`, `SuttaInfoSection._buildFooter`, `FeedbackSection._date`.
- [ ] Task: Merge `_SmallAudioButton` into `DpdPlayButton`
    - [ ] Add `compact` parameter to `DpdPlayButton` (smaller icon, no shadow).
    - [ ] Remove `_SmallAudioButton` from `grammar_table.dart`.
    - [ ] Update `GrammarTable` IPA row to use `DpdPlayButton(compact: true)`.
- [ ] Task: Cache `parseFrequencyData()` result
    - [ ] Move parse call from `build()` to lazy-init pattern (like family/sutta data).
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Quick Wins' (Protocol in workflow.md)

## Phase 2: Entry Card State & Logic Unification

- [ ] Task: Simplify Expansion State Management
    - [ ] Create `Set<String> openSections` replacing individual booleans in `InlineEntryCard` (6 bools) and `AccordionCard` (4 bools).
    - [ ] Implement `toggleSection(String sectionId, bool oneButtonAtATime)` that clears set + adds new section.
- [ ] Task: Extract shared card logic into mixin/widget
    - [ ] Create `EntrySectionsManager` mixin (or similar) containing:
        - `openSections` state and `toggleSection()` method
        - `_loadSuttaInfo()` (currently triplicated)
        - Button row building logic
        - Section content rendering logic
    - [ ] Refactor `InlineEntryCard` to use the shared logic.
    - [ ] Refactor `AccordionCard` to use the shared logic.
- [ ] Task: Unify `EntryScreen` toggle paradigm
    - [ ] Replace `ExpansionTile` with `DpdSectionButton` in `EntryScreen`.
    - [ ] Integrate `EntryScreen` with `EntrySectionsManager`.
    - [ ] Add one-button-at-a-time support to `EntryScreen`.
    - [ ] Gate examples behind toggle (like cards) or document why always-visible is intentional.
- [ ] Task: Move `ref.listen` out of `build()` in both card widgets
    - [ ] Relocate settings listener setup to appropriate lifecycle method.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Card Unification' (Protocol in workflow.md)

## Phase 3: Table Consolidation

- [ ] Task: Consolidate Family Tables
    - [ ] Extract shared `FamilyEntryTable` widget from `_FamilyTable` in `family_table.dart`.
    - [ ] Remove `_FamilySubTable` from `multi_family_section.dart`.
    - [ ] Update `FamilyTableWidget` and `MultiFamilySection` to use `FamilyEntryTable`.
- [ ] Task: Centralize Key-Value Table Row Builders
    - [ ] Create shared row builder functions (`buildTextRow`, `buildLinkRow`, `buildHtmlRow`) in `entry_content.dart` or a new `dpd_table_builders.dart`.
    - [ ] Standardize cell padding with shared constant (currently 5.0/7.0/8.0/10.0 across widgets).
    - [ ] Refactor `GrammarTable` to use the shared builders.
    - [ ] Refactor `SuttaInfoSection` to use the shared builders.
    - [ ] Refactor `RootInfoTable` to use the shared builders.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Table Consolidation' (Protocol in workflow.md)

## Phase 4: Standardize Styling & Containers

- [ ] Task: Standardize `DpdSectionContainer` wrapping
    - [ ] Make `GrammarTable` self-wrap in `DpdSectionContainer`.
    - [ ] Make `InflectionSection` self-wrap.
    - [ ] Make `EntryExampleBlock` self-wrap.
    - [ ] Make `RootInfoTable` self-wrap.
    - [ ] Make `RootMatrixTable` self-wrap.
    - [ ] Remove redundant `DpdSectionContainer` wrapping from callers (`InlineEntryCard`, `AccordionCard`, `EntryScreen`, `InlineRootCard`).
- [ ] Task: Centralize Google Form URL generation in `DpdFooter`
    - [ ] Add `FeedbackType` enum.
    - [ ] Move date generation and URL building into `DpdFooter`.
    - [ ] Update all 7 call sites to use simplified `DpdFooter` constructor.
    - [ ] Standardize footer spacing (pick one value, e.g., `SizedBox(height: 12)`).
- [ ] Task: Standardize link styling
    - [ ] Replace all `InkWell` text-link wrappers with `GestureDetector` (or vice versa — pick one).
    - [ ] Remove underline from `SuttaInfoSection` links (or add it everywhere — pick one).
    - [ ] Replace `Colors.blue` in `GrammarTable` web link with `DpdColors.primaryText`.
- [ ] Task: Replace hardcoded font sizes with theme values
    - [ ] `FrequencyTable`: replace `fontSize: 11.2` and `12` with `bodySmall`.
    - [ ] `FeedbackSection`: replace `fontSize: 13` with `bodyMedium`.
    - [ ] `SuttaInfoSection` headings: replace `fontSize: 13` with `bodyMedium`.
- [ ] Task: Standardize `FrequencySection` heading
    - [ ] Replace custom `boldRegex` parsing with `Text.rich` using `TextSpan` children.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Styling & Containers' (Protocol in workflow.md)

## Phase 5: Minimize HTML Widget Usage

- [ ] Task: Audit all `Html()` widget usage
    - [ ] `GrammarTable`: assess which fields need `Html` vs. can use `Text.rich`.
    - [ ] `EntryExampleBlock`: assess whether examples contain complex HTML or just `<br>` + `<b>`.
    - [ ] `DpdHtmlTable`: assess if still used anywhere; remove if dead code.
- [ ] Task: Replace simple `Html()` calls with native widgets
    - [ ] Replace `Html` for simple bold/italic/linebreak content with `Text.rich`.
    - [ ] Keep `Html` only where database content has complex nested HTML, links, or tables.
- [ ] Task: Conductor - User Manual Verification 'Phase 5: HTML Minimization' (Protocol in workflow.md)
