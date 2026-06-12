# Spec: Random Word as Full Entry

## Overview
The "Random Word" section on the home screen currently shows a hand-rolled three-line teaser (lemma, pos + meaning + construction). Replace it with the real entry card so the random word looks and behaves exactly like a normal search result, following the user's display mode setting:
- **Classic mode** → `InlineEntryCard` (lemma + summary box + collapsible section buttons)
- **Compact mode** → `AccordionCard` (one-line summary, tap to expand)

Fallback decision (user-confirmed): if following the display mode causes any problems, drop to always-classic (`InlineEntryCard`).

## Repo context
- `lib/widgets/home_content.dart:87-130` — `_WordOfDaySection` hand-rolls its own pos/meaning/lit/construction rendering, a drifting duplicate of `EntrySummaryBox`. It ignores niggahita filtering and the sandhi-apostrophe setting.
- `lib/providers/word_of_day_provider.dart` — `randomWordProvider` already returns `DpdHeadwordWithRoot?`, the exact type both entry cards consume.
- `lib/widgets/split_results_list.dart:353-358` — the existing display-mode switch pattern: `DisplayMode.classic => InlineEntryCard`, `DisplayMode.compact => AccordionCard`.
- `lib/screens/search_screen.dart:692-701` — `HomeContent` already renders inside `TapSearchWrapper` + `ContentTextScale`, so tap-to-search and font scaling apply for free.
- `lib/providers/settings_provider.dart:8` — `enum DisplayMode { classic, compact }` on `settingsProvider`.

## What it should do
1. The random word renders as a real entry card, switched on `settings.displayMode`, exactly like `_buildItem` in `split_results_list.dart`.
2. The "Random Word" label and shuffle button row stay unchanged.
3. The hand-rolled summary rendering in `_WordOfDaySection` is deleted, along with any imports it alone used.
4. Loading / error / null states stay as they are.

## Side effects (accepted as improvements)
- Random word now respects niggahita (ṃ/ṁ) and other text settings.
- Section buttons (grammar, examples, families, etc.) become available directly on the home screen.
- Tap-to-search works inside the random word entry.

## Assumptions & uncertainties
- No history recording or other state changes are added — strictly a rendering swap (behavior-parity rule).
- `AccordionCard`'s collapsed state shows lemma + meaning on one line, so compact mode remains informative (verified in `accordion_card.dart:99-132`).
- Both cards manage their own section state via `FamilyStateMixin` + `EntrySectionsMixin`; no extra wiring needed.

## Constraints
- No new widgets — reuse `InlineEntryCard` / `AccordionCard` as-is.
- No UI tests (project policy).
- No commits until the user confirms on Android.

## How we'll know it's done
- Home screen random word in classic mode is visually identical to a classic search result for the same headword.
- In compact mode it shows the one-line accordion summary and expands on tap.
- Shuffle button still fetches a new word.
- Tapping a word inside the entry triggers a search.
- `flutter analyze` clean.

## What's not included
- Recording the random word in search history.
- Changing the shuffle button or section layout of the home screen.
- "Word of the day" persistence (it stays random per fetch).
