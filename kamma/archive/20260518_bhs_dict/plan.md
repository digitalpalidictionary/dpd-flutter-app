# Plan — Add Edgerton's BHS Dictionary to Mobile

## Architecture Decisions
- **Mirror MW block structure** in `export_other_dictionaries()`. Same shape:
  guard on source path existence → parse → loop → executemany → insert
  meta row.
- **Parse XML inline** in `mobile_exporter.py` (BeautifulSoup) rather than
  pre-converting to JSON.
- **No DB schema bump.** New rows only; no new columns.
- **No app code changes in Phase 2 unless rendering reveals a gap.**

## Phase 1 — Exporter: add BHS to mobile_exporter.py

- [x] Add `BeautifulSoup` import and `slp1_translit` import at top of
      `mobile_exporter.py`.
      → verify: `uv run python -c "from exporter.mobile.mobile_exporter import GlobalVars"` succeeds.

- [x] Add a `# --- BHS ---` section inside `export_other_dictionaries()`,
      after the MW block. Parse XML, transliterate headwords, unwrap `<div>`s,
      strip `¦`, strip body wrappers, insert into `dict_entries` and `dict_meta`.
      → verify: 17,836 BHS entries inserted; sample rows transliterate
        cleanly (anuparivartati, Dhanunāśa, Arcirmaṇḍalagātra) with
        clean HTML and correct fuzzy keys.

- [x] **Phase 1 verification:** Inspect 3 random `bhs` rows — clean HTML,
      no `<H1>`/`<body>` wrappers, no `¦`, fuzzy keys diacritic-stripped.

## Phase 2 — App: drop in new DB and verify rendering

- [ ] Copy newly built mobile DB into the Flutter app assets directory.
      → verify: app's expected asset path contains updated file.

- [ ] Run app, confirm BHS in settings + searchable + readable rendering.
      → verify: user-confirmed on Android device.

- [ ] **Phase 2 verification:** Add minimal CSS class rules in
      `dict_html_card.dart` only if rendering is unreadable; otherwise skip.
