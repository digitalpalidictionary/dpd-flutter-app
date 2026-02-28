# CLAUDE.md - Project-specific instructions

## Commit Convention

- `conductor:` - Conductor framework updates (plan.md, tracks.md, phase/task tracking, checkpoints)
- `feat:` - New features
- `fix:` - Bug fixes
- `refactor:` - Code restructuring
- `test:` - Adding/updating tests
- `docs:` - Documentation only
- `style:` - Formatting only

### Examples
```bash
git commit -m "conductor: mark track 'X' as complete"
git commit -m "conductor: checkpoint end of Phase 1"
git commit -m "conductor: completed phase 1 of restyle"
git commit -m "feat: added webapp style parity"
git commit -m "fix: inflection button naming"
```

## Database Notes

When rebuilding the DPD database, add these computed fields:
- `dpd_roots.root_count`: COUNT of headwords with each root
- `dpd_headwords.lemma_ipa`: IPA transcription via Aksharamukha (`transliterate.process("IASTPali", "IPA", lemma_clean)`)

See `lib/database/tables.dart` for details.
