# Spec: Unify app feedback form with DPD feedback styling

## Overview
The "Report a Problem" app feedback bottom sheet (`lib/widgets/feedback_form_sheet.dart`) uses a plain Material labelText/TextFormField layout while every other feedback form in the app (DPD mistake, declension, conjugation, add-word) uses the bordered `FeedbackQuestionCard` pattern from `lib/widgets/feedback_form_components.dart`. The app feedback form should be restyled to match.

## What it should do
- The "Report a Problem" bottom sheet should look and behave like the DPD feedback sheet:
  - Use `showFeedbackBottomSheet` instead of a bespoke `showModalBottomSheet` call.
  - Show a "* Required field" label at the top via `FeedbackRequiredFieldLabel`.
  - Wrap every field (Name, Email, Issue type, Description, Improvement) in a `FeedbackQuestionCard` with the question as the card title and `required` flags matching current validation.
  - Use `TextFormField(decoration: InputDecoration(border: InputBorder.none))` and dropdown with no border chrome.
  - Use `autovalidateMode: AutovalidateMode.disabled` until first submit.
  - Keep the header row ("Report a Problem" + close button) and the grab handle.
  - Keep existing submit logic, draft-save logic, error display, and online/offline branching untouched.

## Assumptions & uncertainties
- Exact parity with the DPD card style (primary-colored questions, `outlineVariant` borders).
- All five existing fields become cards; no copy or field-set changes.
- No visible Version card (app feedback sends metadata via `collectFeedbackMetadata`).

## Constraints
- Preserve submit/draft behavior exactly.
- Use theme colors via the shared components; no hardcoded colors.
- No new dependencies.

## How we'll know it's done
- Opening "Report a Problem" shows the same card-bordered visual style as the DPD feedback sheet.
- Submit still opens URL online / mailto offline; drafts still persist.
- `flutter analyze` clean.

## What's not included
- Changing validation rules, submission URLs, or metadata payload.
- Re-wording any labels or adding/removing fields.
- Refactor of `feedback_form_components.dart`.
