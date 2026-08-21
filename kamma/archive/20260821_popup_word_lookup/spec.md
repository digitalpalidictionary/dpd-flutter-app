# Spec: Popup word lookup

## Overview

User feedback:

> *"New function: Option to view a word as a 'pop up' instead of the full word page when
> clicking a word lookup (similar function to TPR's would be great). In this way you dare to
> click words in the example tab etc., without having to find your long way back there for
> the next lookup..."*

Add a setting that changes what a word tap does: instead of taking over the screen, the
tapped word's DPD entries appear in a slide-up sheet over what you were reading. Closing the
sheet leaves the underlying page exactly as it was — same scroll position, same open
sections. The existing behaviour stays the default and is unchanged when the setting is off.

## Current behaviour (verified in code, 2026-08-21)

Word tapping is handled in one place, `TapSearchWrapper`
(`lib/widgets/tap_search_wrapper.dart`). It wraps: the search results body
(`search_screen.dart:807`), the full entry page (`entry_screen.dart:80`, `shouldPop: true`),
the root page (`root_screen.dart:83`, `shouldPop: true`) and inflection tables
(`inflection_table.dart:37`).

On a tap it calls `_executeSearch`, which:
1. cleans the word (`_cleanPali`, includes `canonicalNiggahita`),
2. clears the text selection,
3. sets `searchQueryProvider` — this replaces the entire results list; scroll position and
   every open section in every card are lost,
4. records the word via `historyProvider.navigateTo` (recent list **and** back/forward stack),
5. if `shouldPop`, pops the current page.

So from the examples of an entry, a tap costs you your place; getting back means using
history and re-opening the sections.

## Key enabling fact (verified)

Every search provider is an `autoDispose.family` keyed by the query string
(`exactResultsProvider`, `partialResultsProvider`, `fuzzyResultsProvider`,
`rootResultsProvider`, `dictResultsProvider`, `secondaryResultsProvider`,
`summaryEntriesProvider`). A popup can therefore look up any word **without touching
`searchQueryProvider`**, so the main search is completely undisturbed. `InlineEntryCard`
holds its open/closed section state internally, so a second instance in a sheet coexists
happily with the ones in the results list.

## What it should do

1. **New setting: "Word lookup"** — segments `Page` (default, current behaviour) / `Popup`.
   Lives in the settings panel next to the existing "Word search tap" setting, built with
   `SettingTile` + `CompactSegmented`, with a `SettingHelpTopic`, persisted through
   `SettingsNotifier` (`SharedPreferences` key `word_lookup_mode`) exactly like `tapMode`.
   Default is `Page`, so nothing changes for anyone who does not opt in.

2. **Popup mode behaviour.** When the setting is `Popup`, a word tap opens a modal bottom
   sheet showing that word's **DPD entries only** — the same `InlineEntryCard` used in the
   results list, one per matching headword, scrollable. `searchQueryProvider` is not
   touched and no page is popped, so the screen underneath is untouched.

3. **Popup contents.** Header: the tapped word, a close button, and a "Full search" action
   that hands off to the existing behaviour (set `searchQueryProvider`, pop back to the
   results screen, close the sheet). Body: the entry cards.

4. **No match.** If the word has no DPD entries the popup still opens, showing a plain
   "no results" message for that word. The "Full search" action stays available, so the
   normal results screen — with its suggestions — is one tap away. (User decision,
   2026-08-21.)

5. **Tapping a word inside the popup** replaces the popup's contents with the new word.
   There is no back stack inside the popup — closing it always returns you to where you
   started. (User decision, 2026-08-21.)

6. **History.** Popup lookups are **not recorded at all** — not in the recent words list
   and not on the back/forward navigation stack. A glance is not a navigation. History
   behaviour is therefore completely untouched by this thread; only the `Full search`
   action records, and it does so through the existing path. (User decision, 2026-08-21.)

7. **All tap surfaces** honour the setting: results list, full entry page, root page,
   inflection tables. In popup mode the entry and root pages no longer pop themselves.

8. **Everything else unchanged.** Search bar text, deep links, share intents, the floating
   bubble, `PROCESS_TEXT` and the autocomplete dropdown all continue to open a full search;
   the setting governs *in-app word taps* only.

## Assumptions & uncertainties

- Both earlier open questions are now settled (2026-08-21): the popup shows its own
  "no results" state, and popup lookups are not recorded in history at all.
- **Presentation.** A `showModalBottomSheet` with `isScrollControlled: true` and a height
  cap (~70% of screen), matching `showSettingsOverlay` / `showHistoryOverlay` in
  `settings_panel.dart:676` / `history_panel.dart:11`. On wide screens (Linux desktop) the
  app uses inline side panels for settings and history instead; the popup deliberately uses
  a width-constrained sheet everywhere rather than adding a third panel — simpler, and the
  popup is transient rather than a mode.
- **Nested scrolling.** `SelectionArea` around nested scrollables has crashed before —
  `inflection_table.dart:31` documents a `SelectionContainer.disabled` workaround. A
  scrollable sheet containing tap-searchable, selectable cards is exactly that shape, so it
  is the main implementation risk and needs real-device testing, not just a widget test.
- Two entries in the tree are currently uncommitted from another thread
  (`20260821_large_font_chrome_layout`: `setting_tile.dart`, `settings_panel.dart` and
  others). Re-read those files before editing — they are actively changing.

## Constraints

- Project rules in `AGENTS.md` apply: theme colours only, native Flutter widgets for DPD
  content, reuse existing patterns (sheet, `SettingTile`, `CompactSegmented`,
  `InlineEntryCard`), no UI tests, one feature = one commit, never commit without an
  explicit "yes".
- **Both text-cleaning paths stay in sync** (`AGENTS.md`): `_cleanPali` and
  `IntentService._clean`. This thread should not need to touch either, but any change to
  one requires the other.
- Displayed niggahīta must be folded back with `canonicalNiggahita` before any text becomes
  a query or reaches history — the popup path must go through the same cleaning
  `_executeSearch` already does.
- Default off. An existing user's experience must be byte-identical until they change the
  setting.

## How we'll know it's done

- With the setting on `Page`, every tap behaves exactly as it does today (results list, entry
  page, root page, inflection table).
- With the setting on `Popup`: tapping a word in an entry's examples opens a sheet with that
  word's entries; closing it leaves the entry page at the same scroll position with the same
  sections still open.
- Tapping a word inside the popup swaps the popup to that word.
- "Full search" in the popup lands on the normal results screen for that word.
- A word with no entry shows the popup's own "no results" message, with `Full search` still
  working from it.
- Popup lookups leave history completely alone — the recent words list and the back/forward
  arrows behave exactly as they did before.
- Sheet scrolls, text selects and copies without crashing on a real device.
- `flutter analyze` clean; `flutter test` passes.

## What's not included

- Partial/fuzzy tiers, external dictionaries, deconstructor and summary inside the popup —
  DPD entries only for now (user decision). Adding them later means extracting the results
  assembly out of `SearchScreen._buildBody` into a shared widget; deliberately deferred.
- A back stack inside the popup (user decision).
- A desktop side-panel variant.
- Any change to external entry points (share, deep link, bubble, PROCESS_TEXT).
