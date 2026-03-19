# Specification: External Dictionary Integration (Cone's Dictionary of Pāli)

## Overview

Integrate external Pāli dictionaries into the DPD Flutter app, starting with Margaret Cone's "A Dictionary of Pāli" (37,395 entries). Dictionary entries are stored as HTML with CSS styling and rendered directly using `flutter_widget_from_html`. Data is added to the existing `dpd-mobile.db` via the `mobile_exporter.py` pipeline — no separate database files.

**Note**: Using `flutter_widget_from_html` for external dictionary rendering is an explicit exception to the project's "no HTML widgets" rule. External dictionaries exist only as HTML — there is no structured alternative, and converting 37,395+ entries to native widgets is impractical.

## Background

- Cone's dictionary source: `../dpd-db/resources/other-dictionaries/dictionaries/cone/source/cone_dict.json` (key-value JSON, values are HTML strings)
- Companion CSS: `../dpd-db/resources/other-dictionaries/dictionaries/cone/cone.css` (styling for orange lemma headwords, italic POS, superscript homonyms, small-caps abbreviations, etc.)
- Processing reference: `../dpd-db/resources/other-dictionaries/dictionaries/cone/cone.py` (existing `make_synonyms_list()`, `remove_links()`)
- Front matter: `../dpd-db/resources/other-dictionaries/dictionaries/cone/source/cone_front_matter.json`

## Functional Requirements

### FR0: HTML Rendering Proof-of-Concept
- Before building the full pipeline, validate that `flutter_widget_from_html` renders Cone entries acceptably
- Test with simple, large, and Devanagari/Kharosthi entries
- Verify key CSS features: orange lemma, italic POS, superscript homonyms, bold subsense headwords, small-caps
- Test in both light and dark mode
- Identify desktop-only CSS rules that need stripping (`position: fixed`, `:hover`, `@font-face`, `cursor`, form elements)

### FR1: Database Export (Python side)
- Extend `mobile_exporter.py` with `export_other_dictionaries()` function
- Create `dict_meta` table: `dict_id` (PK), `name`, `author`, `css`, `entry_count`
- Create `dict_entries` table: `id` (PK), `dict_id`, `word`, `word_fuzzy`, `definition_html`, `definition_plain`
- Index on `(dict_id, word)` and `(dict_id, word_fuzzy)` for fast lookups
- Generate `word_fuzzy` using the existing `_strip_diacritics_mobile()` function (strips diacritics, removes aspirates like `kh→k`, collapses double consonants) — same logic as `lookup.fuzzy_key`
- Strip leading digits from Cone keys (e.g., `"1a"` → `"a"`) for the `word` column
- Store raw HTML body (no DOCTYPE wrapper) in `definition_html`
- `definition_plain`: add column to schema but leave empty (deferred for future FTS)
- Strip desktop-only CSS rules and sanitize hardcoded `color: black` / `background-color: white` from CSS before storing in `dict_meta.css` — ensures dark mode degrades gracefully
- Bump `DB_SCHEMA_VERSION` to 3

### FR2: Flutter Database Layer
- Add `DictMeta` and `DictEntries` Drift table definitions
- Register tables in `AppDatabase` and `DpdDao`
- Bump `schemaVersion` and `requiredDbSchemaVersion` to 3 (this forces a re-download for existing users, which is the intended upgrade path)
- DAO methods: `searchDictExact(word)`, `searchDictFuzzy(fuzzyKey, {limit: 50})`, `getDictMeta(dictId)`, `getAllDictMeta()`
- Fuzzy search must use a LIMIT clause to prevent UI stutter on short prefixes
- Run Drift code generation

### FR3: Flutter Providers
- `dictResultsProvider(query)` — queries `dict_entries` for exact + fuzzy match, groups results by `dict_id`, applies user's order and visibility preferences
- `dictCssProvider(dictId)` — caches CSS from `dict_meta`
- `dictOrderProvider` — reads/writes dictionary order and visibility from SharedPreferences
- Graceful degradation: try/catch on queries if dict tables don't exist

### FR4: HTML Rendering
- Add `flutter_widget_from_html` dependency
- Create `DictHtmlCard` widget that wraps HTML in `<style>{css}</style>{html}` and renders via `HtmlWidget`
- Use `DpdSectionContainer` + `HeadingUnderlined` for consistent styling

### FR5: Search Integration
- Show dictionary results after DPD results in search screen, in user's chosen order
- Only show results from enabled dictionaries
- Query `dictResultsProvider` alongside existing DPD providers

### FR6: Dictionary Settings (Order & Visibility)
- A unified settings widget that shows all installed dictionaries in a reorderable list
- Each dictionary row has: drag handle (for reorder), dictionary name, and enable/disable toggle
- User can drag dictionaries up/down to control the display order in search results
- User can toggle each dictionary on/off independently
- Order and visibility preferences persist via SharedPreferences
- Default order follows the order dictionaries were added; all enabled by default

## Non-Functional Requirements

- Graceful degradation: if `dict_meta`/`dict_entries` tables don't exist (older DB), don't crash — use try/catch on queries
- Generic schema: `dict_id` column supports multiple dictionaries in future phases
- No changes to existing DPD search behavior
- Search performance: fuzzy queries must use LIMIT to stay responsive

## Acceptance Criteria

1. Running `mobile_exporter.py` produces `dict_entries` with ~37,395 Cone rows and 1 `dict_meta` row
2. Searching "dhamma" in the Flutter app shows Cone results with proper HTML formatting (orange lemma, italic text, bold subsense headwords)
3. Dictionary settings widget allows reordering and enabling/disabling each dictionary
4. Search results reflect the user's chosen order and visibility
5. App works normally if dictionary tables are absent (older DB version)
6. HTML rendering proof-of-concept validates `flutter_widget_from_html` handles Cone's CSS acceptably

## Future Phases (in scope, deferred)

- **Phase 5 — All remaining dictionaries**: CPD (29,672), DPPN (13,642), DPR (823,805), Simsapa combined (27,339), MW Monier-Williams (194,040), BHS Edgerton (17,836), Bold Definitions (369,148), ABT (21,099), PEU (250k+), Whitney Sanskrit Roots, Sin-Eng-Sin (46,996)
- **Phase 6 — Polish**: Dark mode CSS adaptation, cross-references (tap word in dictionary → DPD search), dictionary words in DPD `lookup` table for autocomplete

## Out of Scope

- Separate download mechanism for dictionary data
- Full-text search within dictionary definitions (deferred — `definition_plain` column reserved for this)
