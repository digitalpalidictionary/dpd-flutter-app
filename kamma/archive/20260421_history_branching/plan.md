# Plan: Logical history branching and back navigation

## Phase 1 — Model the two histories separately

- [x] Inspect the current history consumers in `lib/providers/history_provider.dart`,
      `lib/screens/search_screen.dart`, `lib/widgets/history_panel.dart`,
      `lib/providers/search_provider.dart`, and `lib/widgets/tap_search_wrapper.dart`
      to map all committed-search entry points and current assumptions.
- [x] Design the new state shape so recent-search history and navigation history
      are distinct but coordinated.
- [x] Implement the provider/model changes needed to support:
  - a linear navigation stack with current position
  - forward-branch pruning on new navigation from an older position
  - a separate deduplicated recent-search list with timestamps
  → verify: `dart analyze lib/providers/history_provider.dart` reports no errors

## Phase 2 — Wire all navigation entry points to the new model

- [x] Update toolbar search submit, autocomplete selection, tap-to-search, and
      history-sheet taps to use the new shared navigation action instead of
      mutating recency order directly.
- [x] Keep Android Back and toolbar back/forward fully aligned by routing both
      through the same navigation behavior.
- [x] Re-check external entry points in `lib/main.dart` and `lib/app.dart` so
      `_IntentBoot`, `intentStream`, and `lookupStream` still record committed
      searches through the shared history rules.
  → verify: `dart analyze lib/screens/search_screen.dart lib/widgets/history_panel.dart lib/providers/search_provider.dart lib/widgets/tap_search_wrapper.dart lib/app.dart lib/main.dart` reports no errors

## Phase 3 — Define clear clear/remove semantics

- [x] Decide and implement what `clear()` and `removeAt()` mean once recency and
      navigation are separate.
- [x] Ensure deleting or clearing recent-search history does not leave the app
      in a broken navigation state.
- [x] Preserve persisted recent-search compatibility with the current
      `SharedPreferences` format, or document and implement a safe migration if
      the format must change.
  → verify: targeted analyze checks for touched provider/history files pass

## Phase 4 — Regression tests for branching behavior

- [x] Expand `test/providers/history_provider_test.dart` to cover:
  - linear back/forward traversal
  - branching from an older entry
  - pruning forward history on branch
  - history-sheet recency remaining independent
  - clear/remove semantics
- [x] Update or add focused tests for shared entry points where needed,
      including external search handling and Android back decision logic.
  → verify: `flutter test test/providers/history_provider_test.dart test/providers/external_search_handler_test.dart test/utils/back_navigation_test.dart test/utils/history_recording_test.dart` passes

## Phase 5 — Final verification

- [x] Re-read all changed history/navigation code paths to confirm the final
      behavior matches the spec and no older recency assumptions remain.
- [x] Run a broader relevant verification pass for the touched area and confirm
      there are no new analyzer or test failures.
  → verify: targeted tests pass and touched files are analyzer-clean
