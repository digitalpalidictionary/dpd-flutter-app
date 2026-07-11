# Plan: Add Open English WordNet as an English dictionary

See `spec.md` in this thread for full intent, assumptions, and done-criteria.

## Architecture Decisions

- **Reuse the existing external-dictionary pipeline.** The app auto-discovers any
  dictionary in the mobile DB's `dict_meta` / `dict_entries` tables, renders its
  `definition_html`, makes it searchable, and gives it a settings toggle — with no
  Flutter code. So this is a data/build task, not an app-feature task.
- **Two-stage data flow, mirroring `cone`.** (1) An author-time converter
  `wordnet_to_json.py` uses the `wn` library to load OEWN 2025 and emit
  `source/wordnet_dict.json` (`{headword: definition_html}`), exactly the shape of
  `cone_dict.json`. (2) The mobile exporter's `include_wordnet` block loads that JSON
  the same way the `include_cone` block loads `cone_dict.json`.
- **`wn` library is build-time only**, invoked via `uv run --with wn` so it is not
  added to dpd-db's runtime deps and never ships in the app.
- **Proper-noun exclusion = drop capitalized lemmas.** Simple, predictable, matches
  intent (removes "Paris", "Newton", "NATO"). Also drops a few capitalized common
  entries (e.g. "Buddhism") — acceptable, DPD covers those on the Pāli side.
- **Optional-in-CI / default-local** via a gated `--wordnet` flag that mirrors the
  existing `--cone` / `--peu` flags. Local `build-db` passes it; CI gates it behind a
  `workflow_dispatch` boolean input defaulting to false.
- **No schema bump** — only rows are added; `dict_meta`/`dict_entries` are unchanged.
- **Plain semantic HTML, no CSS.** POS in `<b>`, senses in `<ol><li>`, synonyms in
  italic parens, examples in italic quotes. No hardcoded colors; the app styles
  generic tags. `dict_meta.css` left empty.

## Files to touch

dpd-db (`../dpd-db/`):
- `resources/other-dictionaries/dictionaries/wordnet/` (NEW folder: `__init__.py`,
  `README.md`, `wordnet_to_json.py`, `source/`)
- `tools/paths.py` (add `wordnet_source_path`)
- `exporter/mobile/mobile_exporter.py` (`include_wordnet` param + block, `--wordnet` flag)
- `.github/workflows/mobile_release.yml` (workflow_dispatch input + conditional flag)

dpd-flutter-app (this repo):
- `justfile` (`build-db` recipe gains `--wordnet`)
- OPTIONAL: `lib/widgets/dict_settings_widget.dart` (help topic), `lib/widgets/dict_html_card.dart` (HTML cleanup) — only if the device test shows a need.

---

## Phase 1 — Generate the WordNet source JSON (dpd-db)  ✅ DONE

- [x] Create the dictionary folder skeleton mirroring `cone`:
  `resources/other-dictionaries/dictionaries/wordnet/` with `__init__.py`, `README.md`
  (source = Open English WordNet 2025, CC BY 4.0, attribution), and empty `source/`.
  → verify: `ls` shows the folder with `README.md` and `source/`.
- [x] Write `wordnet/wordnet_to_json.py`: `wn.download('oewn:2025')` (guarded/idempotent),
  load `wn.Wordnet('oewn:2025')`, iterate words, **skip lemmas whose first char is
  uppercase**, group each word's senses by POS (noun/verb/adjective/adverb/…), render
  plain-semantic HTML per headword (POS in `<b>`, senses in `<ol><li>`, synonyms in
  italic parens, examples in italic quotes), write `source/wordnet_dict.json`
  (`{lowercased headword: html}`).
  → verify: `uv run --with wn wordnet_to_json.py` completes; `wordnet_dict.json` exists
  with ~120k–140k keys; `python -c` spot-check that `"mind"` HTML contains a noun sense,
  a verb sense, a gloss, and at least one example; confirm no capitalized keys.
  → RESULT: 111,198 entries, 0 capitalized keys; "mind"/"peace"/"run" render with
  POS headings, glosses, synonyms, examples. Source LMF committed-ready as
  `wordnet.tar.zst` (4 MB) for CI `decompress_sources` auto-restore.

