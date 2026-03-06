# Plan: Mobile Database Exporter + Flutter Adoption (Stage 1)

## Phase 1: Python Exporter (dpd-db repo)

- [x] Task: Add `dpd_mobile_db_path` to `tools/paths.py` [fcb0837]
- [ ] Task: Create `exporter/mobile/mobile_exporter.py` — reads dpd.db, writes trimmed `dpd-mobile.db` to `exporter/share/`
- [ ] Task: Implement `dpd_headwords` table copy — drop unused columns
- [ ] Task: Implement `lemma_ipa` computed column via Aksharamukha transliteration
- [ ] Task: Implement `dpd_roots` table copy — drop unused columns + compute `root_count`
- [ ] Task: Implement pass-through copy for all remaining tables (lookup, sutta_info, family_*, inflection_templates, db_info)
- [ ] Task: Run `just export-mobile` locally and verify output
- [ ] Task: Conductor - User Manual Verification 'Phase 1' (Protocol in workflow.md)

## Phase 2: Build Pipeline Integration (dpd-db repo)

- [ ] Task: Add `export-mobile` command to dpd-db `justfile`
- [ ] Task: Add `"exporter/mobile/mobile_exporter.py"` to `scripts/bash/makedict.py` COMMANDS list
- [ ] Task: Add export step to `draft_release.yml` and include `dpd-mobile.db` in linux-assets upload and release files
- [ ] Task: Conductor - User Manual Verification 'Phase 2' (Protocol in workflow.md)

## Phase 3: Flutter Schema & DB Reference Updates (dpd-flutter-app repo)

- [ ] Task: Add `lemma_ipa` (TEXT nullable) column to `DpdHeadwords` Drift table
- [ ] Task: Add `root_count` (INTEGER nullable) column to `DpdRoots` Drift table
- [ ] Task: Update DB filename from `dpd.db` to `dpd-mobile.db` in `lib/database/`
- [ ] Task: Regenerate Drift code (`dart run build_runner build`)
- [ ] Task: Rename `push-db` → `push-mobile-db` in justfile, update source path
- [ ] Task: Conductor - User Manual Verification 'Phase 3' (Protocol in workflow.md)
