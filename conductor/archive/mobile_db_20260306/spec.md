# Spec: Mobile Database Exporter + Flutter Adoption (Stage 1)

## Overview

Two-part track:

1. **dpd-db repo** — Create a Python exporter script that produces a trimmed,
   mobile-optimised `dpd-mobile.db` from the source `dpd.db`, with pre-computed
   columns that cannot be calculated at runtime in Flutter. Wire it into the
   standard dpd-db build pipeline.

2. **dpd-flutter-app repo** — Update the Flutter app to consume `dpd-mobile.db`:
   update Drift schema with new columns and update the DB filename reference.

Stage 2 (GitHub upload/download/in-app update mechanism) is deferred.

---

## Functional Requirements

### FR-1: Python Exporter Script (dpd-db repo)

- Script: `exporter/mobile/mobile_exporter.py`
- Output: `exporter/share/dpd-mobile.db`
- Reads from `dpd.db` via `ProjectPaths` (follows existing exporter conventions)
- Uses `get_db_session`, `printer`, `GlobalVars` pattern matching other exporters
- Controlled by config.ini flag `[exporter] make_mobile = yes/no`

#### `dpd_headwords` — trimmed to Flutter Drift schema + new column
Keep:
  id, lemma_1, lemma_2, pos, grammar, derived_from, neg, verb, trans, plus_case,
  meaning_1, meaning_lit, meaning_2, root_key, root_sign, root_base, family_root,
  family_word, family_compound, family_idioms, family_set, construction,
  compound_type, compound_construction, source_1, sutta_1, example_1, source_2,
  sutta_2, example_2, antonym, synonym, variant, stem, pattern, suffix,
  inflections_html, freq_html, freq_data, ebt_count, non_ia, sanskrit, cognate,
  link, phonetic, var_phonetic, var_text, origin, notes, commentary

Drop (in dpd.db but not needed on mobile):
  inflections, inflections_api_ca_eva_iti, inflections_sinhala,
  inflections_devanagari, inflections_thai, derivative, non_root_in_comps,
  created_at, updated_at

Add (computed at export time):
  lemma_ipa — IPA transcription via Aksharamukha
    `transliterate.process("IASTPali", "IPA", lemma_clean)`

#### `dpd_roots` — trimmed + new column
Keep all Flutter Drift schema columns.
Drop: matrix_test, created_at, updated_at
Add: root_count — COUNT of dpd_headwords rows with matching root_key

#### All other tables — copied as-is, no changes:
  lookup (10 cols), sutta_info (all 41 cols), family_root, family_word,
  family_compound, family_idiom, family_set, inflection_templates, db_info

### FR-2: Path Registration (dpd-db repo)

- Add `dpd_mobile_db_path` to `tools/paths.py` pointing to
  `exporter/share/dpd-mobile.db`

### FR-3: Build Pipeline Integration (dpd-db repo)

- Add `"exporter/mobile/mobile_exporter.py"` to the COMMANDS list in
  `scripts/bash/makedict.py`
- Add `export-mobile` command to `justfile`:
  `uv run python exporter/mobile/mobile_exporter.py`
- Add export step to `draft_release.yml` after other exporters
- Add `exporter/share/dpd-mobile.db` to the linux-assets upload artifact
- Add `dpd-mobile.db` to the release files in the `create-release` job

### FR-4: Flutter Drift Schema Updates (dpd-flutter-app repo)

- Add `lemma_ipa` (TEXT, nullable) to `DpdHeadwords` Drift table
- Add `root_count` (INTEGER, nullable) to `DpdRoots` Drift table

### FR-5: DB Filename Update (dpd-flutter-app repo)

- Update DB filename reference from `dpd.db` → `dpd-mobile.db` in `lib/database/`

### FR-6: justfile Updates (dpd-flutter-app repo)

- Rename `push-db` → `push-mobile-db`, update source path to
  `../dpd-db/exporter/share/dpd-mobile.db`

---

## Commit Convention

- All commits in `../dpd-db/` MUST be prefixed with `#153 `
  e.g. `git commit -m "#153 feat: add dpd_mobile_db_path to ProjectPaths"`
- Commits in `dpd-flutter-app/` follow the normal project convention (no prefix).

## Out of Scope (Stage 2)

- In-app DB update/download mechanism
- Version checking against GitHub Releases

---

## Acceptance Criteria

1. `just export-mobile` (dpd-db) produces `exporter/share/dpd-mobile.db`
2. `dpd-mobile.db` is smaller than source `dpd.db`
3. All 11 tables present with correct trimmed schemas
4. `dpd_headwords.lemma_ipa` populated for all rows
5. `dpd_roots.root_count` populated for all rows
6. `dpd-mobile.db` included in dpd-db release assets via `draft_release.yml`
7. Flutter Drift schema compiles with the two new columns
8. `just push-mobile-db` pushes the DB to an Android device via ADB
9. App loads and functions correctly with the new DB
