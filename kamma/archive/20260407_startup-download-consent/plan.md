# Plan

## Phase 1: Model the first-install consent state
- [x] Update `lib/providers/database_update_provider.dart` so first-install and required-redownload flows can expose "needs user confirmation" without auto-starting the download.
- [x] Keep the existing automatic background-update behavior unchanged when a usable local database already exists.
- [x] Ensure the provider offers an explicit action to begin the initial download after consent.
- [x] Verify Phase 1:
  - [x] Run targeted analysis on the updated provider logic and confirm the state model compiles cleanly.

## Phase 2: Show the startup consent popup using existing patterns
- [x] Update `lib/app.dart` and/or `lib/screens/download_screen.dart` to present a consent dialog before download starts when there is no usable local database.
- [x] Reuse existing app dialog conventions (`AlertDialog`, `TextButton`, `FilledButton`) and theme styling.
- [x] Write dialog copy that explains the download and mentions waiting for Wi-Fi as an option.
- [x] Ensure confirm starts the existing download flow and cancel leaves the app waiting for user action instead of downloading automatically.
- [x] Verify Phase 2:
  - [x] Run targeted analysis on the affected UI files and confirm the startup flow compiles cleanly.

## Phase 3: Add non-UI verification for the new startup behavior
- [x] Add or update focused tests for the provider/startup decision logic in `test/` so first-install consent is covered without adding UI tests.
- [x] Verify that confirm transitions into the existing downloading state.
- [x] Verify that first-install does not auto-download before the explicit start action.
- [x] Verify Phase 3:
  - [x] Run the targeted test file(s) and confirm they pass.

## Phase 4: Thread bookkeeping and final verification
- [x] Create the Kamma thread files under `kamma/threads/<thread_id>/` after approval.
- [x] Implement the approved changes and mark each task complete as work is verified.
- [x] Run a final local verification pass covering analysis and the targeted test suite.
- [x] Prepare manual test steps for a fresh-install scenario.
- [x] Verify Phase 4:
  - [x] Confirm all planned items are complete and the thread files reflect the final state.
