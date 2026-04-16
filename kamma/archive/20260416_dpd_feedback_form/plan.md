# Plan: In-App DPD Feedback Form

## Phase 1: Infrastructure changes

- [x] 1.1 Fix FeedbackType.suttaInfo value
  File: `lib/widgets/feedback_type.dart`
  Change: `suttaInfo('Sutta Info')` -> `suttaInfo('Sutta')`
  -> verify: `grep -r 'Sutta Info' lib/` returns nothing

- [x] 1.2 Expand `buildMistakeUrl` to accept all form fields
  File: `lib/utils/feedback_urls.dart`
  Current signature:
  ```dart
  String buildMistakeUrl({String? word, int? headwordId, String? feedbackType})
  ```
  New signature — add optional params for every Google Form field:
  ```dart
  String buildMistakeUrl({
    String? word,
    int? headwordId,
    String? feedbackType,
    String? name,              // entry.485428648
    String? email,             // entry.781828361
    String? suggestion,        // entry.644913945
    String? canonicalSentence, // entry.852810955
    String? references,        // entry.1765697356
    String? feature,           // entry.1696159737
    String? better,            // entry.702723139
  })
  ```
  For each non-null, non-empty param, append `&entry.XXXXXX=Uri.encodeComponent(value)`
  to the URL. Keep existing headword/feedbackType/version logic unchanged.
  -> verify: read function, all 10 entry IDs present with correct mapping

- [x] 1.3 Create `buildMistakeEmailUri` in `lib/utils/feedback_urls.dart`
  ```dart
  Uri buildMistakeEmailUri({
    required String name,
    required String email,
    required String headword,
    required String section,
    required String suggestion,
    required String canonicalSentence,
    String references = '',
    String feature = '',
    String better = '',
    required String version,
  })
  ```
  - To: `digitalpalidictionary@gmail.com`
  - Subject: `DPD Feedback: $section` (or `DPD Feedback` if section empty)
  - Body: labeled lines matching the Google Form field order:
    ```
    Name: $name
    Email: $email
    Headword: $headword
    Section: $section
    Suggestion: $suggestion
    Canonical sentence: $canonicalSentence
    References: $references    (omit line if empty)
    Feature: $feature          (omit line if empty)
    Better: $better            (omit line if empty)
    Version: $version
    ```
  Return `Uri.parse('mailto:...')` same pattern as existing `buildFeedbackEmailUri`
  in `lib/utils/feedback_email_draft.dart`.
  -> verify: read function, produces mailto URI with correct structure

- [x] 1.4 Add DPD draft support to FeedbackDraftService
  File: `lib/services/feedback_draft_service.dart`

  Add a new class alongside existing `FeedbackDraft`:
  ```dart
  class DpdFeedbackDraft {
    const DpdFeedbackDraft({
      this.name = '',
      this.email = '',
      this.suggestion = '',
      this.canonicalSentence = '',
      this.references = '',
    });
    final String name, email, suggestion, canonicalSentence, references;
  }
  ```

  Add methods to `FeedbackDraftService`:
  ```dart
  DpdFeedbackDraft loadDpdDraft() {
    // name and email: read from SAME keys as existing load()
    // i.e. _contactKey.name and _contactKey.email
    // suggestion: _dpdDraftKey.suggestion
    // canonicalSentence: _dpdDraftKey.canonicalSentence
    // references: _dpdDraftKey.references
  }

  Future<void> saveDpdDraft(DpdFeedbackDraft draft) {
    // name and email: write to SAME _contactKey keys
    // transient fields: write to _dpdDraftKey prefix
  }

  Future<void> clearDpdTransientDraft() {
    // remove only _dpdDraftKey.* keys, NOT contact keys
  }
  ```

  Use `const _dpdDraftKey = 'dpd_feedback_draft';` as prefix for transient keys.
  The contact keys `_contactKey.name` and `_contactKey.email` are shared with the
  existing app feedback form — this is how "vice versa" works.
  -> verify: read file, contact keys shared, DPD transient keys separate

## Phase 2: In-app DPD feedback form sheet

