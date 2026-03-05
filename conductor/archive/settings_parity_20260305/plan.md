# Plan: Settings Parity

## Phase 1: Settings Model & Persistence Foundation
- [x] Task: Add new fields to Settings model (oneButtonAtATime, niggahitaMode, showSummary, showSandhiApostrophe, audioGender) [43f0bac]
  - [x] Write tests for Settings copyWith and equality with new fields
  - [x] Add fields to Settings class with defaults
  - [x] Add SharedPreferences load/save methods to SettingsNotifier
  - [x] Run tests and confirm pass
- [x] Task: Build settings UI as both bottom sheet and side drawer prototypes [4cd4226]
  - [x] Create a settings content widget (shared between both variants) with all toggles
  - [x] Implement bottom sheet variant triggered from app bar icon
  - [x] Implement side drawer variant triggered from app bar icon
  - [x] Add a temporary dev toggle to switch between the two variants for user testing
  - [x] Include all existing settings (theme, font size, font style, grammar/examples, display mode) plus new toggles
  - [x] Remove/retire the old separate settings screen

## Phase 2: One-Button-At-A-Time Mode
- [x] Task: Implement one-button-at-a-time logic [46575ee]
  - [x] Study existing roots section one-button behavior as reference
  - [x] Implement section state management that respects the setting
  - [x] Apply to all three display modes (Webapp/Accordion/Sheet)

## Phase 3: Niggahīta Display Toggle
- [x] Task: Implement ṃ ↔ ṁ substitution [2e4c17a]
  - [x] Write tests for niggahīta substitution utility (ṃ→ṁ and identity when ṃ selected)
  - [x] Implement substitution utility function
  - [x] Apply to headwords and search results (WordCard, card headers)
  - [x] Apply to summary, grammar, examples (EntrySummaryBox, GrammarTable, EntryExampleBlock)

## Phase 4: Sandhi Apostrophe Visibility Toggle
- [x] Task: Implement sandhi apostrophe hide/show [a5f903e]
  - [x] Write tests for apostrophe removal utility function (in text_filters_test.dart)
  - [x] Implement apostrophe removal utility (filterApostrophe in text_filters.dart)
  - [x] Applied to EntrySummaryBox, GrammarTable, EntryExampleBlock
- [x] Task: Apply apostrophe toggle throughout entry content [e080596]
  - [x] Applied to GrammarTable and EntryExampleBlock

## Phase 5: Wire Up Font Size
- [x] Task: Apply fontSize setting to entry content [4cd4226]
  - [x] Implemented app-wide via MediaQuery.textScaler in MaterialApp.builder (fontSize / 16.0)

## Phase 6: Final Verification
- [x] Task: Conductor - User Manual Verification 'Settings Parity'
  - [x] User chose bottom sheet variant (55% fixed height, scrollable content)
  - [x] Font size slider divisions fixed to 12 (steps of 1 over range 12–24)
  - [x] one-button-at-a-time family→family bug fixed (familyResetAll in hook)
  - [x] All tests pass (130), flutter analyze clean (2 pre-existing warnings only)
