# Plan — Rank fuzzy search results by closeness

Spec: `spec.md` in this directory. Read it first.

## Architecture Decisions

- **One shared scoring helper, new file `lib/utils/fuzzy_rank.dart`.** Both fuzzy
  paths (DPD headwords in the DAO, external dictionaries in the provider) must
  score identically. AGENTS.md already records a bug caused by two text-handling
  paths drifting apart; a single pure function prevents a repeat. The file is
  new rather than folded into `lib/utils/diacritics.dart`, which is reserved for
  the exporter-parity stripping logic and must not accumulate unrelated code.

- **Score is a single `int`, not a record or class.** `tier * 1000 + delta`
  collapses two criteria into one comparable value, so both call sites sort with
  a plain `compareTo`. Cheaper and clearer than a comparator object.

- **Ranking applied inside `searchFuzzy`, not in `_fetchHeadwords`.**
  `_fetchHeadwords` is shared with `searchExact` and `searchPartial`; its
  alphabetical sort is correct for those and must stay untouched.

- **Score is computed per lookup row, then reduced to the minimum per headword
  id.** One headword is reachable from many lookup keys; it should be ranked by
  its best match, not an arbitrary one.

- **`fromRows` gains a required `query` named parameter.** It currently has no
  access to what the user typed, and scoring needs it. Only one production call
  site and one test helper construct it.

- **Deliberately not abstracted:** no shared "ranked search" base, no generic
  sorting strategy. Two call sites, one helper, nothing more.

## Phase 1 — Scoring helper

- [x] Create `lib/utils/fuzzy_rank.dart` with a pure `fuzzyCloseness` function
      taking the query, the query's fuzzy key, the candidate word and the
      candidate's fuzzy key, returning `int` (lower is closer).
      Tier 0 when candidate key equals query key, else 1.
      Delta is `(candidate.length - query.length).abs()`, clamped to 999.
      Score is `tier * 1000 + delta`.
      → verify: `flutter analyze lib/utils/fuzzy_rank.dart` reports no issues.
      DONE: no issues found.

- [x] Add `test/utils/fuzzy_rank_test.dart` covering: equal key and equal length
      scores 0; equal key with a longer candidate scores by length delta;
      prefix-only match scores above every equal-key match; the clamp holds for
      an extreme length difference; and the concrete `rūpaṃ` vs `ruppaṃ` vs
      `ruppamāna` ordering from the spec's worked example.
      → verify: `flutter test test/utils/fuzzy_rank_test.dart`, all pass.
      DONE: 5/5 passed.

- [x] Phase verification: `flutter test test/utils/` passes with no regressions.
      → verify: `flutter test test/utils/`, all pass.
      DONE.

## Phase 2 — Rank the DPD headword fuzzy tier

- [x] In `lib/database/dao.dart`, change `searchFuzzy` (line ~124) to keep both
      the normalised query (diacritics intact, e.g. `rupaṃ`) and its stripped key
      (`rupam`) — currently only the stripped form survives. Build a
      `Map<int, int>` of headword id to best score by walking `lookupRows`,
      scoring each row from its `lookupKey` and `fuzzyKey` (nullable — treat null
      as `''`), and keeping the minimum per id. Pass the map's keys to
      `_fetchHeadwords`, then re-sort the returned list by score ascending with
      `paliSortKey(lemma1)` as the tiebreak.
      Do **not** touch `_fetchHeadwords`, `searchExact` or `searchPartial`.
      → verify: `flutter analyze lib/database/dao.dart` reports no issues.
      DONE: no issues found.

- [x] Add `test/database/fuzzy_ranking_test.dart` running the real DAO against
      `../dpd-db/exporter/share/dpd-mobile.db`, following the existing pattern in
      `test/search_roots_test.dart` (`AppDatabase.forTesting(NativeDatabase(file))`).
      Skip the test gracefully when the file is absent so it never breaks a
      checkout without the sibling repo. Assert that for `rupaṁ` every `rūpa*`
      lemma precedes every `ruppa*` lemma; for `kammam` that `kamma 1` precedes
      `kama 1`; for `dhammam` that `dhamma 1.01` precedes `dama`.
      → verify: `flutter test test/database/fuzzy_ranking_test.dart`, all pass.
      DONE: 4/4 passed.

