# Plan: Offline Feedback Submission

## Goal
Implement a native in-app feedback form that hands off to a prefilled Google Form when online and a prefilled email draft when offline, while always remembering name and email and preserving the unsent draft until handoff succeeds.

## Execution Context
- Read `kamma/threads/20260409_offline_feedback_submission/spec.md` first.
- Follow `kamma/workflow.md` while executing tasks.
- The current browser-launching flow lives in `lib/widgets/feedback_footer.dart` and uses `lib/utils/app_feedback_url.dart`.
- Metadata collection already exists in `lib/utils/app_feedback_url.dart` via `device_info_plus` and `package_info_plus`.
- Local app state already uses `SharedPreferences`; see `lib/providers/history_provider.dart` for the JSON persistence pattern.
- The footer currently reads the local DB version from `dbUpdateProvider.localVersion` in `lib/providers/database_update_provider.dart`.
- `FeedbackFooter` is currently used from `lib/screens/search_screen.dart`, `lib/screens/root_screen.dart`, and `lib/screens/entry_screen.dart`, so the replacement should preserve behavior across all three entry points.
- This thread explicitly excludes direct Google Forms POST submission, offline queueing, reconnect listeners, and background retries.

## Phase 1: Confirm Current Integration Points

### Task 1.1: Verify the current footer entry point
- [x] Read `lib/widgets/feedback_footer.dart`.
- [x] Confirm the tap handler currently calls `buildFeedbackUrl()` and `launchUrl()`.
- [x] Confirm how `dbVersion` is obtained so the same value can be passed into the new form flow.

### Task 1.2: Verify metadata and launch helpers
- [x] Read `lib/utils/app_feedback_url.dart`.
- [x] Identify which parts can be reused for shared metadata collection.
- [x] Confirm whether the current Google Form prefill helper already covers all required fields or only metadata.
- [x] Note that extending the current Google Form URL helper changes the existing `FeedbackFooter` caller contract; avoid landing that helper change before the footer handoff is updated in the same implementation slice.
- [x] Read the existing `mailto:` usage in `lib/widgets/feedback_section.dart` to match the established launch pattern.

### Task 1.3: Verify local persistence pattern
- [x] Read `lib/providers/history_provider.dart` for the existing `SharedPreferences` JSON persistence pattern.
- [x] Read the `sharedPreferencesProvider` injection pattern in `lib/providers/settings_provider.dart`.
- [x] Decide on the simplest storage layout for:
  - remembered contact fields: `name`, `email`
  - transient draft fields: `issueType`, `description`, `improvement`
- [x] Prefer one small service over multiple providers unless the codebase clearly needs more separation.

## Phase 2: Add Draft Persistence and Payload Builders

### Task 2.1: Create a feedback draft persistence service
- [x] Create `lib/services/feedback_draft_service.dart`.
- [x] Inject `SharedPreferences` into the service via the existing `sharedPreferencesProvider` pattern instead of calling `SharedPreferences.getInstance()` directly.
- [x] Persist and restore:
  - always-remembered `name`
  - always-remembered `email`
  - transient `issueType`
  - transient `description`
  - transient `improvement`
- [x] Implement methods to:
  - load the current draft state
  - save the current draft state
  - clear only the transient draft fields after successful handoff
- [x] Use `SharedPreferences` and defensive JSON parsing.

### Task 2.2: Add tests for draft persistence
- [x] Create `test/services/feedback_draft_service_test.dart`.
- [x] Cover loading empty state.
- [x] Cover saving and restoring all fields.
- [x] Cover clearing only transient fields while preserving name and email.
- [x] Cover malformed JSON recovery.

### Task 2.3: Refactor metadata collection into a shared helper
- [x] Update `lib/utils/app_feedback_url.dart` to expose a reusable metadata object/helper.
- [x] Keep the current prefilled Google Form builder working while extracting the shared metadata helper first.
- [x] Defer extending the Google Form URL builder to include user-entered fields until the footer handoff is replaced in the same task, so the existing caller never lands in a broken intermediate state.
- [x] Ensure the helper still supports the current DB version source.

### Task 2.4: Add an email draft builder
- [x] Create a small helper such as `lib/utils/feedback_email_draft.dart`.
- [x] Build a `mailto:` URI with `Uri(scheme: 'mailto', path: 'digitalpalidictionary@gmail.com', queryParameters: ...)` so subject/body encoding is handled correctly by Dart.
- [x] Include:
  - a clear subject containing the issue type
  - a plain-text body using headings and answers
  - the same full payload used for the online Google Form handoff
