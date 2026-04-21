# Plan

## Phase 1 — Restyle app feedback sheet

- [ ] Rewrite `_FeedbackFormSheet.build` in `lib/widgets/feedback_form_sheet.dart` to mirror the DPD form layout
  - Replace the direct `showModalBottomSheet` in `showFeedbackFormSheet` with a call to `showFeedbackBottomSheet`.
  - Add `FeedbackRequiredFieldLabel` at the top of the form column.
  - Wrap each of the 5 fields in a `FeedbackQuestionCard` with `required: true` for Name/Email/Issue/Description and `false` for Improvement.
  - Strip `labelText` from each input; use `InputDecoration(border: InputBorder.none)` (dropdown also clears enabled/focused/error borders).
  - Switch to `_submitted` gating + `autovalidateMode: _submitted ? always : disabled`, set `_submitted = true` at top of `_submit`.
  - Change outer scroll padding from (16,0,16,24) to (12,0,12,24).
  - Leave `_submit`, `_saveDraft`, controllers, dispose, and error-message UI unchanged.
  → verify: `flutter analyze` clean; only `feedback_form_sheet.dart` changed.

- [ ] Phase 1 verification
  → verify: project-wide `flutter analyze` clean; every field wrapped in `FeedbackQuestionCard`; no remaining `labelText` usage in the file.
