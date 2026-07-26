# Plan: Dropdown Falls Back To The Lookup Table

## Status: REVIEWED — PASSED (see review.md), awaiting commit permission

## Task 9: Review fixes — DONE
Four findings from an independent subagent review + two CodeRabbit passes, all
fixed. Full detail in `review.md`; summary:
- **major** — `searchLookupKeysPrefix` missed uppercase sutta codes (`DN1.1`,
  18,301 such keys) because it never widened to the uppercase range the way
  `searchExact`/`searchPartial`/`searchClosestMatches` already do. Fixed by
  replicating that exact pattern; added 2 regression tests.
- **minor** — `dictSuggestionsProvider` awaited `dictMetaAllProvider.future` even
  when no dictionary was enabled. Fixed with an early return.
- **minor** — both new DAO methods guarded on `normalized.isEmpty` rather than
  `normalized.length < 2`, letting a punctuation-stripped short query slip past
  the intended minimum. Fixed.
- **major** — making `_updateAutocomplete()` async opened a real race: cancelling
  `_autocompleteDebounce` only stops a timer that hasn't fired, not an
  already-running `await`. `_onSearch` never changes `_controller.text`, so a
  stale in-flight call could resolve after Enter was pressed and reopen the
  dropdown, un-doing Task 8. Fixed with `_autocompleteGeneration`, bumped at
  every action that should invalidate in-flight work (every keystroke, search,
  clear, go-home, home-search, suggestion-tap) and checked instead of the
  weaker text comparison.
→ verify: `flutter analyze` clean; full suite (318 tests) passing

## Task 1: DAO prefix query over `lookup` — DONE
- [ ] Add `searchLookupKeysPrefix(String query, {int limit = 200})` to
      `lib/database/dao.dart`, in the Search section beside `searchClosestMatches`
- [ ] Normalise with `_normalizeQuery(query)` only. **Do not call
      `stripDiacritics`** — no fuzzy matching in the dropdown.
- [ ] Range-scan `lookup_key`, the primary key, using the existing `_nextString()`
      helper. **Not `fuzzy_key`.**
- [ ] Select the key column only — `selectOnly(lookup)..addColumns([lookup.lookupKey])`,
      read back with `row.read(lookup.lookupKey)`. Same shape as
      `searchClosestMatches` (`dao.dart:280`). No row hydration.
- [ ] No `ORDER BY` in SQL. The `LIMIT` must short-circuit the scan.
- [ ] Return `List<String>`
→ verify: `flutter analyze` clean for the file

## Task 2: DAO prefix query over `dict_entries` — DONE
- [ ] Add `searchDictWordsPrefix(List<String> dictIds, String query, {int limit = 50})`
      to `lib/database/dao.dart`, in the External dictionaries section
- [ ] Return `[]` immediately on an empty `dictIds`
- [ ] Same `_normalizeQuery(query)`-only normalisation as Task 1, no
      `stripDiacritics`
- [ ] One range query on `word` **per dict id**, so the composite
      `idx_dict_entries_word (dict_id, word)` can seek. **Not `word_fuzzy`.** Do not
      reuse `searchDictFuzzy()` — it is fuzzy, and its unfiltered `LIKE` cannot use
      the index either.
- [ ] Select the word column only — `selectOnly(dictEntries)..addColumns([dictEntries.word])`,
      read back with `row.read(dictEntries.word)`; dedup into a `Set<String>` across
      dictionaries
- [ ] No `ORDER BY` in SQL, same reason as Task 1
→ verify: `flutter analyze` clean for the file

## Task 3: Fallback providers — DONE

### Deviation from spec (corrected)
`dictSuggestionsProvider` had to filter `visibility.order` against
`dictMetaAllProvider`'s real dictionary ids, not just `visibility.enabled`.
`order` also lists DPD's own internal sections (`dpd_headwords`, `dpd_grammar`,
etc.), which are not rows in `dict_entries` — querying them would have wasted a
range query per keystroke for no possible match.

- [ ] Lift the shortest-first, then alphabetical comparator at
      `autocomplete_provider.dart:97` to a shared top-level function rather than
      duplicating it three times. **Strictly behaviour-preserving** — move the
      comparator body verbatim, change no ordering rule. This is the only existing
      code the thread edits; if it cannot be done without altering tier-1 ordering,
      leave it in place and duplicate instead.
- [ ] Add `lookupSuggestionsProvider` as a
      `FutureProvider.autoDispose.family<List<String>, String>`
- [ ] Add `dictSuggestionsProvider` likewise, reading the enabled ids and their
      order from `dictVisibilityProvider`
- [ ] Guard `query.length < 2` in both, matching `autocompleteSuggestionsProvider`
- [ ] Sort with the shared comparator; cap at 100 to match the existing dropdown cap
→ verify: `flutter analyze` clean

