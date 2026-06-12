# Plan: Random Word as Full Entry

## Architecture Decisions
1. **Reuse the display-mode switch pattern** from `split_results_list.dart:353-358` — `DisplayMode.classic => InlineEntryCard`, `DisplayMode.compact => AccordionCard`. No new widgets.
2. **Watch only `displayMode`** via `settingsProvider.select` so the section doesn't rebuild on unrelated settings changes (cards watch their own settings internally).
3. **Delete, don't wrap** — the hand-rolled summary in `_WordOfDaySection` is removed entirely; the cards carry their own padding and layout.
4. **Fallback (user-confirmed):** if display-mode switching causes any problem, use `InlineEntryCard` unconditionally.

## Phases

### Phase 1 — Swap rendering
- [x] In `lib/widgets/home_content.dart`, replace the `data:` builder of `_WordOfDaySection` with the display-mode switch returning `InlineEntryCard` / `AccordionCard`; remove the dead summary code and now-unused imports.
  → verify: `flutter analyze` clean.
- [x] Manual: classic mode — random word identical to a classic search result; compact mode — one-line accordion, expands on tap; shuffle fetches a new word; tap-to-search works inside the entry.
  → verify: user confirmed on Android 2026-06-12 (noted open/closed section state persists).
