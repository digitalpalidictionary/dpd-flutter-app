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
