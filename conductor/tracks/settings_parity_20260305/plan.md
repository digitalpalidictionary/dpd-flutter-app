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
- [ ] Task: Implement one-button-at-a-time logic
  - [ ] Study existing roots section one-button behavior as reference
  - [ ] Write tests for section toggle state management (opening one closes others when ON, independent when OFF)
  - [ ] Implement section state management that respects the setting
  - [ ] Apply to all three display modes (Webapp/Accordion/Sheet)
  - [ ] Run tests and confirm pass

## Phase 3: Niggahīta Display Toggle
- [ ] Task: Implement ṃ ↔ ṁ substitution
  - [ ] Write tests for niggahīta substitution utility (ṃ→ṁ and identity when ṃ selected)
  - [ ] Implement substitution utility function
  - [ ] Run tests and confirm pass
- [ ] Task: Apply niggahīta substitution throughout the app
  - [ ] Apply to headwords and search results
  - [ ] Apply to summary, grammar, examples, family tables
  - [ ] Verify substitution works everywhere and responds to setting changes

## Phase 4: Sandhi Apostrophe Visibility Toggle
- [ ] Task: Implement sandhi apostrophe hide/show
  - [ ] Write tests for apostrophe removal utility function
  - [ ] Implement apostrophe removal utility
  - [ ] Run tests and confirm pass
- [ ] Task: Apply apostrophe toggle throughout entry content
  - [ ] Identify all locations where sandhi apostrophes appear in displayed text
  - [ ] Apply conditional apostrophe hiding based on setting
  - [ ] Verify toggle works across all entry sections

## Phase 5: Wire Up Font Size
- [ ] Task: Apply fontSize setting to entry content
  - [ ] Identify all text widgets in entry display that should scale
  - [ ] Apply fontSize from settings as text scale factor or direct font size
  - [ ] Verify font size slider visually scales entry text

## Phase 6: Final Verification
- [ ] Task: Conductor - User Manual Verification 'Settings Parity' (Protocol in workflow.md)
  - [ ] User chooses between bottom sheet and side drawer — remove the unchosen variant
