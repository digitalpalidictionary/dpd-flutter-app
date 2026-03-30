# Specification: Add CPD to Mobile Database Export

## Overview

Add the Critical Pali Dictionary (CPD) to the mobile database export pipeline in `dpd-db` so the Flutter app can ship and search CPD entries alongside the existing mobile-exported external dictionaries.

This feature should consume CPD directly from `../dpd-db/resources/other-dictionaries/dictionaries/cpd/source/cpd_clean.db` during mobile export. CPD headwords must be canonicalized from `ṁ` to `ṃ` before insertion into the mobile dictionary tables so search behavior is consistent with the app's existing query normalization.

## Background

- Mobile export entry point: `../dpd-db/exporter/mobile/mobile_exporter.py`
- Existing mobile-exported external dictionaries: Cone and MW
- CPD source database: `../dpd-db/resources/other-dictionaries/dictionaries/cpd/source/cpd_clean.db`
- CPD stylesheet: `../dpd-db/resources/other-dictionaries/dictionaries/cpd/cpd.css`
- Standalone CPD exporter reference: `../dpd-db/resources/other-dictionaries/dictionaries/cpd/cpd.py`

## Functional Requirements

### FR1: Source Ingestion
- The mobile exporter must read CPD entries directly from `cpd_clean.db`
- The implementation must update `../dpd-db/tools/paths.py` so CPD mobile export uses a real SQLite source path instead of the stale `en-critical.json` path
- Source rows must be read in stable order from the `entries` table
- The exporter must preserve one mobile row per source article, including repeated headwords and homonym entries

### FR2: Headword Normalization
- CPD headwords must be canonicalized from `ṁ` to `ṃ` before storage in `dict_entries.word`
- `word_fuzzy` must be generated from the canonicalized headword using the existing `_strip_diacritics_mobile()` helper
- The implementation must not create duplicate alias rows for `ṁ`, `ṃ`, or `ŋ`

### FR3: Definition HTML Handling
- The exporter must store CPD HTML in `dict_entries.definition_html`
- `<img>` tags must be removed before storage
- `definition_plain` may remain empty for now

### FR4: Dictionary Metadata
- The exporter must add a `dict_meta` row for CPD with:
  - `dict_id = "cpd"`
  - `name = "Critical Pali Dictionary"`
  - `author = "V. Trenckner et al."`
  - `entry_count` equal to the number of inserted CPD rows
- The implementation must add a CPD stylesheet path to `../dpd-db/tools/paths.py` for mobile export use
- The exporter must load `cpd.css`, sanitize it with the existing mobile CSS sanitization logic, and store the result in `dict_meta.css`

### FR5: Failure Handling
- If the CPD source database is missing, the exporter must skip CPD export cleanly and continue the broader mobile export process
- If `cpd.css` is missing, CPD entries must still export with empty CSS rather than failing the entire export
- Existing Cone and MW export behavior must remain unchanged

## Non-Functional Requirements

- Keep the implementation minimal and localized to the existing mobile export pipeline where practical
- Reuse existing helper logic and export patterns already present for other dictionaries
- Preserve current mobile app search behavior and avoid unnecessary schema changes
- Add focused automated tests for data transformation and export behavior

## Acceptance Criteria

1. Running the mobile exporter with CPD source data present inserts CPD rows into `dict_entries`
2. Running the mobile exporter with CPD source data present inserts one CPD row into `dict_meta`
3. Exported CPD headwords are stored with `ṃ` instead of `ṁ`
4. Exported CPD `word_fuzzy` values are derived from the canonicalized headword
5. Exported CPD HTML does not contain `<img>` tags
6. Exported CPD CSS is sanitized before storage in the mobile database
7. Missing CPD source data does not crash the mobile export; CPD is skipped with a clear message
8. Existing Cone and MW mobile export behavior remains unchanged, and their exported `dict_id` rows are still present after a full export

## Out of Scope

- Generating an intermediate CPD JSON file for mobile export
- Changing Flutter app schema or app-side dictionary search behavior
- Adding duplicate alias rows for alternate niggahita spellings
- Expanding this track to other dictionaries such as DPPN or DPR
