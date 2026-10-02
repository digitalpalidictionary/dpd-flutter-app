# Spec — Add the PTS Pāḷi-English Dictionary (BuddhaDust edition)

## Overview

The app ships several external dictionaries (CPD, DPPN, MW, Apte, BHS, PEU,
WordNet, Nyanatiloka, optional Cone), but not the Pali Text Society's
*Pāli-English Dictionary* (T. W. Rhys Davids & William Stede, 1921–25),
the standard reference most users expect. This thread adds it as a new
dictionary, `dict_id = "pts"`, in three places:

1. `../dpd-db/resources/other-dictionaries` (a git submodule): new
   `dictionaries/pts/` folder, with GoldenDict and MDict files published in
   the existing GitHub release, like every other dictionary there.
2. `../dpd-db/exporter/mobile/mobile_exporter.py`: a new block that writes
   PTS into `dict_entries` / `dict_meta` in the mobile DB.
3. `dpd-flutter-app`: the short name for the search summary, one styling
   rule for indented compound paragraphs, and docs.

The thread began as "add the Simsapa dictionary". Investigation changed it.
Simsapa's file combines four dictionaries. Two of them (DPPN, Nyanatiloka)
already ship in fuller editions. The user says DPD supersedes NCPED. PTS is
the only missing piece, so the thread now finds the best PTS copy and adds
that one.

## Source selection (done during planning, verified by reading the data)

Five copies were compared. Samples and full files sit in the session
scratchpad (gone after this session), so the numbers below are the record.

| Copy | Entries | Updated | Verdict |
|---|---|---|---|
| Tipitaka Pali Reader DB (`../tipitaka-pali-reader/assets/database/`, `dictionary` table, `book_id=5`) | 13,497 unique | old | Rejected. ~3,000 headwords missing (e.g. `ababa`), `ṅ` flattened to `n` (`anga`), no bold/italic, 22,236 `--`, 30 U+FFFD, superscripts flattened (`II.2892`). |
| Simsapa (`dictionaries/simsapa/source/simsapa.json`, `[PTS]` sections), same as `pts.xlsx` in github.com/simsapa/simsapa-dictionary release 0.2.0 (2019-11-27) | 16,106 | 2019 | Rejected. A 2019 snapshot of SuttaCentral's copy. The JSON lost superscripts (`<!-- raw HTML omitted -->`). |
| SuttaCentral `sc-data/dictionaries/complex/en/pli2en_pts.json` | 16,100 | May 2026 | Runner-up. Clean conversion with links to suttas. It restructures entries (etymology moved to the end, homonyms merged) and keeps dropped commas from the original typing ("mindfulness alertness"). |
| Digital Pali Reader `en/ped/{0..4}/ped.xml`, the same text as Univ. of Chicago DSAL | 16,282 | 2020 | Rejected. Closest to the 1925 print with addenda, but uses `ŋ`, ` -- `, and has stray `;` artefacts. DSAL itself has no bulk download and its robots.txt forbids crawling `/cgi-bin/`. |
| **BuddhaDust** `https://obo.genaud.net/backmatter/glossology/ped/pts_ped/ped.htm` | 16,413 headword anchors | 9 Dec 2025 | **Chosen by the user.** Checked against the PTS 2015 corrected reprint. Pāḷi in `<i>`, references in `<b>`, homonym superscripts kept, short reference names (`DN`, `Miln`, `Jāt`). |

