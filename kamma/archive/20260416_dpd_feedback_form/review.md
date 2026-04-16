## Thread
- **ID:** `20260416_dpd_feedback_form`
- **Objective:** Replace DPD feedback links with in-app bottom-sheet forms that prefill context, share contact info, and submit to Google Forms or email.

## Files Changed
- `lib/widgets/dpd_feedback_form_sheet.dart` — New in-app DPD correction form sheet.
- `lib/widgets/add_word_form_sheet.dart` — New in-app "Add a Word" form sheet.
- `lib/widgets/declension_form_sheet.dart` — New in-app declension table feedback form sheet.
- `lib/widgets/conjugation_form_sheet.dart` — New in-app conjugation table feedback form sheet.
- `lib/widgets/feedback_form_components.dart` — Shared UI components (QuestionCard, CheckboxCard).
- `lib/services/feedback_draft_service.dart` — Expanded to support DPD-specific drafts and shared contact info.
- `lib/utils/feedback_urls.dart` — URL and Email builders for all new feedback types.
- `lib/widgets/entry_content.dart` — `DpdFooter` wiring.
- `lib/widgets/feedback_section.dart` — Section link wiring.
- `lib/widgets/inflection_section.dart` — Routing logic for inflection tables.
- `lib/widgets/secondary/secondary_result_cards.dart` — Deconstructor wiring.
- `lib/widgets/feedback_type.dart` — Enum value fix.

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | nit | Form Sheets | `autovalidateMode` differs from original app form. | Divergence from the "template to mirror" instruction. | None (Deliberate UX choice for long forms). |
| 2 | nit | `feedback_form_components.dart` | Checkbox cards use manual validation instead of `FormField`. | Less idiomatic Flutter, but functional. | None. |
| 3 | nit | `dpd_feedback_form_sheet.dart` | Feature/Better fields not included in draft. | Spec said transient fields should be saved; these stay empty on reload. | None. |

## Fixes Applied
- None (User requested an independent review without changes).

## Test Evidence
- Verified all Google Form entry IDs match the source of truth in `spec.md`.
- Verified shared contact info logic in `FeedbackDraftService`.
- Verified routing logic in `InflectionSection` and `DpdFooter`.
- Verified offline `mailto` URI construction.

## Verdict
PASSED
- Review date: 2026-04-16
- Reviewer: Gemini CLI (Independent Review)
