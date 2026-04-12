# Thread Plan
Issue reference: GitHub issue #13 - "Add external searches to history list"

## Phase 1: Capture external committed searches in the shared history path
- [x] Inspect the current external search entry points in `lib/main.dart` and `lib/app.dart`, plus the history consumers in `lib/screens/search_screen.dart`, `lib/providers/history_provider.dart`, and `lib/utils/history_recording.dart`, and confirm where external flows bypass history insertion today.
- [x] Mark the exact integration point for external committed searches so all three entry points (`_IntentBoot`, `intentStream`, `lookupStream`) use the same history-recording rule without changing existing display-text behavior.
- [x] Implement the external-search history recording change in the relevant app/provider files.
- [x] Verify Phase 1 automatically by running the most targeted test command available for the affected non-UI logic and checking that the code compiles for the touched area.

## Phase 2: Add regression tests for external history behavior
- [x] Inspect existing tests in `test/providers/history_provider_test.dart` and related search/history tests to find the best place to add coverage without introducing UI tests.
- [x] Add tests that prove externally triggered committed searches are recorded, including the first external search case and duplicate/normalization behavior expected from the shared history-recording rule.
- [x] Add or update any focused helper tests if the final implementation introduces a reusable non-UI function for external search handling.
- [x] Verify Phase 2 automatically by running the focused history/search test files and confirming they pass.

## Phase 3: Final verification and thread readiness
- [x] Re-read the changed external entry-point code paths (`_IntentBoot`, `intentStream`, `lookupStream`) to ensure all required sources now record history and that internal search paths are unchanged.
- [x] Run a broader relevant verification pass for the changed area and confirm the final code matches the spec requirements.
