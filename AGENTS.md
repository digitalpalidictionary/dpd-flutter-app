# Project-specific instructions

## Commit Convention

**CRITICAL:** NEVER commit unless the user explicitly asks you to. Always wait for instruction.

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

Commit messages appear in the app's release notes. Users read them. Every commit subject must answer: *"What does this mean for me as a user?"*

### Good examples from this project's history
```
feat: search results now show partial and fuzzy matches in labeled tiers
fix: inflection table forms start grey instead of flashing white
fix: startup screen now opens more smoothly
fix: app now starts offline with an existing database
fix: prevent "No results" flashing during search
```

### Bad examples from this project's history
```
db: bump db schema version          ← technical, tells user nothing
fix: another attempt to fix summary ← "another attempt" is meaningless
conductor: udpate plans             ← typo; fine for conductor but proofread
```

### Commit with body for context
```bash
git commit -m "fix: improved double-tap word search sensitivity

Increased double-tap detection window from 300ms to 500ms and
fallback timer from 300ms to 400ms to match the OS default and
accommodate slower devices."
```

## DPD Database Reference

The DPD database and webapp exporter are in the sibling folder: `../dpd-db/`

When running project scripts inside `../dpd-db/`, use `uv run ...` rather than raw `python ...`.

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

### Reuse Existing Patterns
**ALWAYS** search the codebase for existing solutions before building new ones. If the app already has a pattern for tooltips, dialogs, popups, or any UI component, copy that exact pattern — same widget, same styling, same configuration. Never reinvent a solution for an already-solved problem.

### Behavior-Parity Fixes
When a request says one interaction should work exactly like an existing one, keep the change strictly limited to that behavior path. Do not alter adjacent state updates, history recording, or cleanup behavior unless the user explicitly asks for it.

### Testing
Do not add UI tests for this app. Add tests only for data logic and other non-UI behavior.

### Footer Widget
Use `DpdFooter` for all section footers with feedback links:
- Provides consistent styling matching webapp `.dpd-footer` CSS
- Pass `messagePrefix`, `linkText`, and `urlBuilder` for customization

### Search Bar Display Text
The search bar (`_controller`) must never be overwritten by transliteration or query normalization. Only Velthuis live conversion may rewrite the field. Use `_suppressProviderSync` (or equivalent flag) to prevent provider→controller sync from clobbering the user's original script when a local search fires.