## Task 4: Tier the dropdown — DONE

**Constraint: the existing tier-1 path must be untouched at runtime.** The three
guards below are what make that true, not a good intention.

### Deviation from spec (corrected)
The staleness check could not compare the tiered query against `_controller.text`
directly — `query` is post-`toRoman` transliteration (see `_onChanged`), so for
non-Latin input scripts the two strings never match even when nothing is stale.
Fixed by snapshotting `_controller.text` once at the start of the function and
comparing against that snapshot after each await, instead of against `query`.

- [ ] Make `_updateAutocomplete()` in `lib/screens/search_screen.dart:176` async
- [ ] Tier 1 unchanged: `ref.read(autocompleteSuggestionsProvider(query))`
- [ ] **Guard 1 — no await on the tier-1 path.** When tier 1 has results, show the
      overlay and `return` *before the first `await` in the function body*. A Dart
      async function runs synchronously up to its first await, so tier 1 keeps
      exactly today's synchronous timing. Do not put an await above this branch.
- [ ] **Guard 2 — only fall through when the index is genuinely loaded.**
      `autocompleteSuggestionsProvider` returns `[]` both when nothing matches *and*
      while `searchIndexProvider` is still loading (`autocomplete_provider.dart:60`).
      Falling through on the loading state would hit the database on every keystroke
      during startup and change what the dropdown shows before the index is ready.
      Check `ref.read(searchIndexProvider).hasValue` first; if it is still loading,
      behave exactly as today — remove the overlay and return.
- [ ] Leave a comment on Guard 2 recording that it depends on `searchIndexProvider`
      being a `FutureProvider`. If it ever becomes a synchronous provider, `hasValue`
      is always true and the guard silently stops guarding.
- [ ] **Guard 3 — the `query.length < 2` early return stays first**, before anything
      async, so short queries are untouched
- [ ] Tier 2: await `lookupSuggestionsProvider(query)` only when tier 1 is empty
- [ ] Tier 3: await `dictSuggestionsProvider(query)` only when tier 2 is also empty
- [ ] After **each** await, abandon the result if `!mounted` or if the query no
      longer matches what is in `_controller` — the user may have typed on
- [ ] Empty from all three tiers still calls `_removeOverlay()`, as today
- [ ] Gate a `debugPrint` behind `kDebugMode` when tier 2 or tier 3 fires, naming
      which tier answered. Makes it possible to confirm the feature is working
      during the Android check instead of inferring it from the suggestions.
→ verify: `flutter analyze` clean; dropdown appears for `akakkasacittassa`

### Accepted difference
When all three tiers come up empty, `_removeOverlay()` now runs after two short
queries instead of immediately, so a stale dropdown from the previous keystroke can
linger a few milliseconds longer. Removing it up front instead would make the
dropdown flicker on every keystroke that falls through, which is worse. Watch this
on the first query after a cold start, when the database has not been touched yet —
that is the one case where the delay could become visible.

## Task 5: Tests — DONE
12 tests in `test/database/dao_prefix_suggestions_test.dart`, all passing.
- [ ] Create `test/database/dao_prefix_suggestions_test.dart` covering the seven
      tier-2 cases and the five tier-3 cases in spec.md
- [ ] The two anti-fuzzy assertions are the point of this task: `kamma` must not
      return `kammā`, and `kama` must not return `kamma`
- [ ] Seed dictionary rows with `DictEntriesCompanion`, following the existing
      pattern in `dao_test.dart`
- [ ] These tests prove correctness only. The in-memory fixture has no
      `idx_dict_entries_word` — Drift does not declare it — so they cannot show the
      composite index is used. Do not add a performance test; that claim rests on
      the real-database measurement recorded in spec.md.
→ verify: `flutter test test/database/dao_prefix_suggestions_test.dart`

## Task 6: Smoke gate — DONE
- `flutter analyze`: 0 errors, same 94 pre-existing infos in the vendored
  `pali_transliterator/` files as before this thread
- `flutter test`: full suite, 316 tests, all passing
- Real Android check confirmed by the user, including the tier-reorder (Task 7)
  and the no-results-verdict gate (Task 8)

## Task 7: Reorder tiers — dictionaries before lookup — DONE

After manual verification of Tasks 1–6, the user decided the tier order was wrong:
the lookup table should be the last resort, not the first fallback. Swapped in
`_updateAutocomplete()`:

- Tier 2 is now `dictSuggestionsProvider` (external dictionaries)
- Tier 3 is now `lookupSuggestionsProvider` (the lookup table), tried only when
  tiers 1 and 2 both find nothing
