# Plan — Add the PTS Pāḷi-English Dictionary (BuddhaDust edition)

Spec: `kamma/threads/20261002_pts_dictionary/spec.md`. Read it first. It
holds the source comparison, the verified page structure, and the error
counts that this plan relies on.

## Architecture Decisions

- **One converter, one clean JSON.** All cleaning happens once, in
  `dictionaries/pts/pts_from_buddhadust.py`, which writes `source/pts.json`.
  GoldenDict, MDict and the mobile exporter all read that JSON as it is. This
  copies the Nyanatiloka pattern (a static, committed `source/*.json`). It
  does not copy Apte's (rebuilt from a download at prepare time): the PTS
  source is a fixed snapshot, so nothing needs rebuilding.
- **The raw page is committed too.** `source/ped.htm` goes into
  `pts.tar.zst` with the JSON, so the conversion can be re-run without
  fetching again. BuddhaDust's robots.txt asks for a 10-second delay, and the
  thread needs one request in total.
- **The app gets no PTS-specific HTML code.** Clean HTML that uses only `<p>`,
  `<i>`, `<b>`, `<sup>`, `<br>` and the `in1` class renders through the
  existing `HtmlWidget` path. The one app change to how entries look is a
  generic `in1` indent rule in `_buildStylesBuilder`. There is no
  `prepareDictHtml` branch.
- **Homonym numbers go in the body, not the word.** `word` stays `sarati`, so
  an exact search finds all three. The body starts with `<sup>N</sup>`. This
  needs no change to the app's title code (unlike DPPN's `dppnDisplayTitle`).
- **Not abstracted:** the mobile exporter block is copied from Nyanatiloka's.
  Nine near-identical blocks already exist there, and a shared helper is
  outside this thread's scope.

## Phase 1 — Source and converter (other-dictionaries submodule)

Working dir: `../dpd-db/resources/other-dictionaries/`. Run Python with
`uv run`.

- [x] Download the source page once into `dictionaries/pts/source/ped.htm`:
      `curl -sS -A "Mozilla/5.0" -o dictionaries/pts/source/ped.htm https://obo.genaud.net/backmatter/glossology/ped/pts_ped/ped.htm`.
      Also create `dictionaries/pts/__init__.py` (empty).
  → verify: the file is about 8.9 MB, and `grep -c 'class="palientry"'` prints about 16,413. Record the byte size, the date of the download, and the page's own last-changed date in the README task below.
  → result (2026-10-02): 8,976,003 bytes, downloaded 2026-10-02, `last-modified: Tue, 09 Dec 2025 20:31:40 GMT`. 16,415 `palientry` anchors: 16,413 with an id plus 2 without (`Gocara`, `Sekkha`).
- [x] Add `_setup_pts_paths()` to `vendor/dpd_tools/paths.py`, modelled on
      `_setup_nyanatiloka_paths` (lines 108–113), and call it from `__init__`:
      `pts_raw_path = d/"source"/"ped.htm"`, `pts_source_path = d/"source"/"pts.json"`,
      `pts_css_path = d/"pts.css"`, `pts_gd_path`, `pts_mdict_path`.
  → verify: `uv run python -c "from vendor.dpd_tools.paths import RepoPaths; p=RepoPaths(); print(p.pts_raw_path.exists(), p.pts_source_path)"` prints `True …/pts/source/pts.json`.
