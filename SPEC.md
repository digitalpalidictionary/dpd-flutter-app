# DPD Flutter App — Specification

**Version:** 0.1
**Bundle ID:** net.dpdict.app
**Platform target:** Android (primary), Chromebook (via Play Store), iOS (stretch)

---

## Overview

A native offline Flutter app for the Digital Pali Dictionary (DPD). The app combines:
- The speed and offline capability of GoldenDict
- Visual design and layout matching the webapp dictionary tab at `dpd-db/exporter/webapp`
- Native Android integration (text selection → open in DPD from any app)

### Design Reference

The **webapp dictionary middle pane** is the visual reference for colors, fonts, and layout.
Scope: middle pane only (search results + entry display). Left pane (history) and right pane
(settings sidebar) are out of scope for now.

### Color & Font

| Property | Value |
|----------|-------|
| Primary color | Cyan `hsl(198,100%,50%)` = `#00BFFF` |
| Default font | Inter (sans-serif) |
| Alternate font | Noto Serif (toggled in Settings) |

---

## Core Goals

| Goal | Detail |
|------|--------|
| **Offline-first** | Works with zero internet; DB stored in protected app storage |
| **System integration** | Text selected anywhere in Android opens DPD via ACTION_PROCESS_TEXT |
| **Speed** | Sub-100ms search response; lookup table indexed on `lookup_key` |
| **Freshness** | Monthly DB updates via GitHub Releases; app checks on launch |
| **Full entry display** | Mirrors the webapp dictionary tab: grammar, examples, inflections, families |

---

## Architecture

```
dpd-db (monthly release pipeline)
  └── scripts/build_mobile_db.py → mobile.db
        └── uploaded to GitHub Releases (dpd-flutter-app repo)

dpd-flutter-app (this repo)
  └── On first launch: downloads mobile.db → app-private storage
  └── Monthly: checks GitHub API for new release → prompts user to update
  └── All queries run against local SQLite
```

---

## Database: mobile.db

### Source
- Built from `dpd.db` (full DPD database, ~2.1 GB)
- Stripped to ~150–250 MB for mobile by removing build-time and non-essential columns

### Tables retained

#### `dpd_headwords` (stripped)
Essential columns only:

| Column | Purpose |
|--------|---------|
| `id` | Primary key |
| `lemma_1` | Headword (display title) |
| `lemma_2` | Alt form (masc. nom. sg.) |
| `pos` | Part of speech |
| `grammar` | Grammatical info |
| `derived_from` | Etymological parent |
| `neg` | Negative indicator |
| `verb` | Causative/passive type |
| `trans` | Transitive/intransitive |
| `plus_case` | Case triggered |
| `meaning_1` | Primary meaning |
| `meaning_lit` | Literal meaning |
| `meaning_2` | Buddhadatta's meaning |
| `root_key` | FK to dpd_roots |
| `root_sign` | Conjugational sign |
| `root_base` | Root + sign |
| `family_root` | Root family |
| `family_word` | Word family |
| `family_compound` | Compound components |
| `family_idioms` | Idiom components |
| `family_set` | Thematic set |
| `construction` | Word construction |
| `compound_type` | Compound type |
| `source_1`, `sutta_1`, `example_1` | First example |
| `source_2`, `sutta_2`, `example_2` | Second example |
| `antonym`, `synonym`, `variant` | Related words |
| `stem` | Inflection stem |
| `pattern` | Inflection template key |
| `inflections_html` | Pre-rendered HTML inflection table |
| `freq_html` | Pre-rendered frequency HTML |
| `ebt_count` | EBT frequency count |
| `notes` | Additional notes |
| `commentary` | Commentary definitions |

Columns **omitted** (build-time, internal, rarely needed for reading):
- `created_at`, `updated_at`, `origin`
- `inflections` (raw CSV — use `inflections_html` instead)
- `inflections_api_ca_eva_iti`, `inflections_sinhala`, `inflections_devanagari`, `inflections_thai`
- `phonetic`, `var_phonetic`, `var_text`, `link`, `cognate`
- `non_ia`, `sanskrit` (initially omitted, can add later)

#### `lookup` (full)
All columns retained — this is the search index. Entire table is ~50 MB.

| Column | Purpose |
|--------|---------|
| `lookup_key` | PRIMARY KEY — normalized search key |
| `headwords` | JSON list of DpdHeadword IDs |
| `roots` | JSON — root matches |
| `variant` | JSON — variant form matches |
| `see` | JSON — "see also" |
| `spelling` | JSON — spelling variants |
| `grammar` | Grammar references |
| `help` | Help entries |
| `abbrev` | Abbreviations |

