# Implementation Plan: Internal Consistency Review & Refactoring

## Phase 1: Quick Wins (Trivial Deduplication)

- [x] Task: Extract `dpdDateStamp()` utility
    - [x] Create utility function in `lib/utils/` returning `yyyy-MM-dd` string.
    - [x] Replace 5 duplicate date constructions: `EntryExampleFooter`, `_InflectionFooter`, `FrequencySection._buildFooter`, `SuttaInfoSection._buildFooter`, `FeedbackSection._date`.
- [x] Task: Merge `_SmallAudioButton` into `DpdPlayButton`
    - [x] Add `compact` parameter to `DpdPlayButton` (smaller icon, no shadow).
    - [x] Remove `_SmallAudioButton` from `grammar_table.dart`.
    - [x] Update `GrammarTable` IPA row to use `DpdPlayButton(compact: true)`.
- [x] Task: Cache `parseFrequencyData()` result
    - [x] Move parse call from `build()` to lazy-init pattern (like family/sutta data).
- [x] Task: Conductor - User Manual Verification 'Phase 1: Quick Wins' (Protocol in workflow.md)

## Phase 2: Entry Card State & Logic Unification [checkpoint: 47fb2f2]

- [x] Task: Simplify Expansion State Management (49a18f9)
    - [x] Create `Set<String> openSections` replacing individual booleans in `InlineEntryCard` (6 bools) and `AccordionCard` (4 bools).
    - [x] Implement `toggleSection(String sectionId, bool oneButtonAtATime)` that clears set + adds new section.
- [x] Task: Extract shared card logic into mixin/widget (49a18f9)
    - [x] Create `EntrySectionsManager` mixin (or similar) containing:
        - `openSections` state and `toggleSection()` method
        - `_loadSuttaInfo()` (currently triplicated)
        - Button row building logic
        - Section content rendering logic
    - [x] Refactor `InlineEntryCard` to use the shared logic.
    - [x] Refactor `AccordionCard` to use the shared logic.
- [x] Task: Unify `EntryScreen` toggle paradigm (49a18f9)
    - [x] Replace `ExpansionTile` with `DpdSectionButton` in `EntryScreen`.
    - [x] Integrate `EntryScreen` with `EntrySectionsManager`.
    - [x] Add one-button-at-a-time support to `EntryScreen`.
    - [x] Gate examples behind toggle (like cards) or document why always-visible is intentional.
- [x] Task: Move `ref.listen` out of `build()` in both card widgets (49a18f9)
    - [x] Relocate settings listener setup to appropriate lifecycle method.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Card Unification' (Protocol in workflow.md)

## Phase 3: Table Consolidation [checkpoint: 7e60f3c]

- [x] Task: Consolidate Family Tables (0f3a624)
    - [x] Extract shared `FamilyEntryTable` widget from `_FamilyTable` in `family_table.dart`.
    - [x] Remove `_FamilySubTable` from `multi_family_section.dart`.
    - [x] Update `FamilyTableWidget` and `MultiFamilySection` to use `FamilyEntryTable`.
- [x] Task: Centralize Key-Value Table Row Builders (9f16259)
    - [x] Create shared row builder functions (`buildTextRow`, `buildLinkRow`, `buildHtmlRow`) in `entry_content.dart` or a new `dpd_table_builders.dart`.
    - [x] Standardize cell padding with shared constant (currently 5.0/7.0/8.0/10.0 across widgets).
    - [x] Refactor `GrammarTable` to use the shared builders.
    - [x] Refactor `SuttaInfoSection` to use the shared builders.
    - [x] Refactor `RootInfoTable` to use the shared builders.
- [x] Task: Conductor - User Manual Verification 'Phase 3: Table Consolidation' (Protocol in workflow.md)

## Phase 4: Standardize Styling & Containers

- [x] Task: Standardize `DpdSectionContainer` wrapping [6c20c3e]
    - [x] Make `GrammarTable` self-wrap in `DpdSectionContainer`.
    - [x] Make `InflectionSection` self-wrap.
    - [x] Make `EntryExampleBlock` self-wrap.
    - [x] Make `RootInfoTable` self-wrap.
    - [x] Make `RootMatrixTable` self-wrap.
    - [x] Remove redundant `DpdSectionContainer` wrapping from callers (`InlineEntryCard`, `AccordionCard`, `EntryScreen`, `InlineRootCard`).
- [x] Task: Centralize Google Form URL generation in `DpdFooter` [37b8c15]
    - [x] Add `FeedbackType` enum.
    - [x] Move date generation and URL building into `DpdFooter`.
    - [x] Update all 7 call sites to use simplified `DpdFooter` constructor.
    - [x] Standardize footer spacing (pick one value, e.g., `SizedBox(height: 12)`).
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
