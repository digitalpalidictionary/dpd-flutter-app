# Plan: Split search_screen.dart into focused files

## Phase 1: Extract widget files

- [x] Create `lib/widgets/split_results_list.dart`
  - Move: `_SplitResultsList`, `_SplitResultsListState`, `_TierDivider`, `_AccordionSecondaryCard`, `_AccordionSecondaryCardState`, `_CompactGrammarTable`, `_CompactTextLines`, `_CompactEpdList`, `_CompactVariantSummary`
  - Make all classes public (drop `_` prefix)
  - Add all imports the classes need (models, providers, widgets they reference)
  → verify: `flutter analyze lib/widgets/split_results_list.dart` reports no errors

- [x] Create `lib/widgets/info_popup.dart`
  - Move: `_InfoContent` enum, `_InfoPopup`, `_InfoMenuItem`, `_InfoContentView`, `_InfoContentViewState`
  - Make all public: `InfoContent`, `InfoPopup`, `InfoMenuItem`, `InfoContentView`
  - Add required imports (providers, theme, data, models)
  → verify: `flutter analyze lib/widgets/info_popup.dart` reports no errors

- [x] Create `lib/widgets/empty_prompt.dart`
  - Move: `_EmptyPrompt`, `_NoResultsWithSuggestions`
  - Make public: `EmptyPrompt`, `NoResultsWithSuggestions`
  - Add required imports (providers)
  → verify: `flutter analyze lib/widgets/empty_prompt.dart` reports no errors

- [x] Create `lib/widgets/download_footer.dart`
  - Move: `_DownloadFooter`
  - Make public: `DownloadFooter`
  - Add required imports (providers, services, theme)
  → verify: `flutter analyze lib/widgets/download_footer.dart` reports no errors

## Phase 2: Update search_screen.dart

- [x] Remove the 15 extracted classes from `search_screen.dart`
  - Delete everything from line 45 (`enum _InfoContent`) downward except `_BarIconButton` (lines ~1067–1115)
  - Keep: `SearchScreen`, `_SearchScreenState`, `_BarIconButton`
  → verify: file is ~850 lines

- [x] Update `search_screen.dart` imports
  - Remove imports no longer needed directly by the screen
  - Add: `../widgets/split_results_list.dart`, `../widgets/info_popup.dart`, `../widgets/empty_prompt.dart`, `../widgets/download_footer.dart`
  - Update all references to renamed classes: `_InfoContent` → `InfoContent`, `_SplitResultsList` → `SplitResultsList`, `_EmptyPrompt` → `EmptyPrompt`, `_NoResultsWithSuggestions` → `NoResultsWithSuggestions`, `_DownloadFooter` → `DownloadFooter`, `_InfoPopup` → `InfoPopup`, `_InfoContentView` → `InfoContentView`
  → verify: `flutter analyze lib/screens/search_screen.dart` reports no errors

## Phase 3: Final check

- [x] Run full analysis and tests
  → verify: `flutter analyze` — zero errors, zero new warnings
  → verify: `flutter test` — all tests pass

  Note: `flutter analyze` still reports many pre-existing unrelated issues in `lib/utils/pali_transliterator/` and `lib/benchmarks/`. The files changed by this thread analyze clean:
  `lib/screens/search_screen.dart`
  `lib/widgets/split_results_list.dart`
  `lib/widgets/info_popup.dart`
  `lib/widgets/empty_prompt.dart`
  `lib/widgets/download_footer.dart`

  Note: `dart-mcp-server_run_tests` failed twice because it forwarded an invalid `--pause-after-load` flag to `flutter test`. Fallback terminal run of `flutter test` passed.