- [x] 2.1 Create `lib/widgets/dpd_feedback_form_sheet.dart`

  **Public entry point:**
  ```dart
  Future<void> showDpdFeedbackSheet(
    BuildContext context, {
    String? headword,      // pre-filled from entry context
    int? headwordId,       // included in headword display as "ID headword"
    String? feedbackType,  // pre-selected dropdown value, null = unselected
  })
  ```
  Calls `showModalBottomSheet` with same shape/config as `feedback_form_sheet.dart`.

  **Private widget:** `_DpdFeedbackFormSheet` as `ConsumerStatefulWidget`.

  **Fields in order (matching Google Form exactly):**

  1. Name *
     `TextFormField`, required, `TextCapitalization.sentences`,
     `TextInputAction.next`, pre-filled from saved draft
     label: `"Name *"`
     validator: required

  2. Email Address *
     `TextFormField`, required, `TextInputType.emailAddress`,
     `TextInputAction.next`, pre-filled from saved draft
     label: `"Email Address *"`
     validator: required + regex `r'^[^@\s]+@[^@\s]+\.[^@\s]+$'`

  3. What is the headword? *
     `TextFormField`, required, `TextCapitalization.none`
     label: `"What is the headword? *"`
     helperText: `"Please check that the spelling is exactly the same as it currently appears."`
     pre-filled as: `headwordId != null ? '$headwordId $headword' : headword ?? ''`
     validator: required

  4. What section is the problem in? *
     `DropdownButtonFormField<String>`, required
     label: `"What section is the problem in? *"`
     items: Meaning, Sutta, Grammar, Examples, Root Family, Word Family,
            Compound Family, Idioms, Set, Frequency, Root Info, Root Matrix,
            Deconstructor, Other
     initialValue: from `feedbackType` param (null = unselected)
     validator: required

  5. What is your suggestion to correct it? *
     `TextFormField`, required, multiline (minLines: 3, maxLines: null),
     `TextCapitalization.sentences`
     label: `"What is your suggestion to correct it? *"`
     validator: required

  6. Canonical sentence *
     `TextFormField`, required, multiline (minLines: 3, maxLines: null),
     `TextCapitalization.sentences`
     label: `"Please provide a canonical sentence with the word in context. *"`
     helperText: `"Add n/a if not applicable."`
     validator: required

  7. References
     `TextFormField`, optional, multiline (minLines: 2, maxLines: null),
     `TextCapitalization.sentences`
     label: `"Can you provide reasons or reference from other sources?"`
     helperText: `"e.g. Pali texts, other dictionaries, grammar books etc."`

  8. Feature
     `TextFormField`, optional, `TextCapitalization.sentences`
     label: `"What feature of DPD is most useful to you?"`

  9. Better
     `TextFormField`, optional, `TextCapitalization.sentences`
     label: `"What would make DPD better for you?"`

  10. Version (read-only, not editable)
      `Text` widget at bottom, styled as caption/gray
      displays: `'Version: ${dpdAppLabel()}'`

  **Draft behavior (mirror existing form):**
  - `initState`: load name/email/suggestion/canonicalSentence/references from
    `ref.read(feedbackDraftServiceProvider).loadDpdDraft()`
  - Every field's `onChanged` calls `_saveDraft()` which writes via `saveDpdDraft()`
  - Headword controller pre-filled from constructor param, NOT from draft
  - Section dropdown pre-filled from constructor param, NOT from draft

  **Submit behavior (mirror `_FeedbackFormSheetState._submit()`):**
  1. Validate form
  2. Check connectivity: `Connectivity().checkConnectivity()`
  3. If online: call `buildMistakeUrl()` with ALL fields, `launchUrl()` with
     `LaunchMode.externalApplication`
  4. If offline: call `buildMistakeEmailUri()` with ALL fields, `launchUrl()`
  5. On success: `clearDpdTransientDraft()`, pop the sheet
  6. On failure: show error message in the form (same pattern as existing form)
  7. Show loading spinner on button during submit (same pattern)

  **UI structure (copy from `feedback_form_sheet.dart`):**
  - `Padding(bottom: viewInsets.bottom)` for keyboard
  - `DraggableScrollableSheet(initialChildSize: 0.9, min: 0.4, max: 0.95)`
  - Drag handle (Container 40x4, outlineVariant color, borderRadius 2)
  - Title row: `Text('DPD Feedback', style: titleLarge)` + close IconButton
  - Scrollable `Form` with `autovalidateMode: AutovalidateMode.onUserInteraction`
  - 12px `SizedBox` between fields
  - Error text + 48px `FilledButton` "Send" at bottom
  -> verify: read file, all 10 fields present with correct labels/helperText,
    draft load/save, connectivity check, online URL + offline email,
    matches feedback_form_sheet.dart structure

## Phase 3: Wire up existing links

- [x] 3.1 Update DpdFooter onTap
  File: `lib/widgets/entry_content.dart`

  In the `onTap` handler, change:
  ```dart
  // OLD:
  onTap: () async {
    await launchUrl(Uri.parse(_buildUrl()), mode: LaunchMode.platformDefault);
  }

  // NEW:
  onTap: () {
    if (customUrlBuilder != null) {
      launchUrl(Uri.parse(customUrlBuilder!()), mode: LaunchMode.platformDefault);
      return;
    }
    showDpdFeedbackSheet(
      context,
      headword: word,
      headwordId: headwordId,
      feedbackType: feedbackType?.value,
    );
  }
  ```

  Remove the `_buildUrl()` method — no longer needed. The `buildMistakeUrl` import
  can be removed from entry_content.dart. Add import for
  `'dpd_feedback_form_sheet.dart'`.

  DpdFooter's constructor and public API do NOT change. All 12+ existing call sites
  continue to work without modification.
  -> verify: read DpdFooter, confirm customUrlBuilder still launches URL directly,
    feedback links call showDpdFeedbackSheet, no constructor changes

