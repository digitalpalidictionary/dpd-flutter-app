# Plan — Remove redundant magnifying-glass search button

## Architecture Decisions
- Delete the `_BarIconButton(icon: Icons.search, ...)` widget instance only. Keep `_onSearch` method intact because `onSubmitted` still calls it.
- Do not refactor surrounding layout. The remaining `_BarIconButton`s (Clear, Back, Forward) and the `Row`/spacing stay byte-identical apart from the deletion.

## Phase 1 — Remove the button

- [x] Open `lib/screens/search_screen.dart`, locate the `_BarIconButton` with `icon: Icons.search` inside the search-bar `Row` (~lines 569–573), and delete that widget block.
  → verify: `Icons.search` no longer appears in the file. `_onSearch` defined at line 101 and referenced at line 527 by `onSubmitted`. ✓

- [x] Run `flutter analyze` from the project root.
  → verify: only one pre-existing warning (`isDark` unused at line 347) — unrelated to this change. ✓

- [x] Phase verification: re-read the modified `Row` block. Confirm structure is: `Expanded(TextField)`, `SizedBox(width: 4)`, then Clear, Back, Forward buttons only.
  → verify: confirmed via Read — Row children are TextField, SizedBox(width:4), Clear button, then Back/Forward Builder. ✓
