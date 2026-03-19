# Plan: External Dictionary Integration (Cone's Dictionary of Pāli)

## Phase 0: HTML Rendering Proof-of-Concept [checkpoint: e7bc244]

- [x] Task: Test `flutter_widget_from_html` with real Cone entries `45a91ed`
  - [x] Add `flutter_widget_from_html` to `pubspec.yaml`, run `flutter pub get`
  - [x] Create a throwaway test screen with hardcoded Cone HTML + CSS
  - [x] Test with: (a) a simple entry, (b) a large entry, (c) an entry with Devanagari/Kharosthi spans
  - [x] Verify key CSS features render: orange lemma, italic POS, superscript homonyms, bold subsense headwords, small-caps abbreviations
  - [x] Identify any CSS that needs stripping or overriding (desktop-only rules like `position: fixed`, `:hover`, `@font-face`)
  - [x] Test in both light and dark mode — note any hardcoded colors that clash

- [x] Task: Conductor - User Manual Verification 'Phase 0: HTML Rendering PoC' (Protocol in workflow.md)

## Phase 1: Database Export (Python) [checkpoint: 2abf918]

- [x] Task: Add `export_other_dictionaries()` to `mobile_exporter.py` `6eee448`
  - [x] Create `dict_meta` table with schema: `dict_id TEXT PK, name TEXT, author TEXT, css TEXT, entry_count INTEGER`
  - [x] Create `dict_entries` table with schema: `id INTEGER PK, dict_id TEXT, word TEXT, word_fuzzy TEXT, definition_html TEXT, definition_plain TEXT`
  - [x] Add index on `(dict_id, word)` and `(dict_id, word_fuzzy)`
  - [x] Generate `word_fuzzy` via `_strip_diacritics_mobile()` (strips diacritics, aspirates, double consonants — same function used for `lookup.fuzzy_key`)
  - [x] Load `cone_dict.json` + `cone_front_matter.json`
  - [x] Load `cone.css` — strip desktop-only rules (`position: fixed/absolute`, `:hover`, `@font-face`, `cursor`, form/input elements) before storing in `dict_meta.css`
  - [x] Sanitize hardcoded `color: black` and `background-color: white` from CSS so dark mode degrades gracefully
  - [x] Strip leading digits from Cone keys for `word` column
  - [x] Strip DOCTYPE wrapper from HTML, run `remove_links()` on entries with hrefs
  - [x] `definition_plain` column: add to schema but leave empty (deferred for future FTS)
  - [x] Insert Cone metadata row into `dict_meta`
  - [x] Call function from `main()` before `dest.commit()`
  - [x] Bump `DB_SCHEMA_VERSION` to 3

- [x] Task: Conductor - User Manual Verification 'Phase 1: Database Export' (Protocol in workflow.md)

## Phase 2: Flutter Database Layer [checkpoint: 767ffe8]

- [x] Task: Add Drift table definitions for `DictMeta` and `DictEntries` `99139b7`
  - [x] Add `DictMeta` table class to `lib/database/tables.dart`
  - [x] Add `DictEntries` table class to `lib/database/tables.dart`
  - [x] Register both tables in `@DriftDatabase(tables: [...])` in `database.dart`
  - [x] Bump `schemaVersion` and `requiredDbSchemaVersion` to 3
  - [x] Register both tables in `@DriftAccessor(tables: [...])` in `dao.dart`

- [x] Task: Add DAO query methods for dictionary lookups `99139b7`
  - [x] Add `searchDictExact(String word)` method returning `List<DictEntryData>`
  - [x] Add `searchDictFuzzy(String fuzzyKey, {int limit = 50})` method — prefix match on `word_fuzzy` column with LIMIT clause
  - [x] Add `getDictMeta(String dictId)` method returning `DictMetaData?`
  - [x] Add `getAllDictMeta()` method returning `List<DictMetaData>` (for settings widget)
  - [x] Results grouped by `dict_id` so provider can apply user's order/visibility preferences

- [x] Task: Run Drift code generation `99139b7`
  - [x] Run `dart run build_runner build --delete-conflicting-outputs`
  - [x] Verify generated files compile without errors

- [x] Task: Conductor - User Manual Verification 'Phase 2: Flutter Database Layer' (Protocol in workflow.md)

## Phase 3: Providers and HTML Rendering [checkpoint: 0567890]

- [x] Task: Create dictionary Riverpod providers `0567890`
  - [x] Create `lib/providers/dict_provider.dart`
  - [x] Implement `dictResultsProvider(query)` — exact match on `dict_entries.word` + fuzzy match on `word_fuzzy`
  - [x] Group results by `dict_id`, apply user's order and visibility preferences
  - [x] Implement `dictCssProvider(dictId)` — cached CSS from `dict_meta`
  - [x] Implement `dictOrderProvider` — reads/writes order and visibility JSON from SharedPreferences
  - [x] Handle graceful degradation if dict tables don't exist (try/catch on query)

- [x] Task: Create `DictHtmlCard` widget `0567890`
  - [x] Create `lib/widgets/dict_html_card.dart`
  - [x] Wrap HTML with `<style>{css}</style>{definition_html}` (uses `customStylesBuilder` instead — validated in Phase 0 PoC)
  - [x] Render via `HtmlWidget` from `flutter_widget_from_html`
  - [x] Use `DpdSectionContainer` + `HeadingUnderlined` for layout
  - [x] Add to tech-stack.md UI section

- [x] Task: Conductor - User Manual Verification 'Phase 3: Providers and HTML Rendering' — deferred to Phase 4 (no visible UI yet)

## Phase 4: Search Integration and Settings