- [x] Confirm the exact and partial tiers are unaffected: assert in the same test
      that `searchExact('rūpaṃ')` and `searchPartial('rūpa')` return the same
      lemmas in the same order as recorded in the spec's measured baseline.
      → verify: `flutter test test/database/`, all pass.
      DONE: 72/72 passed (68 pre-existing + 4 new).

## Phase 3 — Rank the external-dictionary fuzzy tier

- [x] Confirm `DictEntry.wordFuzzy` is non-empty for rows returned by
      `searchDictFuzzy` — check the column definition in `lib/database/tables.dart`
      and spot-check the mobile database directly.
      → verify: a SQL count of `dict_entries` rows with empty or null
      `word_fuzzy` returns 0; record the number in the task notes.
      DONE: 0 empty/null out of 643,399 rows.

- [x] In `lib/providers/dict_provider.dart`, add a required `query` named
      parameter to `DictRawSearchResults.fromRows` and replace the plain
      `paliSortKey` sort of `fuzzyRows` (line ~242) with a `fuzzyCloseness` sort,
      `paliSortKey(word)` as tiebreak. Compute the query's fuzzy key once with
      `stripDiacritics(query.toLowerCase())`, matching how `searchDictFuzzy` is
      already called at line ~334. Pass `query` through from the provider at
      line ~340. Leave `_groupDictEntries` (exact and partial tiers) alone.
      → verify: `flutter analyze lib/providers/dict_provider.dart` reports no issues.
      DONE: no issues found.

- [x] Update the `_raw` helper in `test/providers/dict_provider_test.dart` to
      supply `query`, and add a case asserting a diacritics-only match outranks a
      doubled-consonant near-miss within one dictionary group.
      → verify: `flutter test test/providers/dict_provider_test.dart`, all pass.
      DONE: 29/29 passed.

## Phase 4 — Full verification

- [x] Run the whole suite and the analyzer.
      → verify: `flutter test` passes and `flutter analyze` reports no new issues.
      DONE: 374/374 tests passed. `flutter analyze` shows 51 pre-existing infos,
      none in files touched by this thread — no new issues.

- [x] Re-measure the three reported queries through the DAO and record the actual
      before/after orderings in this file, so the fix is evidenced rather than
      asserted.
      → verify: `rūpa 1` is the first fuzzy result for `rupaṁ`; `kamma 1` first
      for `kammam`; `dhamma 1.01` first for `dhammam`.
      DONE — measured against `../dpd-db/exporter/share/dpd-mobile.db`:

      ```
      BEFORE (spec baseline)
      "rupaṁ"   ruppa | ruppanta | ruppamāna 1 | ruppamāna 2 | ruppi | rūpa 1 | …
      "kammam"  kama 1 | kama 2 | kama 3 | kami | kamma 1 | …
      "dhammam" dama | damas | damma 1.1 | damma 1.2 | dāma 1 | dāma 2 | dhama | … | dhamma 1.01 | …

      AFTER (this fix)
      "rupaṁ"   rūpa 1 | rūpa 2 | rūpa 3 | rūpa 4 | rūpa 5 | rūpa 6 | rūpa 7 | rūpa 8 | ruppa | ruppanta
      "kammam"  kamma 1 | kamma 2 | kamma 5 | kamma 6 | kamma 7 | kamma 8 | khama 1 | khama 2 | khamanta | khamā
      "dhammam" dhamma 1.01 | dhamma 1.02 | dhamma 1.03 | dhamma 1.04 | dhamma 1.05 | dhamma 1.06 | dhamma 1.07 | dhamma 1.08 | dhamma 1.09 | dhamma 1.10
      ```

- [x] Hand off for manual Android testing: search `rupaṁ`, `kammam`, `dhammam`
      and confirm the wanted word now appears at the top of the Fuzzy Results
      section. Wait for explicit confirmation before any commit.
      → verify: user confirms on device.
      DONE: user confirmed main-screen results are correct. User then reported
      the dropdown still disagrees with the main screen for `kammam`/`dhammam` —
      see Addendum in spec.md and Phase 5 below.

## Phase 5 — Dropdown exact-fuzzy-key rescue tier (addendum)

