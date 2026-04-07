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

## Transliteration (2026-04-07)
Input transliteration uses `indic_transliteration_dart` (pure Dart, no FFI). Users can type in any auto-detected Brahmic or romanization script; input is converted to IAST before DB lookup. The search bar always displays what the user typed. Velthuis sequences (aa→ā, .t→ṭ, etc.) convert live in the text field. FFI-based packages are avoided on Android due to 16 KB ELF alignment requirements on Android 15+.

## Search Performance (2026-04-05)
The `lookup` table in the mobile DB uses `lookup_key` as a PRIMARY KEY (created by `mobile_exporter.py`). This provides O(1) exact lookups. Partial and fuzzy searches use range queries (`>=` and `<`) instead of `LIKE` to leverage the B-tree index. Benchmarks against the full 860MB DB (1.27M lookup entries):
- Exact match: ~50μs
- Partial match: 200-250μs
- Fuzzy match: 75-90μs