- [x] 3.2 Update FeedbackSection "Correct a mistake"
  File: `lib/widgets/feedback_section.dart`

  Change the `_correctMistakeUrl` getter and its `_openUrl` call:
  ```dart
  // OLD:
  String get _correctMistakeUrl =>
      buildMistakeUrl(word: lemma1, headwordId: headwordId);
  // ... onTap: () => _openUrl(_correctMistakeUrl)

  // NEW:
  // onTap opens the in-app form with no feedbackType (user chooses section):
  onTap: () => showDpdFeedbackSheet(
    context,
    headword: lemma1,
    headwordId: headwordId,
  ),
  ```

  Remove the `_correctMistakeUrl` getter. Remove `buildMistakeUrl` import if no longer
  used (check if `buildAddWordUrl` is still used — yes it is, so keep the import).
  Add import for `dpd_feedback_form_sheet.dart`.
  -> verify: read file, "Correct a mistake" calls showDpdFeedbackSheet with no
    feedbackType, other links unchanged

- [x] 3.3 Update _DeconstructorFooter "suggest improvements"
  File: `lib/widgets/secondary/secondary_result_cards.dart`

  Only change the "suggest any improvements here" link's onTap. The "read the docs"
  and "add missing words" links stay unchanged.

  ```dart
  // OLD:
  final suggestUrl = buildMistakeUrl(
    word: Uri.decodeComponent(encodedHeadword),
    feedbackType: 'Deconstructor',
  );
  // ...
  onTap: () => launchUrl(Uri.parse(suggestUrl), mode: LaunchMode.platformDefault),

  // NEW:
  onTap: () => showDpdFeedbackSheet(
    context,
    headword: Uri.decodeComponent(encodedHeadword),
    feedbackType: 'Deconstructor',
  ),
  ```

  Remove `suggestUrl` variable. Add import for `dpd_feedback_form_sheet.dart`.
  Keep `buildMistakeUrl` import only if still used elsewhere in the file (check —
  it's not used elsewhere, but `buildAddWordUrl` is, so keep the `feedback_urls.dart`
  import).
  -> verify: read file, "suggest improvements" calls showDpdFeedbackSheet,
    other two links unchanged

- [x] 3.4 Route inflection footer to declension vs conjugation sheets
  File: `lib/widgets/inflection_section.dart`

  The inflection footer currently hardcodes `showDeclensionSheet()` for every
  headword. Update it to route using the existing headword inflection logic:

  - pass a boolean or label from `InflectionSection.build()` into `_InflectionFooter`
    based on `h.inflectionButtonLabel`
  - for conjugation headwords (verb POS such as `pr`, `aor`, `opt`, `imp`,
    `fut`, `imperf`, `cond`, `perf`) open `showConjugationSheet()`
  - for all other inflection headwords keep opening `showDeclensionSheet()`

  Keep the change narrow to footer routing only. Do not change table generation,
  history, or other inflection behavior.
  -> verify: read file, conjugation routes through `showConjugationSheet`,
    declension routes through `showDeclensionSheet`, using existing inflection
    label logic rather than a new duplicated POS source of truth

## Phase 4: Verify

- [x] 4.1 Run `flutter analyze` — no errors or warnings from changed files
  -> verify: `flutter analyze` output clean for all changed files

- [x] 4.2 Run `flutter analyze` for inflection routing follow-up
  Scope: `lib/widgets/inflection_section.dart`,
  `lib/widgets/conjugation_form_sheet.dart`
  -> verify: analyzer output clean for the updated footer wiring

- [x] 4.3 Refactor shared feedback-form helpers without changing behavior
  Files: `lib/widgets/*form_sheet.dart`, shared helper files as needed
  Scope:
  - extract duplicated feedback bottom-sheet shell and card widgets
  - extract repeated low-level URL assembly helpers
  - extract repeated low-level draft persistence helpers
  Constraint: no changes to field lists, routing, validation rules, submission
  payloads, or offline/online behavior
  -> verify: UI behavior remains unchanged; only internal helper structure moves

- [x] 4.4 Run `flutter analyze` after refactor cleanup
  Scope: all touched feedback-form files and shared helpers
  -> verify: analyzer output clean after behavior-preserving refactor
