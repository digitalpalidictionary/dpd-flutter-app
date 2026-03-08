# Track Specification: Internal Consistency Review & Refactoring

## Overview

Refactor the DPD Flutter app to improve internal coherency, specifically focusing on the expandable dictionary entry sections and state management across the app. This track addresses "WET" (Write Everything Twice) code and unifies UI behaviors, relying on the findings from the initial architectural review.

## Functional Requirements

1.  **Merge `AccordionCard` and `InlineEntryCard` Section Logic:**
    *   Extract the shared button row and conditionally rendered sections into a shared component (e.g., `EntrySectionsManager` or mixin).
    *   Eliminate duplicated layout and rendering logic for section buttons.

2.  **Simplify Expansion State Variables:**
    *   Replace individual booleans (`_grammarOpen`, `_suttaOpen`, etc.) with a single `Set<String> _openSections`.
    *   Refactor the `oneButtonAtATime` logic to simply clear the set and add the new section.

3.  **Centralize Table Row Builders:**
    *   Create a shared key-value table widget or generic row-building functions (e.g., `DpdTableRow.text`, `DpdTableRow.link`) in `entry_content.dart`.
    *   Refactor `GrammarTable` and `SuttaInfoSection` to use these centralized builders instead of custom implementations.

4.  **Consolidate Family Tables:**
    *   Delete duplicate family table implementations (`_FamilySubTable` and `_FamilyTable`).
    *   Create a single shared `FamilyEntryTable` widget and update `MultiFamilySection` and `FamilyTableWidget` to use it.

5.  **Centralize Footer URL Generation:**
    *   Move the Google Form URL generation logic into the `DpdFooter` widget itself.
    *   Pass context (like feedback type, headword ID, lemma) to the footer to generate the correct URL internally, removing date formatting and URL encoding from 7 different files.

6.  **Standardize HTML Parsing (Frequency Section):**
    *   Refactor `FrequencySection` to use the `Html()` widget for its heading, or create a lightweight `HtmlToTextSpan` utility, rather than using a custom `RegExp` to parse `<b>` tags.

7.  **Standardize Provider Architecture:**
    *   Refactor existing providers (e.g., Settings, History) to a simple, consistent, and reusable Riverpod pattern (e.g., `Notifier` or `StateNotifier` based on current usage, standardizing the approach).

## Non-Functional Requirements

*   Must not alter existing app feature functionality (this is purely an architectural refactoring).
*   Must follow the project's tech stack guidelines (Riverpod for state, Flutter for UI).

## Acceptance Criteria

*   [ ] `AccordionCard` and `InlineEntryCard` share a common widget/mixin for rendering their sections and buttons.
*   [ ] The 6 individual expansion booleans are replaced by a `Set<String>`.
*   [ ] `GrammarTable` and `SuttaInfoSection` share the same table row rendering logic.
*   [ ] `MultiFamilySection` and `FamilyTableWidget` use a single shared `FamilyEntryTable` implementation.
*   [ ] `DpdFooter` handles its own URL generation internally based on an enum/type.
*   [ ] `FrequencySection` heading relies on standardized HTML parsing.
*   [ ] Providers are audited and updated for consistent style/implementation.
*   [ ] App compiles and runs without errors.

## Out of Scope

*   Adding new features to the dictionary.
*   Modifying database schema or Drift code generation logic.
*   Major UI redesigns beyond consolidating existing patterns.