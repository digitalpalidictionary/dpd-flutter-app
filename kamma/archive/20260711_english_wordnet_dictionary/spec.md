# Spec: Add Open English WordNet as an English dictionary

## Overview
Add a good-quality, freely-available English–English dictionary to the DPD app so
users can look up ordinary English words. The source is **Open English WordNet
(OEWN) 2025** (CC BY 4.0), full `oewn:2025` with proper nouns excluded (capitalized
lemmas dropped) — **111,198 headwords** in the generated data. (There is no separate
OEWN "core" download; the exclusion is done in our converter.)

The DPD app already has a complete external-dictionary system: any dictionary
present in the mobile DB's `dict_meta` / `dict_entries` tables is auto-discovered,
rendered (HTML via `flutter_widget_from_html`), searchable, and given an
enable/disable + reorder toggle in settings — with **no Flutter code required**.
Therefore this work lives almost entirely in the sibling **dpd-db** repo, which
builds the mobile database.

## Cross-repo note
- **dpd-db** (`../dpd-db/`, separate git repo): all data ingestion, the exporter
  parser block, the CLI flag, and the CI workflow change. ~95% of the work.
- **dpd-flutter-app** (this repo): only the `justfile` `build-db` recipe gains
  `--wordnet` so local DB builds include WordNet by default. Optional polish: a
  settings help-topic entry and any WordNet-specific HTML cleanup.
- This kamma thread is tracked here (kamma is only set up in this repo), but most
  commits land in dpd-db.

## What it should do
1. **Data source**: Obtain the OEWN 2025 JSON release. Store/prepare it under
   `../dpd-db/resources/other-dictionaries/dictionaries/wordnet/source/` following
   the sibling pattern (cone/cpd/mw/peu each have a `source/` dir).
2. **Convert to entries**: For each headword, build one `dict_entries` row:
   - `dict_id = "wordnet"`, `word = <lowercased headword>`,
     `word_fuzzy = _strip_diacritics_mobile(word)` (same transform the app applies to
     queries — also strips spaces and collapses aspirates/geminates, e.g.
     "letter"→"leter"; both sides MUST use the identical transform or matching breaks),
     `definition_html = <rendered HTML>`, `definition_plain = ""`.
   - HTML groups senses by part of speech (noun/verb/adjective/adverb); each sense
     shows its gloss, synonyms, and example(s) where present. Proper nouns excluded.
3. **Exporter integration**: In `../dpd-db/exporter/mobile/mobile_exporter.py`,
   add an `include_wordnet: bool = False` parameter to `export_other_dictionaries()`
   and a gated block that mirrors the existing `include_cone` / `include_peu` blocks
   (load source → build batch → `executemany` into `dict_entries` → insert
   `dict_meta` row with name/author/entry_count). Wire a `--wordnet` argparse flag
   in `main()`.
4. **Local default ON**: In this repo's `justfile`, the `build-db` recipe becomes
   `... mobile_exporter.py --cone --wordnet`.
5. **CI optional OFF**: In `../dpd-db/.github/workflows/mobile_release.yml`, add a
   `workflow_dispatch` boolean input `include_wordnet` (default `false`), and pass
   `--wordnet` to the exporter step (line ~233) only when it is true.
6. **App**: appears automatically as "WordNet" in results and in the dictionary
   settings list. Add a settings help-topic entry describing it (parity with other
   dicts). Add WordNet-specific HTML preprocessing in `dict_html_card.dart` only if
   the generated HTML needs it.

## Attribution / license
OEWN is CC BY 4.0 → attribution required. The `dict_meta.author` field + the
dictionary name shown in the UI provide attribution. Record the source, edition
(2025), and license in the dpd-db dictionary folder (a `README`/`LICENSE` alongside
the source, matching how other dicts are documented).

## Assumptions & uncertainties
- **A:** OEWN's JSON structure exposes lemma → senses (with POS, gloss, examples,
  synonyms). Exact field names verified against the actual download during
  implementation. (Fallback: LMF XML if JSON is awkward.)
- **A:** Excluding proper nouns is doable via POS / synset lexicographer-file
  filtering in the OEWN data.
- **A:** "The GitHub action" = dpd-db `mobile_release.yml` (the workflow that builds
  and releases `dpd-mobile-db.zip`). The flutter app's `release.yml` only builds the
  APK; the DB is downloaded at runtime, so it is not involved.
- **A:** No mobile DB `DB_SCHEMA_VERSION` bump is needed — the `dict_meta` /
  `dict_entries` schema is unchanged; only new rows are added.
- **A:** Entry size is modest (WordNet HTML for ~111k words compresses well), so the
  released zip stays reasonable.
- **U:** Whether a `prepare_sources.py` hook (dpd-db) should fetch WordNet, or the
  source is committed into the repo like the other dictionaries — decided by
  inspecting how sibling dicts' sources are provisioned.

## Constraints
- Follow the existing external-dictionary sibling pattern exactly (cone/peu). Do not
  invent a new mechanism.
- No hardcoded colors / HTML-widget rules beyond what other dicts use.
- Preserve fast startup/search; WordNet is just more `dict_entries` rows behind the
  existing indexes (`idx_dict_entries_word`, `idx_dict_entries_fuzzy`).
- Do not bump the mobile schema version unless strictly required.
- Do not modify `config.ini`.

## How we'll know it's done
- `cd ../dpd-db && uv run exporter/mobile/mobile_exporter.py --wordnet` produces a
  `dpd-mobile.db` containing a `wordnet` row in `dict_meta` and ~111k `dict_entries`.
- `just build-db` (this repo) includes WordNet by default; DB pushed to device shows
  "WordNet" in dictionary settings and returns sensible results for a common English
  word (e.g. "mind", "peace").
- Running the exporter **without** `--wordnet` produces a DB with no `wordnet` rows.
- `mobile_release.yml` triggered with `include_wordnet=false` (default) yields a
  release DB without WordNet; with `true` it includes it.

## What's not included
- No new Flutter dictionary UI, search path, or data-model changes.
- No thesaurus/relations browsing (hypernyms, etc.) — flat gloss entries only.
- No proper-noun ("Plus") edition.
- No changes to the DPD Pāli data or the lookup index.
- No GoldenDict/desktop export of WordNet (mobile only).
