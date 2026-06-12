# Spec: Stale entry state when a card's headword changes

## Overview
The random word never shows the sutta/vagga/saṃyutta/nipāta button. Root cause:
`EntrySectionsMixin._loadSuttaInfo()` runs only from `initState`. When shuffle
replaces the headword in the same `InlineEntryCard` element, `didUpdateWidget`
fires but only resets the frequency cache — sutta info stays from the first
word ever shown. Same staleness class affects family data caches
(`FamilyStateMixin._load*` early-return when cached) and, in `AccordionCard`
(no `didUpdateWidget` at all), the frequency cache too. Search results share
the latent bug on list-element reuse.

## What it should do
1. `EntrySectionsMixin` gains `handleHeadwordChange()`: reset frequency cache,
   clear + reload sutta info, and reset family state.
2. `FamilyStateMixin` gains a data-clearing reset (hide sections + null all
   five `_*Data` caches) used by the above.
3. `InlineEntryCard.didUpdateWidget` calls `handleHeadwordChange()` (replacing
   the bare `resetFrequencyCache()`); `AccordionCard` gets the same
   `didUpdateWidget`.
4. Open/closed section state (`openSections`) is intentionally preserved —
   user-confirmed liked behavior. Grammar/examples/inflections render directly
   from the new headword so staying open is correct; the sutta section guards
   on `suttaInfo != null`; family sections are hidden because their data loads
   only on toggle.

## How we'll know it's done
- Shuffle until a sutta-title word appears → sutta/vagga button shows.
- Shuffle away and back-shuffle: family sections show the current word's data.
- Open grammar, shuffle → grammar stays open showing the new word.
- `flutter analyze` clean.

## What's not included
- `EntryScreen` (`_EntryView`) — pushed per word, `initState` always runs.
- Keying cards by headword id (would destroy the liked open-state persistence).
