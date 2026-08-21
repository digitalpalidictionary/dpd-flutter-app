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

**CRITICAL: The DPD database uses empty strings `''` for missing values — there are no NULLs.** Never filter with `.isNotNull()` alone; always also exclude empty strings with `.isNotValue('')`. Use `isNotEmpty` checks in Dart-side code, not null checks.

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

### Dependencies
When `pubspec.yaml` changes, run `flutter pub get` to refresh dependencies and `pubspec.lock`. Never edit `pubspec.lock` manually.

### Footer Widget
Use `DpdFooter` for all section footers with feedback links:
- Provides consistent styling matching webapp `.dpd-footer` CSS
- Pass `messagePrefix`, `linkText`, and `urlBuilder` for customization

### Search Bar Display Text
The search bar (`_controller`) must never be overwritten by transliteration or query normalization. Only Velthuis live conversion may rewrite the field. Use `_suppressProviderSync` (or equivalent flag) to prevent provider→controller sync from clobbering the user's original script when a local search fires.

### External Entry Points
When reviewing any search or navigation change, explicitly verify all external entry points: share intents (`intentStream`), lookup intents (`lookupStream`), CLI args (`_IntentBoot`), and deep links (`dpd://word/<word>`, also routed through `intentStream`). These bypass the normal typing flow and must be tested separately. On external cold start the query can be set *before* `SearchScreen` mounts, so the `searchQueryProvider` change-listener never fires for it — the screen seeds the field in an `initState` post-frame callback. Never write to a Riverpod provider during `initState`/`build` (it crashes with a red screen); always defer such writes to `addPostFrameCallback` guarded by `mounted`.

Testing the `dpd://` deep link's `BROWSABLE` category requires a real hosted webpage tap — `adb shell am start -d 'dpd://...'` only tests the intent-filter resolution, not the browser path. `data:`/`file://` URIs opened directly in Chrome don't work either (Chrome blocks `file://` intents; `data:` URIs get mangled by `adb shell`'s remote re-parsing). Serve a tiny HTML file with a real `<a href="dpd://...">` link via a local HTTP server + `adb reverse`, then tap it on-device.

### Two Search Paths — Always Update Both
**CRITICAL:** The app has two independent text-cleaning paths. Any change to one MUST be applied to the other:
- **Tap-to-search**: `_cleanPali()` in `lib/widgets/tap_search_wrapper.dart`
- **Share/intent**: `IntentService._clean()` in `lib/services/intent_service.dart`

These paths diverged in history and caused a bug where bracket stripping was added to tap-to-search but missed in share/intent. Never fix or extend one without checking the other.

### Display Transforms Must Not Reach Stored Data
**CRITICAL:** Tap-to-search reads the **rendered** string — `RenderParagraph.text.toPlainText()` in `_getWordAtPosition` — not the underlying data. Anything that changes how Pāḷi is *displayed* therefore flows straight back into the search query and into `historyProvider`, which persists to SharedPreferences.

The database stores the dot niggahīta `ṃ` exclusively. Display may show `ṁ` (the user's setting), but every path back into data must fold to canonical first:
- `context.nigg(text)` (`lib/utils/text_filters.dart`) converts **for display only** — at the `Text`/`TextSpan`/`label:` call, never on a model field, map key, navigation argument, or feedback payload.
- `canonicalNiggahita(text)` folds back, and must be applied wherever displayed text re-enters the data layer: `_cleanPali`, `IntentService._clean`, and the search screen's query construction.
- `DpdDao._foldNiggahita` is the last line of defence on every query path. Do not replace it with `_normalizePunctuation`, which also strips hyphens and apostrophes and would change which external dictionary entries match.

Before adding any new display transform, trace every place rendered output is read back as input.

### Fuzzy Keys Must Match The Exporter Byte-For-Byte
**CRITICAL:** `stripDiacritics()` in `lib/utils/diacritics.dart` reimplements `_strip_diacritics_mobile()` in `../dpd-db/exporter/mobile/mobile_exporter.py`, which generates the stored `word_fuzzy` and `fuzzy_key` columns. Any query that computes a key in Dart and matches it against those columns breaks silently — no error, just zero results — the moment the two disagree.

The Python side drops *every* Unicode combining mark via NFD decomposition; the Dart side uses an explicit codepoint map, which can only ever be a closed subset. Sanskrit letters (`ś`, `ṣ`, `ṛ`) were missing once and broke exact lookups for 12% of all dictionary entries, including a quarter of Apte.

When changing either implementation, verify parity **across the whole built database**, not with sample words — port the Dart algorithm and compare against every row of `dict_entries` and `lookup`. Hand-picked examples will be Pāḷi, and Pāḷi is the subset that already works.

### Generated Files — Never Edit By Hand
`assets/help/changelog.json` is generated at build time from commit subject lines. Never edit it manually; write a good commit subject instead. This is why commit subjects must read as user-facing release notes.

### External Dictionary Attribution
The app renders only `dict_meta.name` (in the dictionary list and on each result card); it never renders `dict_meta.author`. For any CC-licensed external dictionary, the required attribution MUST be placed in `dict_meta.name` (set in `../dpd-db/exporter/mobile/mobile_exporter.py`), not `author`.
