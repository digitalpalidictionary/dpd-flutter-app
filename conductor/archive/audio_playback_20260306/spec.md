# Spec: Audio Playback

## Overview
Add audio playback to the DPD Flutter app. Two surfaces: (1) a main play button
in the entry button row that plays audio based on the user's gender preference,
and (2) three small audio buttons in the IPA row of the grammar table (male1,
male2, female) that play directly regardless of settings.

## Audio URL
`https://dpdict.net/audio/{lemma_clean}?gender={gender}`
- `lemma_clean` = lemma_1 with trailing digits stripped (e.g. "dhamma 1" → "dhamma")
- `gender` values: `male`, `female`, `male1`, `male2`, `female1`

## Functional Requirements

### FR1 — Audio Dependency
- Add `just_audio` package for HTTP audio streaming.

### FR2 — Main Play Button
- Position: first button in the entry button row (before existing section buttons).
- Always shown for every headword.
- Behaviour: fetches and plays audio at URL with gender = user's audio setting
  (`male` or `female`).
- On error (404 / network fail): button grays out.
- Style: same `DpdSectionButton` style as other buttons.

### FR4 — Settings Audio Toggle
- Enable the existing (currently disabled) audio gender setting in Settings.
- Values: `male` (default) | `female`.
- Persisted via `shared_preferences`.

### FR5 — IPA Audio Buttons
- Location: inside the grammar table IPA row, after the IPA text.
- Always show all three buttons: `male1`, `male2`, `female`.
- Each button plays audio with its fixed gender regardless of user setting.
- On error (404 / network fail): that button grays out.
- Style: small play icon buttons (distinct from full-size section buttons),
  matching webapp `.dpd-button.play.small` visual — compact, inline.

### FR6 — Audio Service
- Shared `AudioService` (singleton/provider) wrapping `just_audio`.
- Exposes `play(lemma, gender)` method.
- Handles errors silently (no crash on network failure).

## Out of Scope
- Offline/cached audio files.
- Audio waveform / progress display.
- Volume controls.
