# Track Specification: Internal Consistency Review & Refactoring

## Overview

Refactor the DPD Flutter app to improve internal coherency across the three entry rendering contexts (InlineEntryCard, AccordionCard, EntryScreen) and all expandable dictionary sections. This track addresses duplicated code, inconsistent styling, divergent toggle paradigms, and fragmented text/link rendering patterns identified in the architectural review.

## Functional Requirements

1.  **Quick Wins — Eliminate Trivial Duplication:**
    *   Extract a `dpdDateStamp()` utility to replace 5 identical date-formatting blocks.
    *   Merge `_SmallAudioButton` into `DpdPlayButton` with a `compact` parameter, eliminating the duplicated state machine.
    *   Cache `parseFrequencyData()` result (lazy-init pattern) instead of parsing on every `build()`.

2.  **Unify Entry Card State & Logic (All Three Contexts):**
    *   Replace individual boolean flags (`_grammarOpen`, `_suttaOpen`, etc.) with a single `Set<String> openSections`.
    *   Extract shared section-toggle logic, button row rendering, and section rendering into a shared mixin or widget (e.g., `EntrySectionsManager`).
    *   The shared logic must serve `InlineEntryCard`, `AccordionCard`, **and** `EntryScreen` — not just the two card widgets.
    *   Replace `ExpansionTile` in `EntryScreen` with `DpdSectionButton` to unify the toggle paradigm.
    *   Extract `_loadSuttaInfo()` into the shared mixin (currently triplicated in all three files).
    *   Document intentional differences between display contexts (e.g., compact mode omitting frequency/feedback) or eliminate them.

3.  **Consolidate Tables:**
    *   Delete `_FamilySubTable` from `multi_family_section.dart` and replace with a single shared `FamilyEntryTable` widget used by both `FamilyTableWidget` and `MultiFamilySection`.
    *   Create shared key-value table row builders (`buildTextRow`, `buildLinkRow`, etc.) or a `DpdKeyValueTable` widget. Refactor `GrammarTable`, `SuttaInfoSection`, and `RootInfoTable` to use them.

4.  **Standardize Container Wrapping:**
    *   All section widgets must self-wrap in `DpdSectionContainer` internally. Callers should never need to know whether a section self-wraps or not.
    *   Currently self-wrapping: FamilyTable, MultiFamilySection, FrequencySection, FeedbackSection, SuttaInfoSection.
    *   Must be updated to self-wrap: GrammarTable, InflectionSection, EntryExampleBlock, RootInfoTable, RootMatrixTable.

5.  **Standardize Footer & URL Generation:**
    *   Move Google Form URL generation into `DpdFooter` using a `FeedbackType` enum.
    *   Pass context (headword ID, lemma, feedback type) to `DpdFooter` — eliminate URL construction from 7 call sites.
    *   Standardize footer spacing (currently varies: 16px, 12px, 4px before footer).

6.  **Standardize Text, Link & Style Rendering:**
    *   All links must use the same tap widget (`GestureDetector`) and consistent decoration (no underline, `DpdColors.primaryText`). Fix GrammarTable web link using `Colors.blue`.
    *   Replace hardcoded font sizes with theme-derived values: `FrequencyTable` (11.2, 12), `FeedbackSection` (13), `SuttaInfoSection` headings (13).
    *   Replace the custom regex `<b>` parser in `FrequencySection` with `Text.rich`.
    *   Standardize table cell right-padding with a shared constant.

7.  **Minimize HTML Widget Usage:**
    *   Audit all `Html()` widget usage. Replace with native `Text.rich`/`RichText` wherever the HTML content is simple (bold, italic, line breaks).
    *   Keep `Html()` only where the database content contains complex HTML (nested tags, links, tables).
    *   Goal: reduce flutter_html dependency footprint, improve rendering performance.

8.  **Fix Riverpod Antipatterns:**
    *   Move `ref.listen` out of `build()` in both card widgets.

## Non-Functional Requirements

*   Must not alter existing app feature functionality (purely architectural refactoring).
*   Must follow project tech stack guidelines (Riverpod, Drift, Flutter).
*   Each phase must pass manual verification before proceeding.

## Acceptance Criteria

*   [ ] `AccordionCard`, `InlineEntryCard`, and `EntryScreen` share a common mixin/widget for rendering sections and buttons.
*   [ ] `EntryScreen` uses `DpdSectionButton` instead of `ExpansionTile`.
*   [ ] Individual expansion booleans replaced by `Set<String> openSections` in all three contexts.
*   [ ] `_loadSuttaInfo()` exists in exactly one place (shared mixin).
*   [ ] `_SmallAudioButton` removed; `DpdPlayButton` handles both sizes.
*   [ ] Date formatting exists in exactly one utility function.
*   [ ] All section widgets self-wrap in `DpdSectionContainer`.
*   [ ] `GrammarTable` and `SuttaInfoSection` share table row rendering logic.
*   [ ] `MultiFamilySection` and `FamilyTableWidget` use a single shared table widget.
*   [ ] `DpdFooter` handles its own URL generation internally via `FeedbackType` enum.
*   [ ] All links use consistent color, decoration, and tap widget.
*   [ ] No hardcoded font sizes — all derived from theme.
*   [ ] `FrequencySection` heading uses `Text.rich` instead of regex parser.
*   [ ] `Html()` usage minimized to only complex HTML content.
*   [ ] `parseFrequencyData()` cached (not called in `build()`).
*   [ ] `ref.listen` not inside `build()`.
*   [ ] App compiles and runs without errors.

## Out of Scope

*   Adding new features to the dictionary.
*   Modifying database schema or Drift code generation.
*   Major UI redesigns beyond consolidating existing patterns.
*   Performance optimization for large family tables (separate track — see `todo.md`).
*   Feature parity between classic/compact modes (requires separate product decision).
