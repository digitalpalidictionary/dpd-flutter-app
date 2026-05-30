## Architecture Decisions
- Single file change: `lib/theme/schemes/suriya.dart`, `suriyaDark` object only
- No new files, no abstractions — direct HSL value edits

## Phase 1 — Update suriyaDark values

- [x] Update background colours
  - `dark`:      HSL(38, 20%, 9%)  → HSL(38, 45%, 7%)
  - `darkShade`: HSL(38, 20%, 13%) → HSL(38, 40%, 11%)
  → verify: values compile, `flutter analyze` passes ✓

- [x] Update body text colours
  - `light`:      HSL(40, 15%, 87%) → HSL(44, 60%, 88%)
  - `lightShade`: HSL(38, 12%, 78%) → HSL(44, 50%, 78%)
  → verify: values compile, `flutter analyze` passes ✓

- [x] Update primary highlight
  - `primary`:         HSL(42, 65%, 52%) → HSL(45, 82%, 60%)
  - `primaryText`:     HSL(42, 70%, 62%) → HSL(45, 82%, 68%)
  - `primaryTextDark`: HSL(42, 70%, 62%) → HSL(45, 82%, 68%)
  → verify: values compile, `flutter analyze` passes ✓

- [x] Update deep accent
  - `primaryAlt`: HSL(40, 60%, 36%) → HSL(45, 82%, 30%)
  → verify: values compile, `flutter analyze` passes ✓

- [x] Run `flutter analyze` on the file
  → verify: no errors or warnings ✓ (No issues found)