- [x] Use the issue type text verbatim from the allowed values in the spec.

### Task 2.5: Add tests for payload builders
- [x] Create or extend tests under `test/utils/`.
- [x] Verify the prefilled Google Form URL contains all required Google Form entry IDs.
- [x] Verify the email draft builder includes all headings and values.
- [x] Verify optional fields do not break URL/body generation when empty.

### Task 2.6: Run automated verification for persistence and payload helpers
- [x] Run the new draft-service and payload-builder tests.
- [x] Fix any failures before moving on to the UI phase.

## Phase 3: Build the In-App Feedback Form UI

### Task 3.1: Create the form widget
- [x] Create `lib/widgets/feedback_form_sheet.dart`.
- [x] Match the app's existing visual patterns and theme usage.
- [x] Include fields for:
  - required name
  - required email address
  - required issue type choice
  - required multi-line description
  - optional multi-line improvement text
- [x] Keep auto-filled metadata out of the visible UI.
- [x] Prefer the most established existing modal/sheet pattern already used in the codebase.
- [x] Use a single scrolling form view; do not split this into a multi-step flow.

### Task 3.2: Restore and persist form state
- [x] Load remembered contact info and transient draft state when the form opens.
- [x] Persist edits while the user types or changes the issue type.
- [x] If a debounce is used for auto-save, keep it small and implementation-local rather than introducing extra architecture.
- [x] Prevent reopening the sheet from losing unsent work.

### Task 3.3: Add validation and handoff routing
- [x] Validate required fields before any handoff using standard `Form` and `TextFormField` validators.
- [x] Require:
  - non-empty name
  - non-empty email with a basic email validity check
  - non-empty issue type
  - non-empty description
- [x] At submit time, perform a one-shot connectivity check with `Connectivity().checkConnectivity()`.
- [x] Treat any result other than `ConnectivityResult.none` as online.
- [x] If online:
  - gather metadata
  - build the prefilled Google Form URL
  - launch the browser
  - only clear the transient draft if launch succeeds
- [x] If offline:
  - gather metadata
  - build the email draft URI
  - launch the mail app
  - only clear the transient draft if launch succeeds
- [x] Keep name and email after either successful handoff.
- [x] Wrap `launchUrl()` in defensive failure handling; if it returns `false` or throws, keep the draft and show an error.
- [x] Prevent duplicate sends while a handoff is already in progress.

### Task 3.4: Replace the browser-launching footer behavior
- [x] Update `lib/widgets/feedback_footer.dart` so tapping the CTA opens the in-app feedback form.
- [x] Preserve the existing footer wording unless the user explicitly requested text changes.
- [x] Capture the local DB version in the footer when the sheet is opened and pass it into the sheet immediately; do not re-read it later during submit.
- [x] In the same implementation slice, extend the Google Form URL builder to accept user-entered fields plus metadata so the old caller is not left broken between tasks.

### Task 3.5: Run automated verification for the integrated form flow
- [x] Run the relevant unit tests after wiring the form and footer.
- [x] Run targeted analysis on the changed feedback files.
- [x] Fix any failures before moving on to the final manual verification phase.

## Phase 4: End-to-End Verification and Thread Handoff

### Task 4.1: Verify remembered fields and draft restoration manually
- [x] Ask the user to open the form, enter values, close it, and reopen it.
- [x] Verify name and email are remembered.
- [x] Verify unsent draft fields are restored.

### Task 4.2: Verify the online handoff manually
- [x] Ask the user to test on a real device or emulator with connectivity.
- [x] Verify tapping the footer opens the in-app form and not the browser immediately.
- [x] Verify required-field validation blocks incomplete handoff.
- [x] Verify a valid online submission opens the real Google Form with values prefilled.
- [x] Verify the transient draft clears after successful browser handoff.

### Task 4.3: Verify the offline handoff manually
- [ ] Ask the user to disable connectivity or enable airplane mode.
- [ ] Verify a valid offline submission opens a prefilled email draft.
- [ ] Verify the email body contains headings and answers for all fields and metadata.
- [ ] Verify the transient draft clears after successful email handoff.
- [ ] Verify remembered name and email remain.

### Task 4.4: Run final automated verification
- [x] Run the relevant unit tests.
- [x] Run `flutter test` for the broader suite if the changed area affects shared behavior.
- [x] Run `flutter analyze`.
- [x] Fix any failures before asking for review.

### Task 4.5: Prepare review handoff
- [x] Stop after the work is implemented and locally verified.
- [x] Instruct the user to run `/kamma:3-review`.
- [x] Address review findings before moving to `/kamma:4-finalize`.
