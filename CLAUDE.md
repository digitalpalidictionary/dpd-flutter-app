# CLAUDE.md - Project-specific instructions

## Commit Convention

**CRITICAL:** Use `conductor:` prefix for ALL conductor-related commits, NOT `chore:`.

- `conductor:` - Conductor framework updates (plan.md, tracks.md, phase/task tracking, checkpoints)
- `feat:` - New features
- `fix:` - Bug fixes
- `refactor:` - Code restructuring
- `test:` - Adding/updating tests
- `docs:` - Documentation only
- `style:` - Formatting only

### One thing, one commit
**CRITICAL:** All changes for a single feature, fix, or improvement MUST be grouped into ONE commit — never spread across multiple small commits.

The commit **subject line** must describe the user-facing idea in plain language. Technical details (what changed, why, how) go in the commit **body**.

**BAD:** `fix: delta is now 500ms` — tells a user nothing
**GOOD:** `fix: improved double-tap word search sensitivity` — instantly meaningful

Commit messages appear in the app's release notes. Users read them. Every commit subject must answer: *"What does this mean for me as a user?"*

### Examples
```bash
git commit -m "conductor: mark track 'X' as complete"
git commit -m "conductor: checkpoint end of Phase 1"
git commit -m "conductor: completed phase 1 of restyle"
git commit -m "feat: added webapp style parity"
git commit -m "fix: inflection button naming"
git commit -m "fix: improved double-tap word search sensitivity

Increased double-tap detection window from 300ms to 500ms and
fallback timer from 300ms to 400ms to match the OS default and
accommodate slower devices."
```

## DPD Database Reference

The DPD database and webapp exporter are in the sibling folder: `../dpd-db/`

Key paths:
- Database: `../dpd-db/dpd.db`
- Python DB models: `../dpd-db/db/models.py` (DpdHeadword, DpdRoot definitions)
- Webapp templates: `../dpd-db/exporter/webapp/templates/`
- Webapp CSS: `../dpd-db/exporter/webapp/static/dpd.css`
- Python tools: `../dpd-db/tools/` (meaning_construction.py, lemma_traditional.py, etc.)

When implementing webapp parity, compare against:
- Template: `exporter/webapp/templates/dpd_headword.html` (lines 995-1175 for grammar table)
- CSS: `exporter/webapp/static/dpd.css`

## Database Notes

When rebuilding the DPD database, add these computed fields:
- `dpd_roots.root_count`: COUNT of headwords with each root
- `dpd_headwords.lemma_ipa`: IPA transcription via Aksharamukha (`transliterate.process("IASTPali", "IPA", lemma_clean)`)

See `lib/database/tables.dart` for details.

## UI Architecture Notes

### Section Containers
All entry sections (grammar, examples, inflections, families, etc.) MUST use:
- `DpdSectionContainer` - provides outer border/margin (the "dpd content" div equivalent)
- Inner content padding: 16px all around (consistent with GrammarTable)

### Theme Colors
**NEVER** use hardcoded colors (`Colors.white`, `Colors.blue`, etc.). Always use `Theme.of(context).colorScheme` values (e.g. `colorScheme.primary`, `colorScheme.onPrimary`, `colorScheme.surface`). The app's theme is defined in `lib/theme/dpd_colors.dart` and applied via `ColorScheme` in `lib/app.dart`.

### Footer Widget
Use `DpdFooter` for all section footers with feedback links:
- Provides consistent styling matching webapp `.dpd-footer` CSS
- Pass `messagePrefix`, `linkText`, and `urlBuilder` for customization
