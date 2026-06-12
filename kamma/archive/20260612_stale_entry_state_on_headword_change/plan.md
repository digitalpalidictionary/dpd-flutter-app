# Plan: Stale entry state when a card's headword changes

## Architecture Decisions
1. Fix at mixin level so both display contexts (inline + accordion) and the
   search-list element-reuse case are covered by the same code.
2. Preserve `openSections` across headword changes (user-liked behavior);
   only stale *data* is reset.

## Phases

### Phase 1 — Reset stale state on headword change
- [x] `FamilyStateMixin`: add `familyHandleHeadwordChange()` — `familyResetAll()` + null the five `_*Data` caches.
  → verify: `flutter analyze` clean.
- [x] `EntrySectionsMixin`: add `handleHeadwordChange()` — `resetFrequencyCache()`, clear `_suttaInfo`/`_suttaLoaded`, `_loadSuttaInfo()`, `familyHandleHeadwordChange()`.
  → verify: `flutter analyze` clean.
- [x] `InlineEntryCard.didUpdateWidget`: call `handleHeadwordChange()`; add identical `didUpdateWidget` to `AccordionCard`.
  → verify: `flutter analyze` clean.
- [ ] Manual: shuffle to a sutta-title word shows the sutta/vagga button; families reload per word; open grammar persists across shuffle.
  → verify: user confirms on Android (STOP — no commit; user commits).
