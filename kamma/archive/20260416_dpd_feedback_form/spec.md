# In-App DPD Feedback Form

## Overview
Every DPD dictionary feedback link in the app currently opens a Google Form URL directly
in the browser. Replace this with an in-app bottom sheet form (matching the existing
"Report a Problem" form UX), pre-filled from context and saved preferences. On submit:
open pre-filled Google Form (online) or send email (offline).

## Current behavior
- `DpdFooter` widget (`lib/widgets/entry_content.dart:181-255`) is a StatelessWidget
  used by ~12 sections. On tap it calls `buildMistakeUrl()` and launches the URL.
- `buildMistakeUrl()` (`lib/utils/feedback_urls.dart:1-23`) builds a Google Form URL
  pre-filling only: headword+ID (`entry.438735500`), section (`entry.326955045`),
  and version (`entry.1433863141` via `dpdAppLabel()`).
- `FeedbackSection` (`lib/widgets/feedback_section.dart:20-21`) has a "Correct a mistake"
  link that calls `buildMistakeUrl(word: lemma1, headwordId: headwordId)` with no
  feedbackType and launches the URL directly.
- `_DeconstructorFooter` (`lib/widgets/secondary/secondary_result_cards.dart:50-124`)
  builds its own custom footer with three links: "read the docs" (external), "suggest
  improvements" (calls `buildMistakeUrl` with feedbackType='Deconstructor'), and "add
  missing words" (`buildAddWordUrl()`). Only "suggest improvements" should change.

## New behavior
All three link types above open `showDpdFeedbackSheet()` — a bottom sheet form matching
the style of the existing `showFeedbackFormSheet()` in `lib/widgets/feedback_form_sheet.dart`.

## Reference: existing app feedback form (`lib/widgets/feedback_form_sheet.dart`)
This is the template to mirror. Key patterns:
- `showFeedbackFormSheet()` free function takes `BuildContext` and `dbVersion`
- Private `_FeedbackFormSheet` is a `ConsumerStatefulWidget`
- `initState` loads draft from `ref.read(feedbackDraftServiceProvider).load()`
- Each field calls `_saveDraft()` on `onChanged`
- `_submit()`: validates form, collects metadata, checks connectivity via
  `Connectivity().checkConnectivity()`, builds URL (online) or email URI (offline),
  calls `launchUrl()`, clears transient draft on success, pops sheet
- UI: `DraggableScrollableSheet` inside `Padding(bottom: viewInsets.bottom)`,
  drag handle, title row with close button, scrollable Form with fields, error text,
  FilledButton "Send"

## Google Form: entry ID mapping (source of truth)
```
entry.485428648  = Name *
entry.781828361  = Email Address *
entry.438735500  = Headword *
entry.326955045  = Section * (dropdown)
entry.644913945  = Suggestion to correct *
entry.852810955  = Canonical sentence *
entry.1765697356 = References (optional)
entry.1696159737 = Feature (optional)
entry.702723139  = Better (optional)
entry.1433863141 = Version (auto-filled, not user-editable)
```

## Section dropdown values (must match Google Form exactly)
Meaning, Sutta, Grammar, Examples, Root Family, Word Family, Compound Family,
Idioms, Set, Frequency, Root Info, Root Matrix, Deconstructor, Other

## FeedbackType enum fix
`lib/widgets/feedback_type.dart` — `suttaInfo('Sutta Info')` must become
`suttaInfo('Sutta')` to match the Google Form dropdown.

## Shared name/email ("vice versa")
Both feedback forms share the same SharedPreferences keys for name and email:
- `feedback_contact.name` (existing key in `FeedbackDraftService`)
- `feedback_contact.email` (existing key in `FeedbackDraftService`)

Enter name/email in the app feedback form -> it's pre-filled in the DPD form.
Enter name/email in the DPD form -> it's pre-filled in the app feedback form.
The existing `FeedbackDraftService` (`lib/services/feedback_draft_service.dart`)
already reads/writes these keys. The new form must use the same provider
(`feedbackDraftServiceProvider`) to read/write contact info.

## Offline email fallback
Same pattern as `lib/utils/feedback_email_draft.dart`:
- To: digitalpalidictionary@gmail.com
- Subject: "DPD Feedback: {section}" (or "DPD Feedback" if no section)
- Body: all fields as labeled lines (Name, Email, Headword, Section, Suggestion,
  Canonical sentence, References, Feature, Better, Version)

## What's NOT included
- Inflection footer (separate form, deferred)
- GrammarDictCard / VariantCard footers (link to docs, not feedback)
- "Add a missing word" form (different Google Form)
- "read the docs" link in Deconstructor footer (stays as external URL)
- "add missing words" link in Deconstructor footer (stays as external URL)
- Changes to the existing app feedback form (`feedback_form_sheet.dart`)