#### `dpd_roots` (stripped)
Enough to display root info in entry.

#### `db_info`
Key-value store. Must include:
- `db_version` — semver string checked by app on launch
- `dpd_release_date` — date of this DB snapshot

---

## Search Flow

```
User types query
  → 300ms debounce
  → normalize: lowercase, strip leading/trailing whitespace
  → transliterate if Sinhala/Thai/Devanagari script
  → SELECT * FROM lookup WHERE lookup_key LIKE '<query>%' LIMIT 20
  → for each result: parse headwords JSON → collect unique IDs
  → SELECT * FROM dpd_headwords WHERE id IN (...)
  → sort by pali_sort_key(lemma_1)
  → display WordCard list
```

### Pāḷi sort order
Custom Dart comparator: standard Pāḷi alphabet order
`a ā i ī u ū e o k kh g gh ṅ c ch j jh ñ ṭ ṭh ḍ ḍh ṇ t th d dh n p ph b bh m y r l ḷ v s h`

---

## Screens

### 1. Search Screen (Home)

- **SearchBar** at top — rounded `OutlineInputBorder` with cyan border
- Placeholder: "Search Pāḷi..."
- Velthuis live conversion on each keystroke (`aa`→`ā`, `.m`→`ṃ`, etc.) via `lib/utils/velthuis.dart`
- Debounced live search (300ms)
- Loading spinner during query
- **ResultsList** — ListView of WordCard (summary only, not expanded)
- Empty state: illustration + "Type a Pāḷi word to begin"
- No-results state: "No results for '{query}'" + suggestions

### 2. Entry Screen

Full entry for a single headword. Activated by:
- Tapping a WordCard in search results
- ACTION_PROCESS_TEXT intent from external app

**Layout (single scrollable page with collapsible sections):**

```
┌──────────────────────────────┐
│ ← [Back]                     │
├──────────────────────────────┤
│  dhamma                      │  ← lemma_1 (large, bold)
│  masc. · nom. sg.            │  ← pos + grammar (small, muted)
├──────────────────────────────┤  ← cyan left-border summary box
│  masc. (dhamma)              │  ← pos (meaning_1)
│  lit. natural law (italic)   │  ← lit. meaning_lit
│  dhamma + ...                │  ← construction
├──────────────────────────────┤
│ ▶ Grammar                    │  ← ExpansionTile (default: per settings)
│ ▶ Examples                   │  ← ExpansionTile (default: per settings)
│ ▶ Inflections                │  ← ExpansionTile (default: collapsed)
│ ▶ Families                   │  ← ExpansionTile (default: collapsed)
│ ▶ Notes   (if present)       │  ← ExpansionTile (default: collapsed)
└──────────────────────────────┘
```

**Summary box** (always visible, cyan left border):
- `pos (meaning_1)`
- Literal meaning (if present): `lit. meaning_lit` (italic)
- Construction (if present): muted text

**Grammar section** (ExpansionTile):
- 2-col rows: label | value
- Fields: pos, grammar, derived_from, neg, verb, trans, plus_case, derivative, stem, pattern, root_key, root_sign, root_base, suffix, compound_type

**Examples section** (ExpansionTile):
- Example 1 block: `example_1` (HTML rendered) + citation
- Example 2 block (if present)

**Inflections section** (ExpansionTile):
- Renders `inflections_html` via `flutter_html`, horizontal scroll
- Frequency chart from `freq_html` below (if present)

**Families section** (ExpansionTile):
- Root family, word family, compound members, idioms, thematic sets, antonyms, synonyms, variants

**Notes section** (ExpansionTile, only if notes present)

### 3. Settings Screen

- **Database** section:
  - Current DB version + release date (from `db_info`)
  - "Check for updates" button
  - "Re-download database" option
  - Storage usage
- **Display** section:
  - Font size slider
  - Dark/light/system theme
  - Font style toggle: Sans-serif (Inter) / Serif (Noto Serif)
  - Grammar section default: Closed / Open
  - Examples section default: Closed / Open
- **About** section
  - App version
  - dpdict.net link
  - GitHub link

### 4. First Launch / Download Screen

Shown only if `mobile.db` not present in app storage.

- DPD logo
- "Downloading dictionary..." progress bar (percent_indicator)
- DB size estimate (~200 MB)
- Option to use online API while downloading (stretch goal)

---

## Android: Text Selection Integration

### ACTION_PROCESS_TEXT

In `android/app/src/main/AndroidManifest.xml`:

```xml
<activity android:name=".MainActivity" ...>
  <intent-filter>
    <action android:name="android.intent.action.PROCESS_TEXT" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
  </intent-filter>
</activity>
```

