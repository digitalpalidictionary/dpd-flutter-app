# Plan: Audio Playback

## Phase 1 — Foundation [checkpoint: ]

- [x] Task: Add `just_audio` dependency via `flutter pub add just_audio` eb0b4af
- [ ] Task: Conductor - User Manual Verification 'Phase 1 — Foundation' (Protocol in workflow.md)

## Phase 2 — Audio Service [checkpoint: ]

- [x] Task: Write failing tests for `AudioService.buildUrl(lemma, gender)` (strips trailing digits, builds correct URL)
- [x] Task: Create `lib/services/audio_service.dart` — singleton `AudioService` with `play(lemma, gender)` method using `just_audio`, silent error handling 0355d0f
- [ ] Task: Conductor - User Manual Verification 'Phase 2 — Audio Service' (Protocol in workflow.md)

## Phase 3 — Settings Toggle [checkpoint: ]

- [x] Task: Enable the audio gender setting in `lib/widgets/settings_panel.dart` (remove `enabled: false`) 01e7e98
- [ ] Task: Conductor - User Manual Verification 'Phase 3 — Settings Toggle' (Protocol in workflow.md)

## Phase 4 — Main Play Button [checkpoint: ]

- [x] Task: Add main play button to entry button row in `lib/screens/entry_screen.dart` (or relevant widget) — visible only when any audio flag is true, plays with user's gender setting 81e2884
- [ ] Task: Conductor - User Manual Verification 'Phase 4 — Main Play Button' (Protocol in workflow.md)

## Phase 5 — IPA Audio Buttons [checkpoint: ]

- [x] Task: Add three small inline audio buttons to the IPA row in `lib/widgets/grammar_table.dart` — male1/male2/female, conditional on DB flags, each plays its fixed gender d23f270
- [ ] Task: Conductor - User Manual Verification 'Phase 5 — IPA Audio Buttons' (Protocol in workflow.md)
