# Spec: Settings Parity

## Overview

Bring the Flutter app's settings into parity with the DPD webapp settings panel. Each setting is added to the `Settings` model, persisted via `SharedPreferences`, exposed in the Settings screen UI, and integrated into the app where applicable. Some settings (summary visibility, audio gender) will have the setting and UI created now but actual integration deferred to later tracks.

## Functional Requirements

### FR-1: One-Button-At-A-Time Mode
- Add a boolean setting `oneButtonAtATime` (default: ON).
- When ON, opening a section button closes any other open section (same behavior as the existing roots section).
- When OFF, multiple sections can be open simultaneously.
- Applies across all three display modes (Webapp/Accordion/Sheet).

### FR-2: Niggahīta Display Toggle
- Add a setting to choose between ṃ and ṁ (default: ṃ).
- When set to ṁ, all occurrences of ṃ in displayed text are substituted with ṁ.
- Substitution applies everywhere: headwords, summaries, grammar, examples, family tables, search results.

### FR-3: Entry Summary Visibility Toggle
- Add a boolean setting `showSummary` (default: Show).
- UI toggle added to Settings screen.
- **Integration deferred** — the setting is stored and exposed but not yet wired into entry display.

### FR-4: Sandhi Apostrophe Visibility Toggle
- Add a boolean setting `showSandhiApostrophe` (default: Show).
- When Hide is selected, apostrophes in sandhi constructions are hidden from displayed text.
- Applies to all displayed entry content.

### FR-5: Audio Gender Toggle
- Add a setting for audio gender: Male / Female (default: Male).
- UI toggle added to Settings screen.
- **Integration deferred** — the setting is stored and exposed but not yet wired into audio playback (audio feature does not exist yet).

### FR-6: Wire Up Font Size
- The `fontSize` setting already exists in the model and is persisted, but no widget consumes it.
- Apply `fontSize` to scale text throughout entry content display.

## Settings UI Redesign
- Replace the current separate Settings screen with an in-context overlay so users can see settings changes live on the current entry.
- Implement **two prototype variants** for user evaluation:
  - **Bottom sheet** — slides up from bottom, entry content visible above.
  - **Side drawer** — slides in from the right, like the webapp side panel.
- User will choose the preferred variant during final verification; the other will be removed.
- Both variants contain all settings: theme, font size, font style, grammar/examples open, display mode, plus all new toggles.
- Use `SwitchListTile` for boolean toggles (one-button, summary, sandhi apostrophe).
- Use `SegmentedButton` or equivalent for choice toggles (niggahīta ṃ/ṁ, audio male/female).
- The existing settings icon in the app bar triggers the overlay instead of navigating to a separate page.

## Default Values

| Setting | Default |
|---|---|
| One-button-at-a-time | ON |
| Niggahīta | ṃ |
| Summary | Show |
| Sandhi apostrophe | Show |
| Audio gender | Male |
| Font size | 16 (existing) |

## Acceptance Criteria
- All 5 new settings persist across app restarts via SharedPreferences.
- One-button-at-a-time correctly enforces single-section behavior when ON, and allows multi-section when OFF.
- Niggahīta toggle substitutes ṃ ↔ ṁ in all displayed text.
- Sandhi apostrophe toggle hides/shows apostrophes in entry content.
- Font size setting scales entry text.
- Summary and audio gender toggles exist in UI and persist, ready for future wiring.
- Settings screen shows all new toggles with clear labels.

## Out of Scope
- Audio playback implementation (audio gender toggle is UI-only for now).
- Summary box show/hide rendering logic (toggle is UI-only for now).
- Changes to search/transliteration logic.
- Dark mode or theme changes.
