# Plan: Mobile Database Exporter + Flutter Adoption (Stage 1)

## Phase 1: Python Exporter (dpd-db repo)

- [x] Task: Add `dpd_mobile_db_path` to `tools/paths.py` [fcb0837]
- [x] Task: Create `exporter/mobile/mobile_exporter.py` — reads dpd.db, writes trimmed `dpd-mobile.db` to `exporter/share/` [8ca4a01]
- [x] Task: Implement `dpd_headwords` table copy — drop unused columns [8ca4a01]
- [x] Task: Implement `lemma_ipa` computed column via Aksharamukha transliteration [8ca4a01]
- [x] Task: Implement `dpd_roots` table copy — drop unused columns + compute `root_count` [8ca4a01]
- [x] Task: Implement pass-through copy for all remaining tables (lookup, sutta_info, family_*, inflection_templates, db_info) [8ca4a01]
- [x] Task: Run `just export-mobile` locally and verify output [8ca4a01]

## Phase 2: Build Pipeline Integration (dpd-db repo)

- [x] Task: Add `export-mobile` command to dpd-db `justfile` [3b65be7]
- [x] Task: Add `"exporter/mobile/mobile_exporter.py"` to `scripts/bash/makedict.py` COMMANDS list [3b65be7]
- [x] Task: Add export step to `draft_release.yml` and include `dpd-mobile.db` in linux-assets upload and release files [3b65be7]

## Phase 3: Flutter Schema & DB Reference Updates (dpd-flutter-app repo)

- [x] Task: Add `lemma_ipa` (TEXT nullable) column to `DpdHeadwords` Drift table [3f22f5c]
- [x] Task: Add `root_count` (INTEGER nullable) column to `DpdRoots` Drift table [3f22f5c]
- [x] Task: Update DB filename from `dpd.db` to `dpd-mobile.db` in `lib/database/` [3f22f5c]
- [x] Task: Regenerate Drift code (`dart run build_runner build`) [3f22f5c]
- [x] Task: Rename `push-db` → `push-mobile-db` in justfile, update source path [3f22f5c]
- [ ] Task: Conductor - User Manual Verification 'Phase 3' (Protocol in workflow.md)