- [x] Write `dictionaries/pts/pts_from_buddhadust.py` with a pure function
      `convert(raw_html: str) -> list[dict[str, str]]` and a `main()` that
      reads `pts_raw_path` and writes `pts_source_path` (UTF-8,
      `ensure_ascii=False`). Apply the steps listed in the spec's "What it
      should do": region cut, split at each headword anchor, building the
      word, cleaning the body, `ṁ`→`ṃ`, the `-fullness` fix. **Hold back the
      `; as N` fix and the leading `°`/`-`/`(` handling.** They come in the
      next two tasks.
  → verify: `uv run python -m dictionaries.pts.pts_from_buddhadust` writes the JSON. A count script prints: entries ≈16,413. Every body has 0 `ṁ`, 0 `<img`, 0 `<a `, 0 `{` page markers (`\{\d+\}`), and 0 `\wfullness`. Print the entries for `sati`, `sarati` (all three) and `ababa`, and read them.
  → result: all counts 0 (also 0 `<div`, `<span`, `<h4`, `&nbsp;`, `-----`, `☝`, `::`, `[BD]`, `[DPL]`, `[CPD]`, `[DOP]`, `SUTTA SEARCH`, `GLOSSOLOGY`). `sati`, `sarati` ¹²³, `ababa`, `sathera` read correctly.
  → drift, found while building it (spec updated): (a) the user chose to drop all `[BD]`, `[DPL]`, `[CPD]`, `[DOP]` notes and the side boxes. All 216 removed notes were printed and read. That produced two special rules: `LONG_NOTE_RE` for `Nahuta`/`Niddasa`, whose notes run to the paragraph end, and a stop at `\s—\s` so PTS text in `Taṇhā` survives. 49 merged-only headwords, 2 empty ones (`Corovassikaṃ`, `Vālatta`) and `Sūpatiṭṭha` (NCPED-only, not in DPR) are dropped. (b) 9 variant headwords sit inside another entry (`Amha and<br /> Amhan`). Each is shown in bold and indexed with the same body. (c) `Yena` is typed as `<b><i>:: Yena</i></b>` and is turned into an anchor. (d) 11 `[SUTTA SEARCH] [GLOSSOLOGY]` link-label pairs are removed (2 put the `[` inside the link). (e) Leading `,`/`<br />` left by variants is trimmed from the body start.
- [x] Decide the `; as N` fix from evidence. Parse the DPR copy
      (`https://raw.githubusercontent.com/digitalpalireader/digitalpalireader/master/en/ped/{0..4}/ped.xml`,
      download to the session scratchpad, not the repo). For every PTS entry
      containing `[;,] as \d`, print the headword, the BuddhaDust phrase, and
      the matching DPR phrase.
      Replace with `<b>DhsA</b>` only if DPR shows `DhsA` in the matching
      place. Leave any other kind of hit unchanged.
  → verify: paste into this plan the counts (hits found, hits matched to `DhsA`, hits left alone, with reasons). After re-running the converter, `[;,] as \d` matches only the hits that were left alone.
  → result: 578 hits in the plain text (punctuation may sit inside `</i>`). 571 replaced with `<b>DhsA</b>`. Each of the 571 page numbers is cited as `DhsA`/`Dhs A`/`Asl.` somewhere in DPR (569 directly; `avacara 387` and `kāma 371` are written `Dhs A`). 7 left alone, all English "as": `āroha` "as 1?", `buddha` "as 18 at Miln", `dhamma` "as 3 of the", `ida` "as 1. in", `isi` "as 7th", `kamma` "as 40 at Vism", `ñāṇa` "as 77 (7 × 11)". Rule: `([;,](?:</i>)?) as (\d+)` followed by whitespace/`;,.)<:` and not by ` at`, ` of` or ` (digit`.