See spec.md "Addendum" section for full root-cause analysis. Summary: the
dropdown's tier 1 index (`autocompleteSuggestionsProvider`) is built from bare
lemmas only; a lemma's own collapsed key can be *shorter* than a mistyped
inflected query's collapsed key, so it structurally can never match, and the
real answer (an inflected `lookup_key` row) isn't in that index at all. This
is a different mechanism from Phases 1–4 and needs its own fix.

### Architecture decisions (Phase 5)

- **New DAO method, not a change to `searchFuzzy`.** The dropdown needs raw
  `lookup_key` strings (so tapping one can exact-match), not headword objects.
  Reuses the existing `fuzzyCloseness` helper from `lib/utils/fuzzy_rank.dart` —
  no new scoring logic.
- **Exact `fuzzy_key` equality, not a prefix range scan.** This is deliberately
  narrower than tiers 1/3's prefix matching: it only fires when the *entire*
  typed string folds to match a complete real word, which is what makes it
  cheap and rarely-firing-while-mid-word (see spec's "naturally cheap"
  reasoning).
- **`_updateAutocomplete` restructured, not rewritten.** Tier 1's synchronous
  paint (Guard 1) and the index-loading skip (Guard 2) are preserved exactly.
  The rescue tier runs after tier 1's synchronous check and, when it finds
  something, re-shows the overlay with rescue results prepended — it can only
  upgrade an already-shown dropdown, never delay tier 1's first paint.
- **No UI test for the merge logic**, per AGENTS.md ("Do not add UI tests for
  this app"). Only the new DAO method (data logic) gets a test.

### Tasks

- [x] Add `searchFuzzyExactKeyMatches(String query, {int limit = 20})` to
      `lib/database/dao.dart`, near `searchFuzzy`. Normalize the query the same
      way (`_normalizeQuery`, then `stripDiacritics`), query
      `lookup` where `fuzzyKey.equals(queryFuzzyKey)` (equality, not range),
      score each returned `lookupKey` with `fuzzyCloseness` against the query,
      sort by score then `paliSortKey(lookupKey)`, return the sorted
      `lookupKey` strings.
      → verify: `flutter analyze lib/database/dao.dart` reports no issues.
      DONE: no issues found.

- [x] Add `test/database/fuzzy_exact_key_matches_test.dart` against
      `../dpd-db/exporter/share/dpd-mobile.db` (skip gracefully if absent, same
      pattern as `fuzzy_ranking_test.dart`). Assert: querying `kammam` returns
      `kammaṃ` and `kāmaṃ` among the results with `kammaṃ` ranked at or before
      `kāmaṃ` (both are tier 0 with the same length, so equal-or-better rank is
      the correct assertion — do not assert a strict single winner unless the
      measured order calls for it); querying `dhammam` returns `dhammaṃ`;
      querying a nonsense string like `xyzzyq` returns an empty list.
      → verify: `flutter test test/database/fuzzy_exact_key_matches_test.dart`,
      all pass.
      DONE: 4/4 passed.

- [x] Add `fuzzyExactSuggestionsProvider` to
      `lib/providers/autocomplete_provider.dart`: a
      `FutureProvider.autoDispose.family<List<String>, String>` wrapping the new
      DAO method, following the existing shape of `lookupSuggestionsProvider`.
      Guard `query.length < 2` the same way as the other tiers.
      → verify: `flutter analyze lib/providers/autocomplete_provider.dart`
      reports no issues.
      DONE: no issues found.

- [ ] Restructure `_updateAutocomplete` in `lib/screens/search_screen.dart`
      (currently `lib/screens/search_screen.dart:204`) exactly as specified in
      spec.md's "Resolution" paragraph:
      1. Tier 1 sync check unchanged — if non-empty, call `_showOverlay`
         immediately (Guard 1 preserved), but do **not** `return` yet.
      2. If `searchIndexProvider` lacks a value (Guard 2), remove the overlay
         if tier 1 was empty and return — unchanged early-exit behavior.
      3. Snapshot `_autocompleteGeneration` as `requestGeneration` (existing
         pattern).
      4. `await` the new `fuzzyExactSuggestionsProvider`. Check
         `mounted && _autocompleteGeneration == requestGeneration` same as
         tiers 2/3.
      5. If the rescue result is non-empty, build a merged list — rescue
         results first, then tier 1's `suggestions` with any string already in
         the rescue list removed — and call `_showOverlay(merged)`, then
         return.
      6. If tier 1 was non-empty and the rescue was empty, return (nothing to
         upgrade — tier 1's paint stands).
      7. Otherwise (both tier 1 and the rescue were empty), fall through into
         the existing tier 2/tier 3 logic unchanged.
      Update the guard comments in the function to describe the new step,
      matching the doc-comment style already used for Guards 1–2.
      → verify: `flutter analyze lib/screens/search_screen.dart` reports no
      issues.
      DONE: no issues found.

- [x] Full verification: run the whole suite and the analyzer.
      → verify: `flutter test` passes and `flutter analyze` reports no new
      issues.
      DONE: 378/378 tests passed (374 prior + 4 new). `flutter analyze` shows
      the same 51 pre-existing infos, none in files touched by this thread.

- [x] Hand off for manual Android testing: type `kammam` and `dhammam` (without
      committing the search) and confirm the dropdown's top suggestion now
      matches what the main screen's fuzzy tier ranks first for the same query.
      Also type a few ordinary partial words (e.g. `budd`, `dham`) and confirm
      the dropdown still appears instantly with no perceptible delay, to
      confirm Guard 1 held. Wait for explicit confirmation before any commit.
      → verify: user confirms on device.
      DONE: dropdown confirmed correct (shows `kammaṃ`/`dhammaṃ`). User then
      found the MAIN SCREEN's top result still wrong (`kammakāri`/
      `dhammacchariya` instead of `kamma`/`dhamma`) — a third, distinct bug.
      See Addendum 2 in spec.md and Phase 6 below.

## Phase 6 — Promote genuine fuzzy-exact matches into the Exact tier (addendum 2)

See spec.md "Addendum 2" for full root-cause analysis. Summary: `kamma` was
already correctly ranked first *within* the Fuzzy tier by Phases 1–4, but
`SplitResultsList` renders the "Partial Results" divider *above* "Fuzzy
Results" unconditionally, and `searchPartial('kammam')` genuinely (and
coincidentally) finds two unrelated real headwords — `kammamakari` and
`kammamakāsi` — via literal substring match, which the user sees first.

