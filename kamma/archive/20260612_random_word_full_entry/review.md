# Review — random word as full entry

## Outcome: COMPLETE

## Summary

The home screen "Random Word" section now renders the real entry card instead
of a hand-rolled three-line teaser, following the user's display mode setting
(classic → `InlineEntryCard`, compact → `AccordionCard`), same switch pattern
as search results in `split_results_list.dart`.

## Changes

- `lib/widgets/home_content.dart` — `_WordOfDaySection` `data:` builder replaced
  with the display-mode switch; ~45 lines of duplicated summary rendering
  deleted; dead imports (`dao.dart`, `dpd_headword_extensions.dart`,
  `dpd_palette.dart`) removed; `settings_provider.dart`, `accordion_card.dart`,
  `inline_entry_card.dart` added.
- Free side effects: niggahita filtering, section buttons (grammar, examples,
  families…), tap-to-search (via `TapSearchWrapper` already wrapping
  `HomeContent`), font scaling, and persisted open/closed section state.

## Verification

- User confirmed on Android — classic entry renders correctly and open/closed
  grammar/example section state persists.
- `flutter analyze`: no issues in the changed file (94 pre-existing infos
  elsewhere, untouched).
- `coderabbit review --agent`: 0 findings.
