# Plan: Add CPD to Mobile Database Export

## Phase 1: CPD Export Test Coverage

- [x] Task: Add targeted tests for CPD mobile export behavior
    - [ ] Create `../dpd-db/tests/exporter/mobile/test_mobile_exporter.py`
    - [ ] Add a test that exports CPD sample rows into a temporary SQLite destination and verifies `dict_entries.word` stores `ṃ` instead of `ṁ`
    - [ ] Use a CPD sample headword containing `ṁ` so the test proves canonicalization to `ṃ` and fuzzy normalization from the canonicalized form
    - [ ] Add a test that verifies `word_fuzzy` is generated from the canonicalized headword, not from the raw CPD spelling
    - [ ] Add a test that verifies `<img>` tags are removed from CPD HTML before insertion
    - [ ] Add a test that verifies CPD metadata and sanitized CSS are written to `dict_meta`
    - [ ] Add a test that verifies missing CPD source data skips CPD export without failing the overall dictionary export path
    - [ ] Add a regression assertion that a full dictionary export still includes the expected Cone and MW `dict_id` values alongside CPD when their sources are present
    - [ ] Run the targeted exporter test command and confirm the new tests fail before implementation

- [x] Task: Conductor - User Manual Verification 'Phase 1: CPD Export Test Coverage' (Protocol in workflow.md)

## Phase 2: CPD Mobile Export Implementation

- [x] Task: Add direct CPD export support to `mobile_exporter.py`
    - [ ] Modify `../dpd-db/exporter/mobile/mobile_exporter.py`
    - [ ] Modify `../dpd-db/tools/paths.py` so `ProjectPaths` exposes the real CPD SQLite source path used by mobile export
    - [ ] Add a CPD stylesheet path to `../dpd-db/tools/paths.py` for mobile export use
    - [ ] Add the minimal helper logic needed to canonicalize CPD headwords from `ṁ` to `ṃ`
    - [ ] Read ordered CPD rows from the `entries` table via `ProjectPaths`, not via a hard-coded inline path
    - [ ] Remove `<img>` tags from CPD HTML before insertion into `dict_entries`
    - [ ] Generate `word_fuzzy` from the canonicalized headword using `_strip_diacritics_mobile()`
    - [ ] Load and sanitize CPD CSS via `ProjectPaths` when present
    - [ ] Insert CPD rows into `dict_entries` with `dict_id = 'cpd'`
    - [ ] Insert CPD metadata into `dict_meta` with the agreed name, author, CSS, and entry count
    - [ ] Skip CPD cleanly when the source database is missing, and fall back to empty CSS when the stylesheet is missing

- [x] Task: Verify CPD export against real source data
    - [ ] Run the targeted exporter test command again and confirm all tests pass
    - [ ] Run the mobile export command as automated implementation verification using the real CPD source
    - [ ] Inspect the exported mobile database and confirm a `dict_meta` row exists for `cpd`
    - [ ] Inspect sample `dict_entries` rows and confirm stored headwords use `ṃ`, not `ṁ`
    - [ ] Confirm Cone and MW dictionary exports are still present after the CPD export change
    - [ ] Reserve the separate Conductor manual verification task for user-facing confirmation after the automated export checks are complete

- [x] Task: Conductor - User Manual Verification 'Phase 2: CPD Mobile Export Implementation' (Protocol in workflow.md)