In `lib/main.dart` / `lib/services/intent_service.dart`:
- On app start, check for `PROCESS_TEXT` intent
- Extract `EXTRA_PROCESS_TEXT` string
- Navigate directly to Entry Screen for that word
- If no exact match, navigate to Search Screen pre-filled with the text

### Intent label
`android:label="Look up in DPD"` — appears in Android text selection popup

---

## DB Update Flow

1. On app launch (or manual "Check for updates"):
   - Call GitHub Releases API: `GET https://api.github.com/repos/digitalpalidictionary/dpd-flutter-app/releases/latest`
   - Compare `tag_name` with stored version from `db_info.db_version`
   - If newer: show banner "New dictionary available (2025-12). Download now?"
2. User confirms → download with progress indicator → replace local DB
3. Version stored in SharedPreferences for quick launch-time compare

---

## State Management

**Riverpod** (flutter_riverpod + riverpod_annotation):

| Provider | Type | Purpose |
|----------|------|---------|
| `databaseProvider` | Provider | Drift database singleton |
| `searchQueryProvider` | StateProvider | Current search string |
| `searchResultsProvider` | FutureProvider.family | Lookup results for query |
| `headwordProvider` | FutureProvider.family | Single entry by ID |
| `dbVersionProvider` | FutureProvider | Current local DB version |
| `updateAvailableProvider` | FutureProvider | GitHub latest vs local |
| `settingsProvider` | StateNotifierProvider | User preferences |

---

## Tech Stack

| Layer | Package |
|-------|---------|
| Database ORM | drift + drift_flutter |
| SQLite bindings | sqlite3_flutter_libs |
| State management | flutter_riverpod + riverpod_annotation |
| HTML rendering | flutter_html |
| HTTP client | dio |
| File paths | path_provider + path |
| Preferences | shared_preferences |
| URLs | url_launcher |
| Fonts | google_fonts |
| Progress | percent_indicator |
| Code gen | build_runner + drift_dev + riverpod_generator |

---

## File Structure

```
dpd-flutter-app/
├── SPEC.md                          ← this file
├── pubspec.yaml
├── scripts/
│   ├── build_mobile_db.py           ← Python: dpd.db → mobile.db
│   └── requirements.txt
├── assets/
│   ├── db/                          ← placeholder (real DB downloaded at runtime)
│   └── fonts/
│       ├── NotoSerif-Regular.ttf
│       └── NotoSerif-Bold.ttf
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml      ← ACTION_PROCESS_TEXT intent
└── lib/
    ├── main.dart                    ← App entry, router setup
    ├── app.dart                     ← MaterialApp, theme
    ├── router.dart                  ← go_router routes
    ├── database/
    │   ├── database.dart            ← Drift database class
    │   ├── database.g.dart          ← Generated
    │   ├── tables.dart              ← Drift table definitions
    │   └── dao.dart                 ← Data access methods
    ├── models/
    │   └── search_result.dart       ← Plain data class for search result
    ├── providers/
    │   ├── database_provider.dart
    │   ├── search_provider.dart
    │   ├── settings_provider.dart
    │   └── update_provider.dart
    ├── screens/
    │   ├── search_screen.dart
    │   ├── entry_screen.dart
    │   ├── settings_screen.dart
    │   └── download_screen.dart
    ├── widgets/
    │   ├── word_card.dart           ← Search result card
    │   ├── meaning_box.dart         ← Entry summary box
    │   ├── grammar_tab.dart
    │   ├── examples_tab.dart
    │   ├── inflections_tab.dart
    │   ├── families_tab.dart
    │   └── update_banner.dart
    ├── services/
    │   ├── db_service.dart          ← DB download / update management
    │   └── intent_service.dart      ← Android ACTION_PROCESS_TEXT handler
    └── utils/
        ├── pali_sort.dart           ← Pāḷi alphabet sort comparator
        └── transliterate.dart       ← Script detection + Romanization
```

---

## MVP Scope (v0.1)

- [x] Flutter project scaffold
- [ ] mobile.db builder (Python script)
- [ ] Drift schema + DAO
- [ ] Search screen with live search
- [ ] Entry screen with 5 tabs
- [ ] ACTION_PROCESS_TEXT intent registration
- [ ] First-launch DB download screen

## Post-MVP (v0.2+)

- [ ] Bookmarks / history
- [ ] iOS Share Sheet integration
- [ ] Floating bubble (draw-over) mode
- [ ] Full-text search across meanings
- [ ] Font size preferences
- [ ] DB update flow (GitHub API check)
- [ ] Root browser screen
- [ ] Compound family tree visualization