- Debug tier labels updated to match (`tier 2 (dict)`, `tier 3 (lookup)`)
- No DAO or provider renaming — `searchLookupKeysPrefix` /
  `searchDictWordsPrefix` and their providers keep their names; only the calling
  order changed
→ verify: `flutter analyze` clean

## Task 8: Withhold the no-results verdict while suggestions are visible — DONE

Found on Android: typing `akakkasacitte` showed `akakkasacittena` in the dropdown
while the results area simultaneously declared "No results" with closest matches.
Both surfaces were individually correct — the suggestion resolves to a real
deconstructor entry when completed; the partial text genuinely matches nothing —
but delivering a failure verdict while still offering completions is
contradictory.

Fix: one rule — don't declare failure while suggestions are on screen.

- New `_suggestionsVisible` field, set inside `setState` by `_showOverlay` /
  `_removeOverlay` so the results area rebuilds when the dropdown opens or closes
- The no-results branch returns the quiet `EmptyPrompt` instead of
  `NoResultsWithSuggestions` while `_suggestionsVisible` is true
- `dispose` now removes the overlay inline rather than via `_removeOverlay()`,
  because the latter calls `setState`, which is not allowed during dispose
- Accepted limit: the gate keys off dropdown *visibility*, not off a deeper
  "could this still become a word" check. Dismissing the dropdown by tapping
  elsewhere brings the verdict back mid-word — reasonable, since dismissing
  suggestions signals the user is done with them.

Rejected alternative (external review): filter the lookup fallback to keys with a
headword or root, removing ~814k deconstructor/variant/spelling-only keys from
the dropdown. Rejected because its premise is false — those keys DO resolve to
rendered results (the deconstructor card) when completed, and surfacing exactly
those non-headword forms was the primary point of this thread. The mismatch was
timing, not dead suggestions.

→ verify: `flutter analyze` clean; full suite passing (316 tests)

## Manual Verification (Android)
1. Type `akakkasacittassa` — an inflected form, not a headword. Dropdown should
   offer it. Today it is blank.
2. Type `generosity` — an EPD English key. Dropdown should offer it.
3. Type `kamma` — a real headword. Dropdown must look exactly as it does today,
   with no lag; neither fallback tier must fire.
3b. Start the app cold and type immediately, before the search index has loaded.
   Behaviour must match today's exactly — no dropdown, no database hit per
   keystroke. This is Guard 2.
4. Type `kammā` — suggestions must be for `kammā` only. Typing `kamma` must **not**
   offer `kammā`. No fuzzy matching in the fallback tiers.
5. Type a word only an external dictionary has — a Sanskrit or BHS form absent from
   DPD. Dropdown should offer it, from tier 2. Then switch that dictionary off in
   settings and retype: the suggestion must disappear.
5b. Type a word that exists in an enabled dictionary AND is a DPD lookup key (e.g.
   a headword that also has a Cone/CPD entry not covered by tier 1). Confirm via
   the debug log that tier 2 (dict) answers, not tier 3 (lookup) — dictionaries
   must be checked first.
6. Type nonsense (`zzzqq`) — no dropdown, and the no-results screen still shows
   tappable closest matches.
7. Type quickly and delete — no stale dropdown from an abandoned query.
8. Type `akakkasacitte` — dropdown offers `akakkasacittena`; the area behind it
   must show the quiet search prompt, NOT "No results". Tap elsewhere to dismiss
   the dropdown — the no-results verdict with closest matches should then appear.
   Complete the word — the deconstructor result should render.

## Out Of Scope
- `empty_prompt.dart` closest matches — already tappable via `TapSearchWrapper`,
  and they stay the final fallback for a misspelling
- `searchDictFuzzy()` and `searchFuzzy()` on the results path — left alone. Fuzzy
  matching stays where it belongs, in the results, and out of the dropdown.
- Tier 1's existing `stripDiacritics` folding — unchanged, so headwords stay
  reachable without typing diacritics
- The index build, its JSON cache, and the results path — untouched

## Commit Message
```
feat: suggestions now appear for inflections, compounds and English words

The suggestion dropdown was built only from headwords, roots and
families — about 93k terms — while the search itself reads the lookup
table's 1.28M keys. Anything that was not a headword produced a blank
dropdown even though pressing enter found it.

The dropdown now falls back to the enabled external dictionaries when the
headword index comes up empty, and to DPD's own lookup table as a last
resort when the dictionaries come up empty too. Both fallbacks match on
exact prefix, so no fuzzy guesses appear in the suggestion list, and they
are bounded by a limit rather than a sort, so they only cost a few
milliseconds on the long, unusual prefixes where the tier above finds
nothing.

Also fixed: while the dropdown offered a completion, the results area
could simultaneously declare "No results" for the same unfinished text —
two parts of the screen disagreeing at once. The no-results verdict is
now withheld while the dropdown is visible.
```
