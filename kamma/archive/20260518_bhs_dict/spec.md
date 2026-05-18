# Spec — Add Edgerton's BHS Dictionary to Mobile

## Overview
Add Franklin Edgerton's *Buddhist Hybrid Sanskrit Dictionary* (1953) as a new
bundled dictionary in the DPD Flutter app, wired through the existing
`dict_meta` / `dict_entries` infrastructure used by MW, CPD, and Cone.

## What it should do
- The mobile DB exporter (`../dpd-db/exporter/mobile/mobile_exporter.py`)
  parses `bhs.xml`, builds HTML entries, and inserts rows into
  `dict_meta` (one) and `dict_entries` (one per H1 entry) with `dict_id='bhs'`.
- BHS is included by default, like MW (no CLI flag).
- The app automatically picks up BHS via existing data-driven flow:
  - Appears in `DictSettingsWidget` for visibility/ordering.
  - Entries render through `DictHtmlCard` using the shared style builder.
- Inline `<div n="lb">…</div>` line-break wrappers are flattened into space
  so wrapped lines flow naturally on mobile.
- The leading `¦` marker that follows the bold headword in the source is removed.
- HTML `<H1>` tags are stripped — only `<body>` content stored.
- No niggahita synonym expansion (mobile already does diacritic-strip fuzzy match).

## Assumptions & uncertainties
- BHS uses Cologne-style markup (`<b>`, `<i>`, plain `<div>`, `<H1>`, classes
  rarely needed). Most existing class rules in `dict_html_card.dart` will apply.
  May need small additions once rendering is verified — treated as a
  follow-up if it surfaces.
- No `bhs.css` file exists in `../dpd-db/resources/.../bhs/` — the source has
  no companion stylesheet (confirmed by `bhs.py` passing `css_paths=None`).
  `dict_meta.css` for BHS will be empty.
- DB schema does not change — only new rows in existing tables — so
  `DB_SCHEMA_VERSION` does **not** need to bump.
- `slp1_translit` is available at `tools.sanskrit_translit` in `dpd-db`.

## Repo context
- BHS source: `../dpd-db/resources/other-dictionaries/dictionaries/bhs/source/bhs.xml`
- Reference parser: `../dpd-db/resources/other-dictionaries/dictionaries/bhs/bhs.py`
- Path constant: `g.pth.bhs_source_path` (already defined in `tools/paths.py:315`)
- Mobile exporter: `../dpd-db/exporter/mobile/mobile_exporter.py`
- App entry renderer: `lib/widgets/dict_html_card.dart`
- App data flow: `lib/providers/dict_provider.dart`, `lib/database/dao.dart`
- App tables: `lib/database/tables.dart` (`dict_meta`, `dict_entries`)

## Constraints
- Do not change Drift schema — keep DB schema version stable.
- Follow MW pattern in `export_other_dictionaries()` exactly.
- Do not touch unrelated dictionary sections (Cone/CPD/MW unchanged).

## How we'll know it's done
- `uv run -m exporter.mobile.mobile_exporter` (in `../dpd-db/`) runs without
  errors and the resulting `dpd_mobile.db` contains a `bhs` row in
  `dict_meta` and N entries in `dict_entries` where N matches the H1 count.
- After dropping the new DB into app assets, the app shows "Edgerton's
  Buddhist Hybrid Sanskrit Dictionary 1953" in dictionary settings.
- Searching for a BHS-only word (e.g. `aṃśa`) returns the BHS entry in the
  results, with formatting that's readable on mobile.

## What's not included
- No new CSS class rules in `dict_html_card.dart` unless verification reveals
  unreadable output; minor follow-up tweak only if needed.
- No niggahita synonym expansion.
- No changes to webapp.
