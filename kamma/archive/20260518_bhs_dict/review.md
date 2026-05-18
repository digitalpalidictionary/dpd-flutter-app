## Thread
- **ID:** 20260518_bhs_dict
- **Objective:** Add Edgerton's Buddhist Hybrid Sanskrit (BHS) dictionary to the mobile DB exporter and wire it into the Flutter app like MW.

## Files Changed
- `../dpd-db/exporter/mobile/mobile_exporter.py` — added `BeautifulSoup` + `slp1_translit` imports and a BHS export block in `export_other_dictionaries()` that parses `bhs.xml`, transliterates SLP1 headwords, unwraps `<div n="lb">` line-break wrappers, strips `¦` markers, and inserts 17,836 entries into `dict_entries` plus one `dict_meta` row.

App side: no code changes required — the dictionary surface is data-driven, so BHS appears automatically once its rows are in `dict_meta` / `dict_entries`.

## Findings
No findings. Mirrors the MW pattern exactly, uses existing path constants and helpers, no schema bump needed.

## Fixes Applied
None.

## Test Evidence
- Direct invocation of `export_other_dictionaries` against the full DPD source produced `entry_count = 17836` for `dict_id='bhs'`.
- Sampled 3 random rows — `anuparivartati`, `Dhanunāśa`, `Arcirmaṇḍalagātra` — all clean HTML, no `<H1>`/`<body>` wrappers, no `¦`, fuzzy keys correctly diacritic-stripped.
- User confirmed end-to-end on Android: BHS appears in dictionary settings with correct name + count, BHS-only words return results, rendering is readable.

## Verdict
PASSED
- Review date: 2026-05-18
- Reviewer: kamma (inline)
