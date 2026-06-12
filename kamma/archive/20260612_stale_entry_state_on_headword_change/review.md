## Thread
- **ID:** 20260612_stale_entry_state_on_headword_change
- **Objective:** Fix stale entry state (sutta info, family data, frequency) when an entry card is reused for a different headword during shuffle or search-list element reuse

## Files Changed
- `lib/widgets/family_state_mixin.dart` — added `familyHandleHeadwordChange()`: hides all family sections and nulls all five `_*Data` caches
- `lib/widgets/entry_sections_mixin.dart` — added `handleHeadwordChange()`: resets frequency cache, clears sutta info, reloads sutta, chains to `familyHandleHeadwordChange()`
- `lib/widgets/inline_entry_card.dart` — `didUpdateWidget` now calls `handleHeadwordChange()` instead of bare `resetFrequencyCache()`
- `lib/widgets/accordion_card.dart` — new `didUpdateWidget` with same headword-change guard (was entirely missing)
- `assets/help/changelog.json` — added two unreleased changelog entries

## Findings
No findings.

**Residual notes:**
- `openSections` is intentionally preserved across headword changes — user-confirmed liked behavior. Grammar/examples/inflections render directly from the new headword data, so staying open is correct. Sutta section guards on `suttaInfo != null`. Family sections are hidden by `familyHandleHeadwordChange()` and reload on next toggle.
- `EntryScreen` (`_EntryView`) is not affected — it pushes a new route per word, so `initState` always runs fresh.
- No tests added — the spec explicitly scopes testing out ("Do not add UI tests"). The data-reset logic is covered by manual verification.
- `EntrySectionsMixin` declares `on FamilyStateMixin<T>`, so the `handleHeadwordChange` → `familyHandleHeadwordChange` chain is type-safe.

## Fixes Applied
None — no findings required fixing.

## Test Evidence
- `flutter analyze` → 0 issues
- `flutter test` → 297/297 passed
- Manual verification checklist (from spec):
  - [ ] Shuffle until a sutta-title word appears → sutta/vagga button shows
  - [ ] Shuffle away and back-shuffle: family sections show current word's data
  - [ ] Open grammar, shuffle → grammar stays open showing new word

## Verdict
PASSED
- Review date: 2026-06-12
- Reviewer: AI agent
