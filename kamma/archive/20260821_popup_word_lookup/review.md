## Thread
- **ID:** 20260821_popup_word_lookup
- **Objective:** Add a "Word lookup" setting (Page/Popup) so a tapped word can optionally open in a slide-up sheet over the current screen instead of replacing it, without disturbing the underlying page's scroll/section state or the search bar.

## Files Changed
- `lib/providers/settings_provider.dart` — `WordLookupMode` enum, `Settings.wordLookupMode` field/copyWith/==/hashCode/persistence/setter, mirroring `tapMode`.
- `lib/widgets/settings_panel.dart` — new "Word lookup" settings row + help topic.
- `lib/widgets/tap_search_wrapper.dart` — new `onWordTap` callback param; `_executeSearch` branches: `onWordTap` (nested-tap swap) → popup mode (`showWordPopup`, with a `_popupShowing` guard against rapid-double-tap stacking) → original page behaviour, unchanged.
- `lib/widgets/word_popup.dart` (new) — `showWordPopup()`, a modal sheet showing a word's `exactResultsProvider` matches via `InlineEntryCard`, a "no results" state, a "Full search" action, and nested-tap swap (no back stack).
- `test/providers/settings_provider_test.dart` — default/copyWith/equality cases for `wordLookupMode`.

## Findings

Independent review (spawned subagent, zero shared context) found two real defects, since fixed, plus two minor issues, also fixed.

| # | Severity | Location | What | Why | Fix | Status |
|---|----------|----------|------|-----|-----|--------|
| 1 | blocking | `word_popup.dart` `_fullSearch()` | Set `searchQueryProvider` but never called `historyProvider.navigateTo` | Contradicts spec item 6: "Full search" must record through the existing path | Added the same `shouldRecordCommittedSearch`+`navigateTo` guard used by the page-mode branch | Fixed |
| 2 | major | `word_popup.dart` `_fullSearch()` | Only popped the sheet, never the underlying entry/root page | Opening a popup from a full entry/root page (which normally self-pops via `shouldPop`) and pressing "Full search" left the search bar changed underneath a page still showing the old word | Threaded `shouldPop` from `TapSearchWrapper` into `showWordPopup`; `_fullSearch` now pops the sheet then the page when set | Fixed |
| 3 | minor | `settings_provider.dart` `Settings.hashCode` | Unnecessary nested `Object.hash(showOtherDictsInSummary, wordLookupMode)` | 20 fields fit directly within `Object.hash`'s 20-arg limit; nesting was needless and inconsistent with the rest of the list | Flattened to a plain 20-argument call | Fixed |
| 4 | minor | `tap_search_wrapper.dart` `_executeSearch` | No guard against two rapid taps each independently opening a popup sheet | `_executeSearch` runs a frame after the tap (`addPostFrameCallback`), leaving a window for a second tap to fire before the first sheet's barrier is up | Added `_popupShowing` bool, set before `showWordPopup`, cleared via `.whenComplete` | Fixed |
| 5 | nit | `tap_search_wrapper.dart` / `word_popup.dart` | Two-file circular import (each imports the other) | Dart tolerates it (analyze/tests clean); worth knowing about before it worsens | Not changed — nit, no functional issue | Not fixed (accepted) |

## Fixes Applied
- `word_popup.dart`: `showWordPopup` gained a `shouldPop` parameter; `_fullSearch` now records history and pops both the sheet and (when applicable) the underlying page.
- `tap_search_wrapper.dart`: the popup branch passes `shouldPop: widget.shouldPop` through; added `_popupShowing` re-entrancy guard.
- `settings_provider.dart`: flattened `Settings.hashCode`.

## Test Evidence
- `flutter analyze` (scope: whole project) → before fixes: 51 pre-existing issues, 0 in changed files. After fixes: `lib/widgets/tap_search_wrapper.dart`, `lib/widgets/word_popup.dart`, `lib/providers/settings_provider.dart` analyzed directly → "No issues found!"; full-project rerun unnecessary since only those three files changed post-review.
- `flutter test` (scope: whole suite, 384 tests) → before fixes: 384/384 pass. After fixes: 384/384 pass.
- `coderabbit review --agent --base main --type uncommitted` (scope: all 6 changed/new files, confirmed via `git add -N` for the untracked new file, then unstaged again) → 0 findings both passes. Independent agent review caught findings #1/#2 that CodeRabbit missed — CodeRabbit's clean pass is corroborating, not sufficient, evidence.
- Manual on-device pass (user, 2026-08-21, "all works ok") against the full step list: scroll/section-state preservation when a popup opens from an entry page's examples, nested-tap swap inside the popup, text selection/copy inside the sheet (the specific crash risk flagged in `spec.md`), the "no results" state, Full search, rotation with the sheet open, and Page-mode being unchanged.

## Not Verified
- The device pass predates the fix for finding #2 (missing pop-through). The user's confirmed scenarios did not specifically include "open a popup from a word inside a full entry/root page's examples, then press Full search" — the exact scenario the bug affected. The fix is verified by code inspection and the reviewing agent's Navigator-stack trace, not by a fresh on-device run. Worth one more targeted device check before or shortly after finalize, though the risk is now low: the logic mirrors the existing single-pop pattern already used by page mode.
- Desktop/wide-screen (Linux) layout was not exercised on-device; per spec this is deliberately out of scope (popup uses a width-constrained sheet everywhere rather than a third side panel).

## Verdict
PASSED
- Review date: 2026-08-21
- Reviewer: independent subagent (general-purpose, zero shared context) + coordinating agent fix pass