### Architecture decisions (Phase 6)

- **New DAO method `searchFuzzyExact`, not a change to `searchExact` or
  `searchFuzzy`.** Keeps each method's contract single-purpose: `searchExact`
  stays strictly literal, `searchFuzzy` stays the prefix-ranged full fuzzy
  tier. `searchFuzzyExact` is the equality-only (tier-0) slice, mirroring the
  resolution path (`_extractIds` → `_fetchHeadwords`) already used by
  `searchFuzzy` and `searchFuzzyExactKeyMatches`.
- **Rescue only fires when the literal exact search is empty.** Every
  already-working exact search (e.g. `buddha`) stays byte-for-byte unchanged
  and pays no extra DB cost — the change is invisible unless `searchExact`
  would otherwise have returned nothing.
- **Fixed at the provider layer (`exactResultsProvider`), not in
  `search_screen.dart` or `split_results_list.dart`.** The existing dedup
  logic (`exactIds` filtering `partial`, `exactAndPartialIds` filtering
  `fuzzy`) already excludes anything present in `exact` — promoting these
  matches into `exact` fixes tier ordering for free, with zero UI-layer
  changes.

### Tasks

- [x] Add `searchFuzzyExact(String query)` to `lib/database/dao.dart`, near
      `searchFuzzy`. Normalize the same way (`_normalizeQuery`, then
      `stripDiacritics`), query `lookup` where `fuzzyKey.equals(queryFuzzyKey)`
      (equality, matching `searchFuzzyExactKeyMatches`'s WHERE clause), extract
      ids with `_extractIds`, resolve with `_fetchHeadwords`.
      → verify: `flutter analyze lib/database/dao.dart` reports no issues.
      DONE: no issues found.

- [x] Add a case to `test/database/fuzzy_ranking_test.dart` (or a new test file
      following the same DB-backed, skip-if-absent pattern): `searchFuzzyExact`
      on `kammam` returns headwords including `kamma 1`; on `dhammam` returns
      headwords including `dhamma 1.01`; on `buddha` (a query with a genuine
      literal exact hit) is not asserted at all here (that's covered by the
      provider-level behavior, not this method — this method has no knowledge
      of whether a literal hit exists).
      → verify: `flutter test test/database/`, all pass.
      DONE: 3 new cases added to `fuzzy_ranking_test.dart`, 7/7 in that file pass.

- [x] In `lib/providers/search_provider.dart`, change `exactResultsProvider`:
      call `dao.searchExact(query)` as today; if the result is empty, call
      `dao.searchFuzzyExact(query)` and use that instead; if the literal result
      is non-empty, use it unchanged (no second DB call). Keep the existing
      `enableSearchTiming` block wrapping whichever result is chosen.
      → verify: `flutter analyze lib/providers/search_provider.dart` reports no
      issues.
      DONE: no issues found.

- [x] Full verification: run the whole suite and the analyzer.
      → verify: `flutter test` passes and `flutter analyze` reports no new
      issues.
      DONE: 381/381 tests passed (378 prior + 3 new). `flutter analyze` shows
      the same 51 pre-existing infos, none new.

      Mid-verification finding, fixed before this checkbox: the first
      implementation of `searchFuzzyExact` resolved ids via `_fetchHeadwords`,
      whose sort is plain alphabetical — for `kammam` that put `kama 1` ahead
      of `kamma 1`, because `kamaṃ`, `kammaṃ`, `kāmaṃ`, `khamaṃ` and `kkamaṃ`
      are *all* genuine tier-0 matches (same bug shape as the original thread,
      recurring one layer up). Fixed by extracting the scoring/ranking block
      already used by `searchFuzzy` into a shared private helper,
      `_rankedHeadwordsByCloseness`, and having `searchFuzzyExact` use it too
      — so length-delta discrimination applies here exactly as it does in the
      Fuzzy tier, and the two paths can't drift apart.

- [x] Re-measure `kammam` and `dhammam` through `exactResultsProvider`'s
      underlying DAO calls (or via `dao.searchExact` + the new fallback logic
      manually composed in a throwaway check) and record the actual top result
      in this file as evidence.
      → verify: `kamma 1` (or another `kamma N`) is first for `kammam`;
      `dhamma 1.01` first for `dhammam`.
      DONE — measured against `../dpd-db/exporter/share/dpd-mobile.db`:

      ```
      "kammam"  literalExact=0
        effectiveExact = kamma 1 | kamma 2 | kamma 5 | kamma 6 | kamma 7 |
                          kamma 8 | khama 1 | khama 2 | khamanta | khamā |
                          khami | kama 1 | kama 2 | kama 3 | kami | kāma 1 |
                          kāma 2 | kāma 3 | kāma 4 | kāmaṃ 1 | …

      "dhammam" literalExact=0
        effectiveExact = dhamma 1.01 | dhamma 1.02 | … | dhamma 2.1 | dhammā |
                          damma 1.1 | damma 1.2 | dhama | dhamanta 1 | …

      "buddha"  literalExact=2 (genuine literal hit)
        effectiveExact = buddha 1 | buddha 2   -- unchanged, no rescue call made
      ```

- [x] Hand off for manual Android/device testing: search (commit, not just
      autocomplete) `kammam` and `dhammam` and confirm the very first result on
      the main screen — above any "Partial Results" divider — is `kamma`/
      `dhamma`, matching the dropdown. Also search an ordinary word with a real
      exact hit (e.g. `buddha`) and confirm nothing changed. Wait for explicit
      confirmation before any commit.
      → verify: user confirms on device.
      DONE: user confirmed all three phases (main fuzzy, dropdown, exact-tier
      promotion) tested and correct on device.

## Review

See `review.md`. Verdict: PASSED. CodeRabbit found one minor issue in
`searchFuzzyExactKeyMatches` (SQL `limit` applied before closeness sort,
could theoretically drop the true closest match on a very ambiguous key) —
fixed by sorting the full result set first, then limiting. Re-verified:
`flutter analyze` clean, `fuzzy_exact_key_matches_test.dart` and
`fuzzy_ranking_test.dart` pass, full suite 381/381.