## Phase 2 — Exporter integration (dpd-db)  ✅ DONE

- [x] Add `wordnet_source_path` to `tools/paths.py` in the other-dictionaries block
  (pointing at `.../wordnet/source/wordnet_dict.json`), following the `cone_source_path`
  definition.
  → verify: `python -c "from tools.paths import ProjectPaths; print(ProjectPaths().wordnet_source_path)"` prints the expected path.
- [x] In `exporter/mobile/mobile_exporter.py`: add `include_wordnet: bool = False` to
  `export_other_dictionaries()`, add a gated block mirroring `include_cone` (load
  `wordnet_dict.json` → build `("wordnet", word, word_fuzzy, html, "")` batch →
  `executemany` into `dict_entries` → insert `dict_meta` row: `("wordnet", "WordNet",
  "Open English WordNet", "", count)`). Add `--wordnet` argparse flag in `main()` and
  pass `include_wordnet=args.wordnet` through.
  → verify: `uv run exporter/mobile/mobile_exporter.py --wordnet`, then
  `sqlite3 exporter/share/dpd-mobile.db "SELECT * FROM dict_meta WHERE dict_id='wordnet'; SELECT count(*) FROM dict_entries WHERE dict_id='wordnet';"` shows the meta row and a count matching the JSON key count. Re-run **without** `--wordnet` → both queries return zero wordnet rows.
  → RESULT (standalone harness, config.ini `make_mobile=no` left untouched): with
  flag → dict_meta `('wordnet','WordNet','Open English WordNet',111198)`,
  dict_entries 111,198; without flag → zero wordnet rows.

## Phase 3 — Local-default + CI-optional wiring  ✅ DONE

- [x] dpd-flutter-app `justfile`: change `build-db` to
  `... mobile_exporter.py --cone --wordnet`.
  → verify: `just --show build-db` (or read the recipe) shows both flags.
- [x] dpd-db `.github/workflows/mobile_release.yml`: add a `workflow_dispatch` boolean
  input `include_wordnet` (default `false`); change the exporter step (~line 233) so it
  passes `--wordnet` only when the input is true (e.g. `run: uv run python
  exporter/mobile/mobile_exporter.py ${{ inputs.include_wordnet == true && '--wordnet' || '' }}`).
  → verify: read the workflow — input block present with `default: false`; exporter step
  conditionally appends the flag. (Full CI run deferred to the user.)

## Phase 4 — On-device verification + polish (MANUAL)  ✅ DONE

- [x] Build the DB locally with WordNet and load it on device:
  `just build-db` then `just android-debug-push-db` (or `android-debug-install`).
  ⚠️ PREREQ: `../dpd-db/config.ini` must have `[exporter] make_mobile = yes` — it is
  currently `no`, which makes the exporter no-op silently. (Not changed by this thread;
  config.ini is never modified programmatically.) Also requires cone's source present
  (the recipe passes `--cone`); run `uv run resources/other-dictionaries/scripts/prepare_sources.py`
  first if sources aren't decompressed locally.
  → verify (MANUAL — user runs): open the app, go to dictionary settings — "WordNet"
  appears with an entry count and a working On/Off toggle; search "mind" and "peace" —
  WordNet results render legibly (POS headings, numbered senses, examples).
- [ ] Only if the device test shows a rendering problem: add WordNet HTML preprocessing
  in `dict_html_card.dart` (`prepareDictHtml`) and/or a help-topic entry in
  `dict_settings_widget.dart`, matching the sibling dictionaries.
  → verify: re-run the device test; rendering is clean.

## Phase verifications
- End of Phase 1: JSON generated, spot-checked, no capitalized keys.
- End of Phase 2: exporter includes/excludes WordNet correctly by flag (SQL-verified).
- End of Phase 3: recipe + workflow reviewed.
- End of Phase 4: MANUAL device confirmation by the user (the single manual gate).

## Notes / deferred
- Source provisioning for commit (compressed `wordnet.tar.zst` + `prepare_sources.py`
  extraction, mirroring `cone.tar.zst`) is handled at commit time; committing is out of
  scope for this run (no commits without explicit permission).
- `wn` proper-noun lexfile filtering was considered; capitalization filter chosen for
  simplicity and determinism.
