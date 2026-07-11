# Tech Notes

## Tools & Platforms
This project is a Flutter and Dart app that uses SQLite through Drift and Riverpod for state management. Android is the first priority, and the project is intended to support all major operating systems over time, including mobile, desktop, and web targets already present in the codebase.

## Who This Is For
This app is for monastics, scholars, students, and meditators interested in ancient Buddhist texts.

## Constraints
The main priority is fast startup, fast search, and reliable self-updates for both the app and the database. New work should support those goals rather than slow them down.

## Resources
The project already has an existing Flutter codebase, platform scaffolding, tests, release automation, and a sibling `dpd-db` repository used for database work.

## What The Output Looks Like
The output is a fast dictionary app, starting with Android first, that gives users access to the latest DPD database and related Pali and Sanskrit dictionaries, with broader operating system support over time.

## Transliteration (2026-04-12)
Input transliteration uses a custom stack imported from the sibling `../tipitaka-pali-reader` repo (`lib/utils/pali_transliterator/`). Script detection and script-to-Roman conversion cover all major Buddhist scripts (Sinhala, Devanagari, Thai, Myanmar, Khmer, Bengali, and more). Roman input returns unchanged immediately. Velthuis sequences (aa→ā, .t→ṭ, etc.) convert live in the text field. All other script normalization happens only for DB lookup without overwriting the user's typed script. A `searchBarTextProvider` (nullable `String?`) lets intent/share entry points set the original-script display text separately from the romanized lookup query — it is cleared after one use by the search screen listener.

## Search Performance (2026-04-05)
The `lookup` table in the mobile DB uses `lookup_key` as a PRIMARY KEY (created by `mobile_exporter.py`). This provides O(1) exact lookups. Partial and fuzzy searches use range queries (`>=` and `<`) instead of `LIKE` to leverage the B-tree index. Benchmarks against the full 860MB DB (1.27M lookup entries):
- Exact match: ~50μs
- Partial match: 200-250μs
- Fuzzy match: 75-90μs

## Change Log Asset (2026-04-12)
The in-app change log is generated at build time from local git tags and commit subjects by `tool/generate_changelog.dart`, which writes `assets/help/changelog.json`. Standard local build/run Just recipes and `.github/workflows/release.yml` regenerate that asset before packaging so the shipped app never depends on runtime git access or GitHub API calls.

## External Dictionaries & English WordNet (2026-07-11)
External (non-DPD) dictionaries are not app code: the app auto-discovers any dictionary present in the mobile DB's `dict_meta`/`dict_entries` tables (built by `../dpd-db/exporter/mobile/mobile_exporter.py`) and renders (`flutter_widget_from_html`), searches, and toggles it with no Flutter changes. Open English WordNet (English–English, `dict_id = "wordnet"`, CC BY 4.0) is included this way. Attribution for CC-licensed dictionaries must live in `dict_meta.name` (shown in the UI) — the app never renders `dict_meta.author`. Inclusion is gated by a `--wordnet` exporter flag: local `just build-db` passes it (default on), while dpd-db's `mobile_release.yml` gates it behind a `workflow_dispatch` input (default off), so the public released DB omits it unless explicitly requested. The source data is generated once by `../dpd-db/resources/other-dictionaries/dictionaries/wordnet/wordnet_to_json.py` (uses the `wn` library, build-time only) and committed as `wordnet.tar.zst`; `other-dictionaries` is a git submodule, so CI needs the submodule commit pushed and its pointer bumped before `include_wordnet=true` works.
