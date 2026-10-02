## Thread
- **ID:** 20261002_pts_dictionary
- **Objective:** Add the PTS Pāḷi-English Dictionary (BuddhaDust edition) to other-dictionaries, the mobile DB and the app.

## Files Changed
- `other-dictionaries/dictionaries/pts/pts_from_buddhadust.py` — converts `ped.htm` to `pts.json` (furniture, editor notes, DhsA, -fullness, headword forms)
- `other-dictionaries/dictionaries/pts/{pts.py,pts.css,README.md,__init__.py,pts.tar.zst}` — GoldenDict/MDict export, styling, provenance, packed source
- `other-dictionaries/tests/test_pts_converter.py` — 30 real-snippet tests
- `other-dictionaries/{vendor/dpd_tools/paths.py,scripts/prepare_sources.py,scripts/export_all.py,README.md,.github/workflows/build-and-release.yml}` — registration
- `dpd-db/{tools/paths.py,exporter/mobile/mobile_exporter.py}` — paths and the PTS mobile block
- `dpd-db/docs/{other_dicts.md,index.md}` — download rows, description, home-page mention
- `lib/providers/dict_provider.dart`, `test/providers/dict_provider_test.dart` — `'pts': 'PTS'` short name
- `lib/widgets/dict_html_card.dart` — `in1` → `margin-left: 1em`
- `kamma/tech.md` — PTS note

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | major (Sonnet) | `pts_from_buddhadust.py` DHSA_RE | ~430 lost `DhsA` left where no `;`/`,` preceded "as N", incl. 4 bold | Same bug, half fixed; spec check was too narrow | Fixed: any `[Aa]s N` + bold form; 26 listed exceptions; 1,001 verified vs DPR |
| 2 | minor (Sonnet) | `convert`, `_has_text` | 9 junk entries from merged-only headwords (`.`, "and Esa (pronoun),") | Non-PTS fragments shown as entries | Fixed: 7 to `NOT_IN_PTS` (absent in DPR); `_has_words` ≥ 3 letters |
| 3 | minor (Sonnet) | `_strip_furniture` | 2 `[Page N]` markers kept; one split a sentence | Furniture in text | Fixed: two rules; `Taca` paragraphs joined |
| 4 | minor (Sonnet) | `convert` | Duplicate `(word, body)` rows | Two identical cards | Fixed: skipped |
| 5 | minor (Sonnet, DeepSeek) | tests | 9 of 12 rules unguarded | Regressions stay green | Fixed: 14 tests; all 13 rule mutants fail ≥ 1 test |
| 6 | minor (Sonnet) | `docs/other_dicts.md` | "PTS text only" overstated | Untagged edits remain | Fixed: wording softened |
| 7 | major (CodeRabbit) | README, licence | Corrected reprint licence not stated | User decided: cite BuddhaDust | Fixed: © Pāḷi Text Society, CC BY-NC in the description, README and docs; not in the app name (user decision) |
| 8 | nit (Sonnet, CodeRabbit) | README | Split/variant counts; JSON-shape wording | Accuracy | Fixed: re-measured |
| 9 | nit (Sonnet) | hyphenated headwords | `paṭiccasamuppāda` not found | App exact-match compares word | Fixed: hyphen-less form indexed |
| 10 | nit (Sonnet) | `AUDIO_RE`, `</I>` | Dead rule (output identical without it); stray capital tag | Dead code | Fixed: removed; tag folded |
| — | declined | CodeRabbit ANCHOR_RE | "misses other attribute orders" | All 16,415 anchors accounted for | None |
| — | declined | DeepSeek `ida`, `Ahu 3,4` | Claimed wrong DhsA / broken key | Disproved on the data | None |
| — | declined | Sonnet LONG_NOTE_RE, empty-output guard | Hard-coded text / speculative | Frozen snapshot | None |

## Fixes Applied
- Findings 1–10 above; archive re-packed, GoldenDict/MDict and mobile DB rebuilt.

## Test Evidence
- `uv run pytest tests/test_pts_converter.py` (scope: converter, 30 tests) → pass; mutation run over 13 rules → each caught
- `uv run pytest tests/` (scope: whole other-dictionaries suite) → 248 passed, 1 pre-existing MW count failure
- DhsA vs DPR (scope: every `DhsA` in all 16,318 bodies) → 994 same entry, 7 elsewhere, 0 not found
- Fuzzy parity, Dart port vs `word_fuzzy` (scope: all 16,421 PTS DB rows) → 0 mismatches; DB rows == `pts.json` as a multiset
- `flutter test` (scope: whole app, before review) → 389 passed; app code unchanged by the review fixes
- `ruff check` on every touched Python file → clean; `ruff check .` → 1 pre-existing error (Cone scraper)

## Not Verified
- The rebuilt DB (new name with the licence, review text fixes) has not been looked at on a device or in GoldenDict.
- CodeRabbit reviewed only `dictionaries/pts/` in the submodule (full diff too large because of `mwweb1.zip`); the Sonnet review covered the other submodule files.
- `vyāyāma` "as 146" left as is (no DPR entry); untagged BuddhaDust edits cannot be found by rule.
- CI release run not executed.

## Verdict
PASSED
- Review date: 2026-10-02
- Reviewer: independent Sonnet subagent + CodeRabbit 0.7.6 + pi/DeepSeek v4 pro, findings verified and fixed by Claude Opus 5.5
