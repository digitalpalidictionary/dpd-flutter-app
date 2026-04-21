## Thread
- **ID:** 20260421_app_feedback_styling
- **Objective:** Restyle the app feedback ("Report a Problem") sheet to match the DPD feedback card styling.

## Files Changed
- `lib/widgets/feedback_form_sheet.dart` — replaced plain labelText fields with `FeedbackQuestionCard` wrappers, switched to `showFeedbackBottomSheet`, added `_submitted` gating.

## Findings
No findings. Submit logic, draft service, online/offline branching, and validators are byte-identical to the prior version; only the visual shell changed.

## Fixes Applied
- None.

## Test Evidence
- `flutter analyze lib/widgets/feedback_form_sheet.dart` → No issues found.
- `flutter analyze` (project-wide) → pre-existing 109 issues, none in the changed file.
- User manual test on Android → confirmed.

## Verdict
PASSED
- Review date: 2026-04-21
- Reviewer: kamma (inline)
