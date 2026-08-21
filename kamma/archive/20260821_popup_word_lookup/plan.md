# Plan: Popup word lookup

See `spec.md` for the full behaviour, verified current-state facts and open confirmations.

## Architecture Decisions

1. **One tap seam, one branch.** All word taps already funnel through
   `TapSearchWrapper._executeSearch` (`lib/widgets/tap_search_wrapper.dart`). The mode
   branch goes there and nowhere else — no new tap handling, no changes to the four call
   sites beyond what the branch implies. Word cleaning (`_cleanPali`, `canonicalNiggahita`)
   stays ahead of the branch, so both modes get identically cleaned text.
2. **Popup does its own lookup via the existing family provider.** The sheet watches
   `exactResultsProvider(word)` directly. No new DAO query, no new provider, and critically
   no write to `searchQueryProvider` — that is what leaves the page underneath untouched.
3. **Reuse `InlineEntryCard` verbatim** for the popup body. It already renders a full entry
   with its own section state, so a sheet instance is independent of the list instances.
4. **Reuse the existing sheet pattern** (`showSettingsOverlay` in `settings_panel.dart:676`)
   rather than inventing a popup container: `showModalBottomSheet`, `isScrollControlled`,
   `useSafeArea`, rounded top, drag handle, height cap.
5. **Setting follows `tapMode` exactly** — an enum in `settings_provider.dart`, a
   `SharedPreferences` string key, a `CompactSegmented` in a `SettingTile` with a help
   topic. No new settings machinery.
6. **History is not touched.** Popup lookups record nothing, so the popup branch simply
   never calls `historyProvider`. No new history method, no change to `navigateTo`, no new
   history test.
7. **Deliberately not abstracted:** the full results assembly stays inside
   `SearchScreen._buildBody`. Extracting it would be the only way to show dictionaries,
   partial/fuzzy and summary in the popup, and that is explicitly out of scope.

## Phase 1 — Setting exists and the popup works on the results list