- [ ] Task: Wire dictionary results into search screen
  - [ ] Modify `lib/screens/search_screen.dart`
  - [ ] Query `dictResultsProvider` alongside existing DPD providers
  - [ ] Show dictionary results section after DPD results, in user's chosen order
  - [ ] Render each result as a `DictHtmlCard`
  - [ ] Only show results from enabled dictionaries

- [ ] Task: Create dictionary order & visibility settings widget
  - [ ] Create `lib/widgets/dict_settings_widget.dart` — unified reorderable list
  - [ ] Each row: drag handle, dictionary name, enable/disable toggle
  - [ ] Use `ReorderableListView` for drag-to-reorder
  - [ ] Store order and visibility as JSON in SharedPreferences
  - [ ] Integrate widget into `lib/widgets/settings_panel.dart`
  - [ ] Dictionary results in search screen respect user's chosen order and visibility

- [ ] Task: Conductor - User Manual Verification 'Phase 4: Search Integration and Settings' (Protocol in workflow.md)

## Phase 5: Additional Dictionaries

- [ ] Task: Add CPD (Critical Pāli Dictionary, 29,672 entries)
  - [ ] Load `en-critical.json` (list format with HTML definitions)
  - [ ] Parse entries, generate `word`, `word_fuzzy`, `definition_html`
  - [ ] Load CPD CSS if available, store in `dict_meta`
  - [ ] Insert with `dict_id = 'cpd'`

- [ ] Task: Add DPPN (Dictionary of Pāli Proper Names, 13,642 entries)
  - [ ] Load `DPPN.json` (list format with name/entry fields)
  - [ ] Parse entries, generate `word`, `word_fuzzy`, `definition_html`
  - [ ] Insert with `dict_id = 'dppn'`

- [ ] Task: Add DPR (Digital Pali Reader compound analysis, 823,805 entries)
  - [ ] Load `dpr.json` (plain text)
  - [ ] Wrap plain text in minimal HTML
  - [ ] Insert with `dict_id = 'dpr'`

- [ ] Task: Add Simsapa combined dictionary (27,339 entries)
  - [ ] Load `simsapa.json` (Nyanatiloka + NCPED + PTS combined)
  - [ ] Parse entries, generate `word`, `word_fuzzy`, `definition_html`
  - [ ] Insert with `dict_id = 'simsapa'`

- [ ] Task: Add MW (Monier-Williams Sanskrit-English Dictionary, 194,040 entries)
  - [ ] Load `mw.json`
  - [ ] Parse entries, generate `word`, `word_fuzzy`, `definition_html`
  - [ ] Insert with `dict_id = 'mw'`

- [ ] Task: Add BHS (Edgerton's Buddhist Hybrid Sanskrit Dictionary, 17,836 entries)
  - [ ] Load `bhs.xml` (XML from Cologne Sanskrit Lexicon)
  - [ ] Parse XML entries, generate `word`, `word_fuzzy`, `definition_html`
  - [ ] Insert with `dict_id = 'bhs'`

- [ ] Task: Add Bold Definitions (CST Tipiṭaka bold definitions, 369,148 entries)
  - [ ] Load `bold_definitions.tsv`
  - [ ] Parse TSV, wrap plain text in minimal HTML
  - [ ] Insert with `dict_id = 'bold_def'`

- [ ] Task: Add ABT (Concise Pāli-English Glossary, 21,099 entries)
  - [ ] Load `CPED.csv` (pipe-delimited)
  - [ ] Parse CSV, wrap plain text in minimal HTML
  - [ ] Insert with `dict_id = 'abt'`

- [ ] Task: Add PEU (Pali English Ultimate, 23-volume Myanmar dictionary)
  - [ ] Load `peu_dump.js` (JavaScript object literal)
  - [ ] Parse JS dump, generate `word`, `word_fuzzy`, `definition_html`
  - [ ] Insert with `dict_id = 'peu'`

- [ ] Task: Add Whitney (Sanskrit Roots, 1895)
  - [ ] Load XML files from `source/*.xml`
  - [ ] Parse XML entries, generate `word`, `word_fuzzy`, `definition_html`
  - [ ] Insert with `dict_id = 'whitney'`

- [ ] Task: Add Sin-Eng-Sin (Sinhala-English-Sinhala Dictionary, 46,996 entries)
  - [ ] Load `sinhala-english.tab` and `english-sinhala.tab`
  - [ ] Parse tab-delimited, wrap in minimal HTML
  - [ ] Insert with `dict_id = 'sin_eng_sin'`

- [ ] Task: Register all new dictionaries in the order/visibility settings widget
  - [ ] Ensure all dictionaries from Phase 5 appear in the reorderable list
  - [ ] Verify order and visibility persist correctly across app restarts

- [ ] Task: Conductor - User Manual Verification 'Phase 5: Additional Dictionaries' (Protocol in workflow.md)

## Phase 6: Polish

- [ ] Task: Dark mode CSS adaptation for dictionary entries
  - [ ] Override remaining hardcoded colors based on app theme
  - [ ] Inject theme-aware CSS overrides when rendering HTML

- [ ] Task: Cross-references between dictionaries and DPD
  - [ ] Tapping a word in dictionary HTML triggers a DPD search
  - [ ] Add `onTapUrl` handler to `HtmlWidget`

- [ ] Task: Add dictionary words to DPD `lookup` table for autocomplete
  - [ ] In Python exporter, inject dictionary headwords into `lookup` table
  - [ ] Ensure autocomplete shows results from all sources

- [ ] Task: Conductor - User Manual Verification 'Phase 6: Polish' (Protocol in workflow.md)
