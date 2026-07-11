## Thread
- **ID:** 20260711_english_wordnet_dictionary
- **Objective:** Add Open English WordNet 2025 as an offline English–English dictionary in the mobile DB, optional in CI, default in local builds.

## Files Changed
dpd-db (submodule `resources/other-dictionaries` + parent):
- `dictionaries/wordnet/wordnet_to_json.py` — NEW: OEWN→`wordnet_dict.json` converter (excludes capitalized lemmas, groups senses by POS)
- `dictionaries/wordnet/{README.md,__init__.py}` — NEW: docs + package marker
- `dictionaries/wordnet/english-wordnet-2025.xml.gz` — NEW: OEWN LMF source (folder root, not `source/`)
- `dictionaries/wordnet/wordnet.tar.zst` — NEW: 4 MB archive of `wordnet_dict.json` for CI restore
- `exporter/mobile/mobile_exporter.py` — `include_wordnet` block + `--wordnet` flag (mirrors cone/peu)
- `tools/paths.py` — `wordnet_source_path`
- `.github/workflows/mobile_release.yml` — `include_wordnet` dispatch input (default false) + conditional flag
dpd-flutter-app:
- `justfile` — `build-db` now `--cone --wordnet` (local default on)

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | major | `mobile_exporter.py` dict_meta / `README.md` | Only `dict_meta.name` ("WordNet") is rendered; `author` never shown → CC BY attribution invisible and didn't name *Open English* WordNet | CC BY 4.0 requires visible attribution | FIXED: name→"Open English WordNet", author→"…(CC BY 4.0)"; README corrected |
| 2 | minor | `wordnet/source/english-wordnet-2025.xml.gz` | `compress_sources.py` archives all of `source/`, so the 11 MB gz would bloat `wordnet.tar.zst` | Wasteful build artifact | FIXED: moved gz to folder root; `LOCAL_LMF` updated |
| 3 | minor | both working trees | Unrelated changes present (dpd-db: `sutta_info.tsv`, `sandhi_rules.tsv`; app: device-sync recipe + `scripts/*sync*`) | "One thing, one commit" | Stage only WordNet files at finalize (not fixed — commit hygiene) |
| 4 | minor | `resources/other-dictionaries` (submodule) | New files are untracked *inside the submodule*; CI needs submodule commit pushed + pointer bump | CI `include_wordnet=true` fails until both land | Order the two pushes at finalize (not a code fix) |
| 5 | minor | `spec.md` | Spec said "core edition ~136k"; real is full oewn minus caps = 111,198; word_fuzzy note was misleading | Doc accuracy | FIXED: spec corrected |
| 6 | nit | `wordnet_to_json.py:34-40` | `callable(pos)` branch likely dead | — | Left (cross-version defensive, harmless) |
| 7 | nit | `wordnet_to_json.py` | broad `except Exception` around wn load | — | Left (author-time script) |
| 8 | nit | `plan.md` | Phase 1 converter checkbox unticked | — | FIXED |

CodeRabbit: dpd-db **0 findings**; dpd-flutter-app 2 findings both in `scripts/plug_sync_db.sh` — **out of scope** (pre-existing device-sync script, not this thread), recorded in `scripts/plug_sync_db_review.md`.

## Fixes Applied
- Renamed dictionary to "Open English WordNet" (attribution) + README corrected.
- Moved OEWN LMF out of `source/`; updated `LOCAL_LMF`.
- Corrected spec numbers/notes and plan checkbox.
- Re-ran exporter harness after fixes.

## Test Evidence
- Converter: `wordnet_dict.json` = 111,198 entries, 0 capitalized keys, HTML escaped, deterministic (key-sorted).
- Exporter harness (with `--wordnet`): `dict_meta('wordnet','Open English WordNet','Open English WordNet (CC BY 4.0)',111198)`, `dict_entries`=111,198 → PASS
- Exporter harness (without flag): 0 wordnet rows → PASS (gating correct)
- `DB_SCHEMA_VERSION` unchanged at 6 (rows only) → correct
- On-device: user confirmed WordNet appears, toggles, and renders ("plain but fine")
- `wordnet.tar.zst` contains only `wordnet_dict.json`; `decompress_sources` stem→`wordnet`→`source/` verified

## Verdict
PASSED
- Review date: 2026-07-11
- Reviewer: fable subagent (code review) + CodeRabbit via haiku subagent + consolidation. Note: independent from implementer.
- Residual risk: no automated test for the exporter block (consistent with sibling dicts); CI `include_wordnet=true` path untested until the submodule commit + pointer bump land (see findings 3–4). Note: on-device settings label will read "WordNet" until the DB is rebuilt with the renamed meta.