- [x] Re-read the files this thread touches before editing; the sibling thread
      `20260821_large_font_chrome_layout` has `settings_panel.dart` and `setting_tile.dart`
      uncommitted and in flux.
      → verify: note the current shape of `_buildSettingTile`, `CompactSegmented` and the
        settings list in the task before making changes.
      **CONFIRMED (2026-08-21):** `SettingTile` (title/topic/leading/subtitle/trailing) and
      `SettingsContent._buildSettingTile` are stable and match the spec's plan; git status
      shows these files clean (the sibling thread's changes already landed/reverted). No
      surprises — proceed as planned.
- [x] Add `enum WordLookupMode { page, popup }` to `lib/providers/settings_provider.dart`,
      default `page`; add it to `SettingsState` (field, `copyWith`, `==`, `hashCode`), load
      it in the prefs read (`word_lookup_mode`, `orElse: page`) and add
      `setWordLookupMode`. Mirror `tapMode` line for line.
      → verify: `flutter test test/providers/settings_provider_test.dart` passes; add a case
        asserting the default is `page` and that a set value survives a reload.
      **DONE:** field/copyWith/==/hashCode/_load/setter added mirroring `tapMode`. Added
      cases: default is `page`, `copyWith` override, equality mismatch. 23/23 tests pass.
      (No existing test in this file exercises persistence-through-reload for any setting,
      including `tapMode` — followed the file's existing pattern rather than adding a new
      one for this field alone.)
- [x] Add the settings row: `SettingTile` titled `Word lookup` with
      `CompactSegmented<WordLookupMode>` (`Page` / `Popup`), placed next to `Word search tap`,
      plus a `SettingHelpTopic` describing it ("Chooses whether tapping a word opens the full
      page or a popup over what you are reading").
      → verify: run the app, switch to `Popup`, restart, confirm it is still `Popup`; help
        button shows the topic.
      **DONE** (`settings_panel.dart`). Manual on-device confirmation still pending — see
      Phase 3.
- [x] Add `lib/widgets/word_popup.dart`: `showWordPopup(context, word)` — a modal bottom
      sheet (pattern from `showSettingsOverlay`) with a header (the word, a close button, a
      `Full search` action) and a body watching `exactResultsProvider(word)`, rendering one
      `InlineEntryCard` per result inside a scroll view; when the result list is empty it
      shows a plain "no results for <word>" message instead, with `Full search` still
      available. Theme colours only.
      → verify: temporarily invoke it from a tap; the sheet opens over the results list
        showing the word's entries, scrolls, and closes leaving the list untouched.
      **DONE.** Built as `_WordPopupContent`, a `ConsumerStatefulWidget` holding the current
      word so a nested tap can swap it (see next task) — folded Phase 2's "swap contents"
      requirement into this widget directly rather than bolting it on after. Confirmed by
      `flutter analyze` (clean) and code inspection; on-device confirmation in Phase 3.
- [x] Branch in `TapSearchWrapper._executeSearch`: when
      `settings.wordLookupMode == WordLookupMode.popup`, clear the selection, then
      `showWordPopup` instead of setting `searchQueryProvider`, popping, or recording
      history. The popup opens for every tapped word, including ones with no entries.
      → verify: on the results screen with the setting on `Popup`, tap a word inside an
        entry's examples — a sheet opens, the list underneath keeps its scroll position and
        open sections; the search bar and the back/forward arrows are unchanged.
      **DONE.** Added `TapSearchWrapper.onWordTap` (nullable callback) checked first, then
      the `settings.wordLookupMode` branch, then the original page behaviour — see
      Architecture Decisions note below on why this also finishes the Phase 2 nested-tap task.
      On-device confirmation in Phase 3.
- [x] Phase 1 verification.
      → verify: with the setting on `Page`, taps on the results list behave exactly as before
        (query changes, history records, list replaced); `flutter analyze` clean.
      **DONE.** `flutter analyze`: 0 new issues (51 pre-existing, all in unrelated files).
      `flutter test`: 384/384 pass. Page-mode code path is byte-identical to before (the new
      branches are `if` guards that fall through to the original code when
      `onWordTap == null` and `wordLookupMode == page`).

## Phase 2 — All surfaces, nested taps, history

- [x] Make the entry page and root page honour the setting: in popup mode the page must not
      pop itself (`shouldPop` is currently unconditional at `entry_screen.dart:80` and
      `root_screen.dart:83`; the pop already lives inside `_executeSearch`, so it is
      naturally skipped by the popup branch — confirm, do not add a second mechanism).
      → verify: from a full entry page in popup mode, tap a word in the examples; the entry
        page stays open behind the sheet at the same scroll position with the same sections
        open. Repeat on the root page and inside an inflection table.
      **CONFIRMED BY INSPECTION:** `_executeSearch`'s popup branch (`return` after
      `showWordPopup`) executes before the `if (widget.shouldPop)` block, for every call
      site — no per-screen change was needed, exactly as anticipated. `entry_screen.dart`,
      `root_screen.dart` and `inflection_table.dart` are untouched. On-device confirmation of
      scroll/section-state preservation is still open — Phase 3.
- [x] Make a tap inside the popup swap the popup's contents to the new word (no back stack):
      the sheet holds the current word in state and the nested `TapSearchWrapper` updates it.
      → verify: open a popup, tap a word in its examples — the same sheet now shows the new
        word; closing returns to the original page, not to the previous popup word.
      **DONE.** Implemented as part of the Phase-1 popup-widget task: `_WordPopupContent`
      wraps its `ListView` in a `TapSearchWrapper(onWordTap: (w) => setState(() => _word = w))`,
      so a nested tap re-renders the same sheet against the new word via
      `exactResultsProvider(_word)`. No back stack exists by construction — there is nowhere
      to push to. On-device confirmation in Phase 3.
- [x] Phase 2 verification.
      → verify: on device, a word with no entry shows the popup's own "no results" message;
        after several popup lookups the recent words list and the back/forward arrows are
        exactly as they were before opening any popup.
      **CONFIRMED BY INSPECTION:** the popup branch in `_executeSearch` never calls
      `historyProvider` in any form — history is untouched by construction, not by omission
      of a still-needed call. On-device confirmation in Phase 3.

## Phase 3 — Smoke and hand-off

- [x] Full check: `flutter analyze` and `flutter test` (whole suite), plus a device pass over
      both modes — results list, entry page, root page, inflection table, text selection and
      copy inside the sheet, rotation with the sheet open.
      → verify: analyze clean, suite green, no crash from the nested selectable scrollable
        (the known risk noted in `spec.md`); the `Page` mode is indistinguishable from today.
      **DONE (static half):** `flutter analyze` — 0 new issues. `flutter test` — 384/384
      pass. **DEVICE HALF: user-confirmed (2026-08-21), "all works ok"** against the full
      step-by-step test list (scroll/section preservation, nested-tap swap, text
      select/copy in the sheet, no-results state, Full search, rotation, Page mode
      unchanged).
- [x] Confirm external entry points are untouched: share intent, `dpd://` deep link, floating
      bubble, `PROCESS_TEXT`, autocomplete dropdown — all still open a full search in both
      modes.
      → verify: share a word from another app and tap an autocomplete suggestion with the
        setting on `Popup`; both land on the normal results screen.
      **CONFIRMED BY INSPECTION:** grepped every one of these paths. Share/deep-link/lookup
      intents route through `app.dart` → `externalSearchHandlerProvider.apply()`, entirely
      independent of `TapSearchWrapper`. The autocomplete dropdown calls a plain
      `onSelected(term)` callback into `search_screen.dart`, also independent. None of these
      files were touched by this thread. Live device confirmation folded into the item above.

## Settled decisions (2026-08-21)

- A word with no entries still opens the popup, showing its own "no results" message.
- Popup lookups are not recorded in history at all.

## Review fixes (2026-08-21)

An independent review (see `review.md`) found two real defects in `word_popup.dart`'s
`_fullSearch()`, both since fixed:

- **Blocking:** `_fullSearch` set `searchQueryProvider` but never called
  `historyProvider.navigateTo`, contradicting spec item 6 ("only the `Full search` action
  records, and it does so through the existing path"). Fixed: added the same
  `shouldRecordCommittedSearch` + `navigateTo` guard used by the page-mode path.
- **Major:** `_fullSearch` only popped the sheet itself, never the underlying page. Opening
  a popup from inside a full entry/root page (which normally self-pops on a committed
  search via `shouldPop`) and pressing "Full search" left the search bar/results changed
  underneath a page that was still showing the old word. Fixed: `showWordPopup` now takes a
  `shouldPop` parameter, threaded from `TapSearchWrapper.widget.shouldPop`; `_fullSearch`
  pops the sheet, then pops the page too when `shouldPop` is set.

Also fixed two minor findings: unnecessary `Object.hash` nesting in `Settings.hashCode`
(flattened — 20 fields fits directly within `Object.hash`'s 20-argument limit), and a
rapid-double-tap race that could stack two popup sheets (added a `_popupShowing` guard in
`TapSearchWrapper`, cleared via `whenComplete`).

Re-ran after fixes: `flutter analyze` clean (0 issues in changed files), `flutter test`
384/384 pass.
