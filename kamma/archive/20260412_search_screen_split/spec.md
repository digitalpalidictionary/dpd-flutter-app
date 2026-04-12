# Spec: Split search_screen.dart into focused files

## Overview

`lib/screens/search_screen.dart` is 1,786 lines containing 18 classes. Only 3 of those classes are the actual screen (`SearchScreen`, `_SearchScreenState`, and `_BarIconButton` which is screen-local). The other 15 classes are self-contained widgets that happen to be defined in the same file. Moving them to their own files makes the screen readable and gives each widget an obvious home.

This is a mechanical refactor — zero behavior change, zero new abstractions.

## What it should do

Extract the 15 non-screen classes from `search_screen.dart` into four new widget files under `lib/widgets/`. The classes become public (drop the `_` prefix). `search_screen.dart` imports the new files.

### Extraction map

**`lib/widgets/split_results_list.dart`**
- `SplitResultsList` (was `_SplitResultsList` + `_SplitResultsListState`)
- `TierDivider` (was `_TierDivider`)
- `AccordionSecondaryCard` (was `_AccordionSecondaryCard` + `_AccordionSecondaryCardState`)
- `CompactGrammarTable` (was `_CompactGrammarTable`)
- `CompactTextLines` (was `_CompactTextLines`)
- `CompactEpdList` (was `_CompactEpdList`)
- `CompactVariantSummary` (was `_CompactVariantSummary`)

**`lib/widgets/info_popup.dart`**
- `InfoPopup` (was `_InfoPopup`)
- `InfoMenuItem` (was `_InfoMenuItem`)
- `InfoContentView` (was `_InfoContentView` + `_InfoContentViewState`)
- `InfoContent` enum (was `_InfoContent`)

**`lib/widgets/empty_prompt.dart`**
- `EmptyPrompt` (was `_EmptyPrompt`)
- `NoResultsWithSuggestions` (was `_NoResultsWithSuggestions`)

**`lib/widgets/download_footer.dart`**
- `DownloadFooter` (was `_DownloadFooter`)

After the split, `search_screen.dart` should be roughly 850 lines containing only: `SearchScreen`, `_SearchScreenState`, and `_BarIconButton`.

## Assumptions & uncertainties

- The `_InfoContent` enum is currently private (`_InfoContent`). Moving it to `info_popup.dart` and making it public changes nothing about how it's used — it's only referenced inside `_SearchScreenState` for `_activeInfo`. After the move it will be referenced as `InfoContent` from `search_screen.dart`.
- `_BarIconButton` stays in `search_screen.dart` — it's a tiny (50-line) local helper used only in the search bar row. Not worth a separate file.
- All imports needed by extracted widgets will move with them. `search_screen.dart` will drop the imports it no longer needs directly and add imports of the four new files.
- No providers, models, or services are moved — only widget classes.

## Constraints

- Zero behavior change. No logic modifications.
- No new abstractions. Just file relocation.
- Do not rename anything beyond removing the `_` prefix (making classes public).
- All existing tests must continue to pass unchanged.

## How we'll know it's done

- `flutter analyze` reports zero new errors or warnings.
- `flutter test` passes with no changes to test files.
- `search_screen.dart` is ~850 lines.
- Each of the four new files exists and contains only the extracted classes.
- The app launches, search works, results display, info popup opens, download footer appears during an update.

## What's not included

- Any logic changes.
- Any provider or state management changes.
- Any changes to `dao.dart`, `entry_content.dart`, or any other file.
- Splitting `_SearchScreenState` itself (that's a separate task if ever needed).
