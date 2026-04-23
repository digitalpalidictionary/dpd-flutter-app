# Ideas for Improvement

Merged master list of improvement ideas for the DPD Flutter app, compiled from two independent reviews of the codebase. Ranked from most to least critical.

---

## Tier 1 — Absolutely Vital

### 1. iOS build & TestFlight distribution
README states "Android-first". The `ios/` folder exists but there is no signed build or distribution path. A substantial fraction of the Pali-learning audience (monks, students, academics) uses iPads/iPhones. Shipping iOS roughly doubles reachable users and is the single highest-ROI item on this list.

### 2. First-run download & forced-update recovery
The app lives or dies on database availability. `lib/screens/download_screen.dart` is fairly minimal despite `database_update_service.dart` already handling resume, stall detection, cancel, and compatibility logic. Needed:
- Onboarding carousel: what DPD is, Velthuis input, sections, history, settings
- Size / network / storage preflight messaging
- Clearer "why this is required" states
- Proper recovery guidance for corrupt or incompatible DB cases

This is the highest-risk UX window in the whole app — a blank or confusing first launch is where non-technical users churn.

---

## Tier 2 — High Value

### 3. Inline result-source controls on the search screen
Source visibility and ordering currently live in settings via `dictVisibilityProvider` and `SettingsContent`, while `split_results_list.dart` mixes DPD, roots, secondary tools, and external dictionaries together. Inline chips (DPD / Roots / Grammar / EPD / Fuzzy / Partial) directly on the search surface would make the app feel dramatically faster and more understandable — without changing the backend search model.

### 4. Full-text search inside examples & commentaries
Search is currently lemma- and inflection-based. An FTS5 index over `example_1` / `example_2` (and ideally sutta text) transforms DPD from a dictionary into a concordance. Scholars want to locate *where a phrase appears*. Moderate DB-side work, huge user payoff.

### 5. Bookmarks / study lists
`history_provider` exists but history ≠ intentional saving. Students memorising vocab, translators building glossaries, and teachers preparing lessons all need "save this word" with optional tags or lists. Data model is trivial (one table + one provider); ongoing user value is large.

### 6. Performance pass on heavy searches and result rendering
`kamma/tech.md` explicitly prioritises startup and search speed. `SearchScreen` watches many providers simultaneously; `SplitResultsList` builds tier arrays eagerly. Fine for common queries, expensive for broad searches — especially in compact mode with many dictionary sources enabled. Profile, lazy-build tiers, and trim redundant provider watches.

---

## Tier 3 — Medium (Code Health & UX Refinement)

### 7. Consolidate the three entry-display contexts
`EntryScreen`, `InlineEntryCard`, and `AccordionCard` already share `EntrySectionsMixin` + `FamilyStateMixin`, but `EntryScreen` builds its own "notes" button while inline cards don't, and `buildExtraSectionButtons` only runs in inline contexts. This is drift waiting to produce bugs. A single `EntryBody` widget with display-mode flags would kill a whole class of "X works here but not there" regressions.

### 8. Split `search_screen.dart` (881 lines) into smaller state owners
Currently owns: text input, debounce, autocomplete overlay, help overlay, info overlay, settings panel, history panel, Android back behavior, provider sync, and result composition. Extract `SearchAppBar`, `SearchOverlayController`, and `AndroidBackController`. Pure refactor — no user-visible change, but every future search feature becomes cheaper and regression risk for intent/share/history behaviour drops.

### 9. Reorganise settings into groups with presets
`settings_panel.dart` is a long flat list that asks users to understand the app's internal model. Group into **Reading / Search / Input / Updates / Advanced**, plus presets like **Simple / Scholar / Compact**. Big friction reduction for new users, negligible risk for power users.

### 10. Reading navigation inside entries and roots
Entry and root screens still feel like long document viewers. Improvements: a sticky section jump bar, smarter "open the most relevant section first" logic, and clearer movement between summary / grammar / examples / root / family. Long-form reading becomes materially smoother.

---

## Tier 4 — Nice to Have

### 11. Shareable deep links
A URL scheme (`dpd://entry/12345`) with a web fallback to dpdict.net so users can link entries from Anki, Obsidian, Discord, notes apps. Low cost once intent handling is already wired up; valuable for the power-user community that drives most of the app's evangelism.

---

## Source

Compiled 2026-04-23 from two independent reviews of `lib/` — merged and deduplicated. Items 1, 4, 7, 11 from review A; items 3, 6, 9, 10 from review B; items 2, 5, 8 present in both.