Copyright: the user first said the 1921–25 text is out of copyright.
**Changed in review (2026-10-02, user decision: "believe buddhadust, just
state that as the source of the license"):** the BuddhaDust page states
"Corrected reprint Copyright The Pāḷi Text Society. Commercial Rights
Reserved" with a CC BY-NC badge. BuddhaDust's text follows that 2015
reprint, so PTS ships as © Pāḷi Text Society, CC BY-NC, and BuddhaDust is
cited as the source of that statement in the README, the GoldenDict/MDict
description and the docs. **User decision (2026-10-02): the licence does not
go in `dict_meta.name`** — no other dictionary carries one there; the name
stays "PTS Pāḷi-English Dictionary".

### BuddhaDust page structure (verified from the downloaded 8,976,003-byte page)

- One HTML page holds the whole dictionary. Front matter comes before the
  first `class="palientry"` (byte ~52,392). An `<h4 class="ctr">Afterword</h4>`
  follows the last entry (`Yūthikā`). Both are excluded.
- Each entry starts `<p><a id="x<key>" href="#x<key>" class="palientry">:: Headword</a> …`.
  Homonyms carry the number as a superscript and in the id:
  `id="xsarati-1"` → `:: Sarati<sup>1</sup>`. Count: 556 headwords with ¹,
  556 with ², 80 with ³, 18 with ⁴, 4 with ⁵.
- Compound sub-entries follow as `<p class="in1">…</p>` (1,485 of them).
  They belong to the preceding headword. So the page is split at each
  headword anchor, not at each `<p>`.
- Some headwords start with `°` (66), `-` (54) or `(` (24), e.g. suffixes.
- Niggahīta is `ṁ` throughout (16,109 `ṁ`, 0 `ṃ`).
- Page furniture inside entries that must be removed: 689 links to
  `resources/audios/…` (audio), 759 `<img>`, printed-page markers like
  `<a id="pg58" href="#pg58"><span class="f2 g"><b>{58}</b></span></a>`,
  and other relative links (`lingo.htm`, JPTS PDFs, `#x…` cross-references).
  None of these work offline.
- Found during implementation (2026-10-02, re-downloaded page, same
  8,976,003 bytes, `last-modified: Tue, 09 Dec 2025 20:31:40 GMT`):
  - 16,415 `class="palientry"` anchors, not 16,413. Two have no `id`
    (`:: Gocara` and `:: Sekkha`, both "see …" cross-references). They are
    real entries and are kept, so the split is at every `palientry` anchor.
  - More furniture: 36 `<div class="floatl">` letter-heading images, 34
    `<div class="floatr…">` BuddhaDust side boxes that define English words
    ("Moil: hard work; drudgery") with a cartoon image, ~40 section dividers
    `<p>-----<a …>[ An ]</a>-----&nbsp;&nbsp;<a href="#top">☝</a></p>`,
    `<p>&nbsp;</p>` spacers, and page markers in two id forms (`pgNN`, `preNN`).
  - 148 BuddhaDust editor notes tagged `[BD]`/`[bd]` (e.g. `[BD]: high dudgeon,
    ire`). This replaces the "Unverified ~190 additions" item below.
  - 2 `<div class="inner">` boxes with "Note from earlier editions" (PTS
    text, under `gala` and one other). Kept, with the `<h4>` turned into a
    bold paragraph.
  - Text merged from other dictionaries, tagged `[DPL]` (Childers, 62),
    `[CPD]` (3) and `[DOP]` (3). 49 headwords have only merged text (e.g.
    `Abhigacchati`: `[DPL]: To go to, to approach.`); 17 more tagged notes
    sit inside real PTS entries. `[Kuhns]` is part of a PTS reference title,
    not a tag.
  - **User decisions (2026-10-02): drop the `[BD]:` notes, the side boxes,
    and all `[DPL]`/`[CPD]`/`[DOP]` merged text.** A headword whose body is
    only merged text is dropped. The output is the PTS text only. Known
    limit: BuddhaDust also edited a few places without a tag (e.g. `Brahma`
    reads "see Mayrhofer 1994" where the print cites Osthoff). These cannot
    be found by rule and stay.
- BuddhaDust also offers `ped-export.htm` (zip, dated 12 Feb 2025). It already
  strips audio and images, but it is 10 months older and spells references
  out in full ("Dīgha Nikāya"), which is long on a phone. Not used.

### Known conversion errors in BuddhaDust (counted across the whole page)

- `-fullness` misspellings: `mindfullness` 32, `watchfullness` 11,
  `forgetfullness` 5, `lawfullness` 4, `usefullness` 4, `bashfullness` 4,
  … (~70 total; measured during implementation: 106 in the kept text). Fix: `(\w)fullness` → `\1fulness`. The standalone word
  `fullness` is not touched.
- A broken commentary abbreviation: `; as 121` where the DPR/print text has
  `DhsA 121` (Atthasālinī). 559 hits of `; as <digit>` and 18 of
  `, as <digit>`. The fix replaces it with `<b>DhsA</b>`. That fix is
  unproven until every hit is checked against DPR (see plan). Review found
  the same loss without the `;`/`,` ("fawning as 362", "cf. as 143", and
  bold `<b>as</b> 124`); the final fix covers every `as N`, 1,001 in all,
  with 26 listed exceptions.
- Garbled Greek (1,079 Greek-block characters by the planning count, not
  reproduced during implementation; some are wrong, e.g. `δἓμα`).
  Left as is. There is no reliable source to correct against.

## What it should do

### other-dictionaries submodule (`../dpd-db/resources/other-dictionaries/`)

- `dictionaries/pts/source/ped.htm`: the downloaded BuddhaDust page,
  committed for provenance and compressed into `pts.tar.zst` by the existing
  `scripts/compress_sources.py`. That script globs `dictionaries/*/source`,
  so no registration is needed.
- `dictionaries/pts/pts_from_buddhadust.py`: a one-off converter. It reads
  `source/ped.htm` and writes `source/pts.json`, a list of
  `{"word", "definition_html"}`. All cleaning lives here, so GoldenDict,
  MDict and the app get the same clean text:
  1. Keep only the region between the first `palientry` and the Afterword.
  2. Split at each headword anchor. The body is everything after the anchor
     up to the next headword's `<p>`, including `in1` paragraphs.
  3. `word`: the anchor text with the `:: ` prefix and the `<sup>` removed,
     `ṁ`→`ṃ`, lower-cased. Leading `°`/`-`/`(` handling is decided after
     printing every such headword (see plan; decided: marks dropped, inner
     spaces removed, bracketed letters indexed both ways). A variant
     headword inside an entry gets its own row with the same body.
  4. Body: drop the anchor. For homonyms, start the body with the homonym
     number as `<sup>N</sup>` so `sarati¹/²/³` stay distinguishable. Remove
     audio links, `<img>`, and page markers. Unwrap every other `<a>`.
     Apply the two error fixes above. Apply `ṁ`→`ṃ`.
- `dictionaries/pts/pts.css`: minimal styling, matching `nyanatiloka.css`
  plus `.in1 { margin-left: 1em; }`.
- `dictionaries/pts/pts.py`: GoldenDict + MDict export, mirroring
  `nyanatiloka.py`. `DictInfo(bookname="PTS Pāḷi-English Dictionary",
  author="T. W. Rhys Davids & William Stede", description=<edition +
  BuddhaDust credit>, website=<BuddhaDust URL>, source_lang="pi",
  target_lang="en")`.
- `dictionaries/pts/README.md` and `__init__.py`. The README records the
  source URL, the page's last-changed date, the download date, and the
  comparison above in short.
- `vendor/dpd_tools/paths.py`: `_setup_pts_paths()` (source json, css,
  gd/mdict paths), like `_setup_nyanatiloka_paths`.
- `scripts/export_all.py`: import and call `pts`.
- `scripts/prepare_sources.py`: add `"pts": pth.pts_source_path` to
  `mobile_critical`.
- `README.md` dictionary table and the release-notes table in
  `.github/workflows/build-and-release.yml`: add a `pts` row.

### dpd-db (`../dpd-db/`)

- `tools/paths.py`: `pts_source_path`, `pts_css_path`, like the Nyanatiloka
  entries at lines 538–547.
- `exporter/mobile/mobile_exporter.py`: a `# --- PTS ---` block after
  Nyanatiloka, mirroring it. It raises `_missing_source_error` if the
  source is absent. `dict_meta` = `("pts", "PTS Pāḷi-English Dictionary",
  "T. W. Rhys Davids & William Stede", pts_css, len(batch))`.
  `DB_SCHEMA_VERSION` is not bumped.
- `docs/other_dicts.md`: GoldenDict row, MDict row, and a description
  section. `docs/index.md`: mention PTS in the dictionaries sentence.
- Submodule pointer bump.

### dpd-flutter-app

- `lib/providers/dict_provider.dart`: add `'pts': 'PTS'` to `_dictShortNames`.
- `test/providers/dict_provider_test.dart`: add `expect(dictShortName('pts'), 'PTS')`.
- `lib/widgets/dict_html_card.dart` `_buildStylesBuilder`: add a rule for
  class `in1` → `{'margin-left': '1em'}`, so compound paragraphs indent as
  they do in the source.
- `kamma/tech.md`: note PTS under "External Dictionaries".
- `assets/help/bibliography.tsv` already has the Rhys Davids & Stede row
  (line 9). No change.

## Assumptions & uncertainties

- **Verified:** entry counts, source structure, error counts, the absence
  of `ṃ`, the homonym id scheme, and the furniture counts. All came from the
  downloaded files. The registration points came from a hidden-files sweep
  of both repos for `nyanatiloka`. The app needs no change to discover a new
  dictionary: the Nyanatiloka thread confirmed this, and `kamma/tech.md`
  states it.
- **Unverified:** a helper's claim that BuddhaDust has ~190 tagged
  additions. A search for `[BuddhaDust]`, `Obo` and `Childers` tags in entry
  bodies did not find them, so the spec does not rely on it.
- **Unverified:** that every `; as N` is a broken `DhsA`. The plan checks
  all hits against DPR before applying the fix.
- **Assumption:** lower-casing headwords is right. The search is
  case-insensitive (`dao_test` matches `anāthapiṇḍika` to `Anāthapiṇḍika`),
  and other Pāḷi dictionaries use lower case.
- **Assumption:** a leading `<sup>N</sup>` in the body reads well enough to
  tell homonyms apart. It is checked on a real screen.
- BuddhaDust's robots.txt asks for a 10-second crawl delay. The thread needs
  one download of one page.

## Constraints

- Never use hardcoded colours in Flutter. The new `in1` rule sets layout
  only.
- `word_fuzzy` must be computed with `_strip_diacritics_mobile()` (fuzzy
  parity rule in AGENTS.md).
- The database stores `ṃ` only. Fold every `ṁ`.
- Commits happen only on the user's explicit "yes": submodule first, then
  the dpd-db pointer bump, then the app.

## How we'll know it's done

- `source/pts.json` has ~16,400 entries (16,421 rows after the decisions
  above and the review fixes). It contains 0 `ṁ`, 0 `<img`, 0 `<a `, 0
  `{NN}` or `[Page N]` markers, 0 `\wfullness`, 0 editor tags, 0 duplicate
  rows, and no `as \d` except the 26 listed in `ENGLISH_AS` and 2 broken
  across a line break (`ida`, `koṭṭha`).
- The GoldenDict and MDict zips build. `sati` and `sarati` open correctly in
  GoldenDict.
- The mobile DB has `dict_meta` row `pts` and `dict_entries` count equal to
  the JSON count.
- In the app, searching `sati`, `kamma`, `sarati` and `ababa` shows a "PTS"
  card. Pāḷi is italic, references bold, compounds indented, homonyms
  numbered. It is readable in light and dark mode, and the summary row
  reads "PTS".
- `flutter test` passes.

## What's not included

- Removing or changing the existing Simsapa Combined dictionary or its
  downloads.
- NCPED, Dhammika, or any other Simsapa sub-dictionary.
- Fixing the garbled Greek.
- Live re-fetching. The source is committed as a static snapshot, like
  Nyanatiloka.
- Turning references into SuttaCentral links.