- [x] Decide the leading-symbol headwords from evidence. Print every
      headword whose anchor text starts with `°`, `-` or `(` (about 144),
      with its first 80 body characters, and read them all. Strip the symbol
      from `word` only where the result is a real searchable form, e.g.
      `°ka` → `ka`. Remove the stripped form only if it would collide
      with a normal headword in a confusing way. Record the rule here.
  → verify: the printout and the chosen rule are pasted here. No `word` in the JSON starts with `°`, `-`, `(`, or a space, unless the rule says so.
  → result: 183 headwords with non-letters were printed and read (saved only in the session scratchpad). Rule in `_search_forms`: drop leading/trailing `°` and `-` (prefix/stem/suffix marks, ~130, e.g. `pa°`→`pa`, `-da`→`da`; no confusing collisions — the forms that already exist, `ā`, `su`, `du`, `ve`, `vo`, are the same word's homonyms); remove spaces inside words (24 BuddhaDust typing errors, e.g. `upa kappati`→`upakappati`); drop the stray `(adjective)` in `bahula(adjective)`; index bracketed optional letters both ways (25, e.g. `jap(p)aka`→`jappaka` and `japaka`). Hyphenated compounds (`paṭicca-samuppāda`, 44) are real PTS spellings and stay. After the rule: 0 words start or end with `°`, `-`, `(` or a space; 0 empty words. Final count: 16,388 entries, 15,702 unique words.
- [x] Add `tests/test_pts_converter.py`. Build its fixtures by copying real
      snippets from `source/ped.htm`, not hand-written ones: a plain entry
      (`Sathera`), a homonym with `in1` compounds (`Sarati<sup>1</sup>`), an
      entry with an audio link, an `<img>` and a `{NN}` page marker, an entry
      with a `-fullness` misspelling, and one `; as N` hit. Assert the word,
      the leading `<sup>N</sup>`, the stripped furniture, and the two fixes.
  → verify: `uv run pytest tests/test_pts_converter.py -v` passes. Then undo the `-fullness` fix in the converter (keep it compiling), re-run, and confirm the `-fullness` test fails for that reason. Restore the fix and record the result here.
  → result: 16 passed. 11 fixtures, each checked to be a byte-exact substring of `ped.htm` (`Sathera`, `Agha¹` + `in1`, `Abhidhamma` audio + img + `{58}`, `Abhiyobbana` -fullness, `Abhisaṅga` `; as 129`, `Abbhudīreti` `[BD]`, `Abhigacchati` `[DPL]`-only, `Nisamsa` variant, `Chab°`, `Jap(p)aka`, `Upa kappati`). Revert proof: the substitution changed to write `fullness` back → exactly 1 failed (`test_fullness_misspelling_fixed`), 15 passed. Restored → 16 passed.
- [x] Phase 1 automatic check: `uv run pytest tests/ -v` and `uv run ruff check dictionaries/pts tests/test_pts_converter.py`.
  → verify: all tests pass and ruff reports no errors. Paste the summary line here.
  → result: `1 failed, 234 passed, 4 skipped`. The 1 failure is PRE-EXISTING — NOT CAUSED BY THIS THREAD: `test_mw_data_loading.py::TestEntryLoading::test_entries_count` (Cologne upstream has 286,525 entries, below the 286,554 floor). It failed the same way at baseline, before any change. `ruff check dictionaries/pts tests/test_pts_converter.py`: All checks passed. The two new files were run through `ruff format`; `pts.json` md5 is identical before and after.

## Phase 2 — GoldenDict / MDict build and release registration (submodule)

- [x] Write `dictionaries/pts/pts.css`: the same rules as `nyanatiloka.css`,
      plus `.in1 { margin-left: 1em; }`.
  → verify: the file exists and its selectors match the classes the JSON uses (`grep -o 'class="[^"]*"' source/pts.json | sort | uniq -c`).
  → result: the JSON uses one class, `in1` (1,488 rows; 1,482 in the source plus the copies on variant rows). The CSS has `b`, `i` and `.in1`.
- [x] Write `dictionaries/pts/pts.py`, mirroring `dictionaries/nyanatiloka/nyanatiloka.py`
      line for line. Use `dict_name="pts"` and the `DictInfo` values from the
      spec. `css_paths=[pth.pts_css_path]`.
  → verify: `uv run python -m dictionaries.pts.pts` writes `build/goldendict/pts.zip` and `build/mdict/pts.zip` (or the names the shared exporter gives them; take them from the build output). Open the GoldenDict zip in GoldenDict and confirm `sati` and `sarati` show with italics, bold and indented compounds.
  → result: `build/goldendict/pts.zip` (2,697,492 bytes) and `build/mdict/pts.zip` (2,732,388 bytes). The GoldenDict zip was read back with pyglossary: `.ifo` wordcount 16,388, `res/pts.css` present, and `sati` (1), `sarati` (3), `ababa` (1) found with the expected HTML. **Opening it in the GoldenDict window is left for the user's manual test.**
- [x] Register PTS: add `"pts": pth.pts_source_path` to `mobile_critical` in
      `scripts/prepare_sources.py`. Add the import and call in
      `scripts/export_all.py`, next to `nyanatiloka`. Add a `pts` row to the
      `README.md` table and to the release-notes table in
      `.github/workflows/build-and-release.yml` (next to the `nyanatiloka` row,
      line ~102).
  → verify: `rg -n "pts" scripts/prepare_sources.py scripts/export_all.py README.md .github/workflows/build-and-release.yml` shows each new line. `uv run python scripts/prepare_sources.py` lists `pts` as present.
  → result: each new line is shown. `prepare_sources.py` lists `pts 8.3 MB`. Side effect: that script re-downloads Cologne MW, which rewrote the tracked `dictionaries/mw/source/mwweb1.zip`. This is not part of the thread. It needs to be restored by the user (`git checkout -- dictionaries/mw/source/mwweb1.zip` in the submodule) or deliberately kept.
- [x] Write `dictionaries/pts/README.md`, in the same shape as Nyanatiloka's. Include the title, authors and dates, the source URL, the download date and size, the page's last-changed date, a short version of the five-copy comparison, the conversion steps and the two error fixes with their counts, the known Greek problem, and Run / Output sections.
  → verify: every number in the README matches the numbers recorded in Phase 1 of this plan.
  → result: every number was re-measured by script. Three first-draft figures were wrong and are fixed: 148 `[BD]` notes, not 147; 51 headwords dropped plus `Sūpatiṭṭha`, not 52; the Greek count was dropped because 1,079 could not be reproduced. The `-fullness` count is 106 (the spec estimated ~70).
- [x] Compress the source. (Drift: `scripts/compress_sources.py` re-packs every dictionary and would rewrite about a dozen tracked archives, so only `pts` was packed, with the same tarfile + `zstd -19` steps.)
  → verify: `dictionaries/pts/pts.tar.zst` exists. Run `uv run python scripts/decompress_sources.py` in a scratch copy (or check `tar --zstd -tf`): it lists `ped.htm` and `pts.json`.
  → result: `pts.tar.zst` is 3,682,240 bytes. It lists `ped.htm` and `pts.json`, and extracting it to the scratchpad gives byte-identical files (md5 `fa6aee16…` and `7838066b…`).
- [x] Phase 2 automatic check: `uv run pytest tests/ -v`, `uv run ruff check .`.
  → verify: all tests pass and ruff is clean. Paste the summary line here.
  → result: `1 failed, 234 passed, 4 skipped`. The failure is the same pre-existing MW count test. `ruff check .` gives 1 error, PRE-EXISTING — NOT CAUSED BY THIS THREAD: unused `re` in `scrapers/cone/scrape_entries.py`, the same as at baseline. Every touched file passes `ruff check`.

## Phase 3 — Mobile export (dpd-db)

Working dir: `../dpd-db/`.

- [x] Add `pts_source_path` and `pts_css_path` to `tools/paths.py`, next to the
      Nyanatiloka entries (lines 538–547), with the same comment style.
  → verify: `uv run python -c "from tools.paths import ProjectPaths; p=ProjectPaths(); print(p.pts_source_path.exists(), p.pts_css_path.exists())"` prints `True True`.
  → result: `True True`.
- [x] Add a `# --- PTS (Pali Text Society Pāli-English Dictionary) ---` block at
      the end of `export_other_dictionaries` in
      `exporter/mobile/mobile_exporter.py`, copied from the Nyanatiloka block
      (lines ~783–822). Use `dict_id "pts"`, `_strip_diacritics_mobile(word)`
      for `word_fuzzy`, `_sanitize_css` on `pts.css`, and the `dict_meta` row
      from the spec. Do not bump `DB_SCHEMA_VERSION`.
  → verify: `uv run python exporter/mobile/mobile_exporter.py --cone` (the app's `just build-db` recipe) finishes. Then `sqlite3 exporter/mobile/dpd-mobile.db "select dict_id,name,entry_count from dict_meta where dict_id='pts'; select count(*) from dict_entries where dict_id='pts'"` shows the two counts equal to the JSON entry count.
  → result: exit 0, log `exporting PTS 16,388`. The DB is written to `exporter/share/dpd-mobile.db` (the path `just`'s `_local_db` pushes), not `exporter/mobile/` as this line assumed. `dict_meta`: `pts|PTS Pāḷi-English Dictionary|T. W. Rhys Davids & William Stede|16388`, css 86 chars. `dict_entries` count 16,388, equal to the JSON. The DB mtime (18:29:12) is newer than the exporter edit (18:28:14).
- [x] Update `docs/other_dicts.md` (GoldenDict table row, MDict table row
      with the release download links, and a `## PTS Pāḷi-English Dictionary`
      section crediting Rhys Davids & Stede and BuddhaDust). Add PTS to the
      dictionary sentence in `docs/index.md` line 19.
  → verify: the download link names match the zip names produced in Phase 2.
  → result: the build makes `pts.zip`. The release workflow renames it `${basename}-gd.zip` / `${basename}-mdict.zip`, so the docs link to `pts-gd.zip` and `pts-mdict.zip`, the same pattern as every other row.
  → docs sweep (2026-10-02, on the user's request): `rg` over `../dpd-db/docs` for every dictionary name. Only `other_dicts.md` (on the site menu as "Other Dictionaries" in `mkdocs.yaml`) and `index.md` list the downloadable dictionaries; both now name PTS. `abbreviations.md` (`PED` row) and `bibliography.md` (Rhys Davids & Stede row) already cover PTS, as does the app's `assets/help/bibliography.tsv`. `newsletters.md` and `changelog.md` are history and are not changed.
- [x] Phase 3 automatic check: `uv run ruff check exporter/mobile/mobile_exporter.py tools/paths.py`, plus the fuzzy-parity spot check. Port `stripDiacritics()` from `lib/utils/diacritics.dart` and compare it with `word_fuzzy` for every `pts` row.
  → verify: ruff is clean. The parity script prints 0 mismatches over all PTS rows. Paste the count here.
  → result: ruff `All checks passed!`, format clean. Parity: `rows 16388 mismatches 0` (the Dart `stripDiacritics` was ported to Python and checked on `sati`, `dhamma`→`dama`, `ṭhāna`→`tana`).

## Phase 4 — App integration (dpd-flutter-app)

- [x] Add `'pts': 'PTS'` to `_dictShortNames` in `lib/providers/dict_provider.dart`.
      Add `expect(dictShortName('pts'), 'PTS');` beside the existing
      short-name expectations in `test/providers/dict_provider_test.dart` (~line 724).
  → verify: `flutter test test/providers/dict_provider_test.dart` passes. Remove the map entry, re-run, and confirm the new expectation fails (`'Pts'` ≠ `'PTS'`). Restore the entry.
  → result: 29 passed. With the entry removed: 1 failed, `Expected: 'PTS' Actual: 'Pts'`. Restored: 29 passed.
- [x] Add an `in1` rule to `_buildStylesBuilder` in `lib/widgets/dict_html_card.dart`,
      placed with the other layout-only rules: `if (classes.contains('in1')) return {'margin-left': '1em'};`.
      It sets no colour. First grep the mobile DB for any other dictionary
      already using class `in1`, and report the result
      (`sqlite3 ../dpd-db/exporter/mobile/dpd-mobile.db "select dict_id,count(*) from dict_entries where definition_html like '%class=\"in1\"%' group by dict_id"`).
  → verify: the grep result is recorded here (only `pts` is expected). `flutter analyze` is clean.
  → result: the grep gives only `pts|1421` (rows). The rule sits after `div-sep`. `flutter analyze` reports 52 infos (deprecations), none in the changed files: PRE-EXISTING — NOT CAUSED BY THIS THREAD.
- [x] Add a PTS paragraph to `kamma/tech.md` under "External Dictionaries & English WordNet": `dict_id`, the source, the snapshot date, the converter location, and the "short name map" note.
  → verify: the paragraph names the converter path and source URL exactly as they are in the code.
  → result: the path `../dpd-db/resources/other-dictionaries/dictionaries/pts/pts_from_buddhadust.py` and the URL match `pts.py`'s `website=` and the README.
- [x] Phase 4 automatic check: `flutter analyze` and `flutter test`.
  → verify: no analyzer issues and all tests pass. Paste the summary line here.
  → result: `flutter test`: `+389: All tests passed!`. `flutter analyze`: 52 pre-existing infos, 0 in the changed files.
- [x] Real-app check on Android with the freshly built mobile DB (check that its mtime is newer than the exporter change). Search `sati`, `kamma`, `sarati` and `ababa`, then tap a word inside a PTS entry.
  → verify: each search shows a "PTS" card and a "PTS" summary row. Pāḷi is italic, references bold, and compounds indented. The three `sarati` entries show ¹ ² ³. The text is readable in light and dark mode. Tap-to-search on a PTS word opens a lookup with `ṃ` (no `ṁ` in history). Take a screenshot of `sarati` for the review.
  → result (2026-10-02): the user confirmed that all manual tests passed (Android searches, sarati ¹²³, styling in light and dark, tap-to-search with ṃ, GoldenDict).

## Review fixes (2026-10-02)

Three parallel reviews ran: an independent Sonnet agent, CodeRabbit (per
repo), and pi with DeepSeek. Each finding was checked against the data before
it was acted on. See `review.md` for the table.

- [x] DhsA everywhere, not only after `;`/`,`. Every remaining `as N` was
      classified against the same DPR entry (headwords folded to plain
      letters). `DHSA_RE` now matches any `[Aa]s N`; `BOLD_DHSA_RE` covers the
      4 bold forms; `ENGLISH_AS` lists the 26 places left alone (25 English
      plus `vyāyāma`, unconfirmed).
  → verify: 1,001 `DhsA` in the output; 994 confirmed in the same DPR entry,
    7 elsewhere in DPR, 0 not found. 28 `as N` left (the 26 listed, plus
    `ida` and `koṭṭha`, English and broken by a line break).
- [x] Drop merged-only leftovers: `NOT_IN_PTS` gains `Amhākaṁ`, `Avyatta`,
      `Bhātā`, `Eso`, `Hīyo`, `Paṭilekhanaṁ`, `So` (none in DPR), and
      `_has_words` drops bodies with fewer than 3 letters (`.`, `(q.v.).`).
  → verify: printed every entry that lost a note and kept < 40 letters; all
    386 bodies under 16 characters left are genuine cross-references.
- [x] Remove the two `[Page N]` markers; in `Taca` the paragraphs are joined.
  → verify: 0 `[Page` in the output; `Taca` reads "I.(a) of which the first".
- [x] Skip duplicate `(word, body)` rows. → verify: 0 duplicates.
- [x] Index hyphenated compounds also without the hyphen (the app's exact
      match compares the word, so `paṭiccasamuppāda` missed). → verify:
      `paṭiccasamuppāda` and `paṭicca-samuppāda` both present.
- [x] Fold the stray `</I>` in `Takka`. Delete `AUDIO_RE`: dead, the output is
      byte-identical without it (images and link unwrapping already remove
      audio links).
- [x] Tests: 14 new real-snippet tests (30 total). Every fixture is a
      byte-exact substring of `ped.htm`. Mutation check: each of 13 rules
      replaced with a never-matching pattern fails at least one test;
      baseline 0 failures.
- [x] Licence (user decision): stated in the GoldenDict/MDict description, the PTS README, `docs/other_dicts.md`
      (wording also softened from "PTS text only"), the spec and `tech.md`.
      It was first also put in `dict_meta.name`; the user rejected that after
      the device test (no other dictionary does it), so the name is back to
      "PTS Pāḷi-English Dictionary" and the mobile DB was rebuilt.
- [x] README: counts re-measured (16,421 rows, 15,739 words, 16,407 entries,
      9 variant anchors, 61 headwords dropped), JSON-shape wording fixed.
- [x] Rebuild: archive re-packed and checked byte-identical; GoldenDict/MDict
      rebuilt; mobile DB rebuilt.

Declined, with reasons (in `review.md`): CodeRabbit's "anchor regex misses
other attribute orders" (every one of the 16,415 anchors is accounted for);
DeepSeek's `ida` and `Ahu 3,4` claims (disproved on the data); an
empty-output guard in `main()` (speculative for a frozen snapshot).
