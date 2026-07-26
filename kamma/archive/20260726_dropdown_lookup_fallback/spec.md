# Spec: Dropdown Falls Back To The Lookup Table

## Problem
Typing a word that is not a dictionary headword produces an empty suggestion
dropdown, even though pressing enter finds the word perfectly well. Inflected
forms, compounds the deconstructor can split, English (EPD) words and variant
spellings all behave this way.

## Root Cause
The dropdown and the results list read from two different sources.

- **Dropdown** — `searchIndexProvider` (`lib/providers/autocomplete_provider.dart:11`)
  builds an in-memory list from `getAllLemmas()` + `getAllRoots()` +
  `getAllRootFamilies()`, cached to `search_index.json`. About 93k terms.
- **Results** — `searchExact` / `searchPartial` / `searchFuzzy`
  (`lib/database/dao.dart:55`) query the `lookup` table. 1,283,470 keys.

`_updateAutocomplete()` (`lib/screens/search_screen.dart:176`) reads only the
in-memory index and calls `_removeOverlay()` when it is empty. There is no second
source to try.

Measured coverage of `lookup` that the dropdown cannot see:

| kind | rows |
|---|---|
| inflected forms (`headwords` set) | 457,747 |
| deconstructions, no headword | 724,838 |
| grammar | 290,494 |
| EPD (English → Pāḷi) | 79,257 |
| variants | 72,418 |
| spelling / abbrev / help / see | 800 |

Each figure counts *rows*, and the columns overlap, so they do not sum to the
table total. 852,542 rows carry a deconstruction of some kind; the 724,838 above
are those with no headword attached, which is the group the dropdown misses
entirely. The 800 is distinct rows carrying any of those four columns, not a sum.

## Key Measurement
`lookup` is a superset of the in-memory index, not a different vocabulary:

- roots absent from `lookup`: **0** of 753
- root families absent from `lookup`: **0** of 3,142

Both figures are *distinct* values, because `getAllRoots()` and
`getAllRootFamilies()` (`dao.dart:471`, `dao.dart:479`) both select with
`distinct: true`. `family_root` has 3,358 rows but only 3,142 distinct families.
- lemmas absent from `lookup` (numbering stripped the way
  `autocomplete_provider.dart:34` strips it): **46** of 89,273 — 0.05%

So the in-memory index is a ~7% subset. Nothing is lost by consulting `lookup`
when the index comes up empty.

## Fix
Add two fallback tiers to `_updateAutocomplete()`:

1. **In-memory index** — unchanged, instant, tried first.
2. **`dict_entries` prefix query** — new DAO method (`searchDictWordsPrefix`), runs
   only when tier 1 is empty.
3. **`lookup` prefix query** — new DAO method (`searchLookupKeysPrefix`), last
   resort: runs only when tiers 1 and 2 are both empty.

### Why dictionaries before the lookup table
Original design order was lookup, then dictionaries — reversed by explicit user
decision: the lookup table should be the last resort, tried only after the
headword index and every enabled external dictionary have found nothing. The
method names still say `searchLookupKeysPrefix` / `searchDictWordsPrefix`; only the
calling order in `_updateAutocomplete()` changed.

### No Fuzzy Matching In The Dropdown
Both new tiers match on **exact prefix**, not on the folded columns.

- Tier 2 (`searchDictWordsPrefix`) range-scans `word` **once per enabled
  dictionary**, so it can seek on the composite `idx_dict_entries_word
  (dict_id, word)` — **not** `word_fuzzy`.
- Tier 3 (`searchLookupKeysPrefix`) range-scans `lookup_key`, the primary key —
  **not** `fuzzy_key`.

`fuzzy_key` and `word_fuzzy` fold hard: they strip diacritics, drop aspirates and
collapse double consonants, so `kamma`, `kammā`, `kāma` and `kāmā` all reduce to
`kama`. That belongs on the results path, not in a suggestion list.

`_normalizeQuery()` is still applied. It lowercases, strips apostrophes, hyphens,
question marks and exclamation marks, and maps the two alternative niggahita forms
`ṁ` and `ŋ` onto `ṃ` (`dao.dart:667`). That last step is character-set
normalisation, not folding — it does not merge distinct Pāḷi letters — so it is
punctuation handling rather than fuzzy matching, and it is reused unchanged.

Tier 2 results need `distinct`: a word like `kamma` has many rows in one dictionary.

The existing `searchDictFuzzy()` (`dao.dart:614`) is not reused. It matches
`word_fuzzy LIKE 'x%'` with no `dict_id` filter, so it is both fuzzy and unable to
seek the composite index. It stays on the results path, untouched.

### Consequence: Both Fallback Tiers Are Diacritic-Strict
Typing `kamma` will not suggest `kammā` — at byte level `kammā` is not a prefix
match for `kamma`, it differs at the final character. The diacritic has to be typed.

This is accepted, not overlooked:
- Tier 1 still folds via `stripDiacritics`, so every **headword** remains reachable
  without diacritics. Only the fallback tiers are strict.
- A wrong spelling still lands on the closest-match list, which is already tappable.
- Velthuis input (`aa` → `ā`) already gives a fast way to type diacritics.

### Why this stays cheap
Each tier only runs when the one above it found nothing, which means the prefix is
long or unusual, which means the matching range is small. Measured on the real
mobile DB:

```
dict_entries.word range, one dictionary, LIMIT 50                          3ms
lookup_key range, 'akakk'                                        25 rows,  2ms
lookup_key range, 'akakkasa'  (a real empty-tier-1 case)         12 rows,  2ms
```

The worst case stays flat because there is **no `ORDER BY` in SQL** — the `LIMIT`
short-circuits after 200 rows instead of sorting the whole 28,314-row range.
Ordering happens in Dart on at most 200 strings, reusing the shortest-first
comparator already in `autocompleteSuggestionsProvider`.

Tier 3 is rarer still: reaching it needs a prefix that matches nothing in any
enabled dictionary either, so it is DPD-only ground — a real Pāḷi inflection,
compound or grammar form with no dictionary entry of its own.

No dedup is needed between tiers — they are mutually exclusive by construction — but
tier 3 dedups within itself, across dictionaries and across repeated rows.

## Rejected Alternatives
- **Load all 1.29M lookup keys into `searchIndexProvider`.** ~30MB JSON cache and a
  resident `List<String>` in the hundreds of MB. Slower startup, heavier runtime,
  no benefit over a 3ms query.
- **Replace the in-memory index with a single ranked SQL query.** Tempting, since it
  would delete `_buildIndex`, the JSON cache, the version files and three DAO
  methods. But ranking headwords above inflections needs
  `ORDER BY (case when headwords != '' ...)`, which forces a table fetch for every
  row in the range — ~28k rows per keystroke on a two-character prefix. The
  in-memory tier earns its keep as the ranking tier, not the coverage tier.

## Where The Measurements Come From
`../dpd-db/exporter/share/dpd-mobile.db`, built 2026-07-25, containing all six
external dictionaries (bhs, cone, cpd, mw, peu, wordnet). This is the path the
exporter writes to (`tools/paths.py:259`), produced by `just export-mobile`.

Note that `../dpd-db/dpd-mobile.db` and `../dpd-db/exporter/mobile/dpd-mobile.db`
are both zero-byte placeholders, and `~/Documents/dpd-mobile.db` is a stale May
build with only three dictionaries. Do not measure against any of those.

**Index usage must be verified here, never in the unit-test fixture.** The tests
run on `AppDatabase.forTesting(NativeDatabase.memory())`. Drift declares the
`lookup` primary key in `tables.dart`, so tier 2 gets its autoindex there — but
`idx_dict_entries_word` exists only in the exporter's raw SQL, not in the Drift
schema, so the in-memory fixture has no index on `dict_entries` at all. Tier-3
tests will still pass, because SQLite scans a tiny fixture table happily. They
prove correctness, not that the composite index is being used. That claim rests on
the measurement against the real database above, which is the right division per
`AGENTS.md` — no performance tests.

## Which Dictionaries Tier 2 Queries
Only the enabled ones, read from `dictVisibilityProvider`
(`lib/providers/dict_provider.dart:78`), iterated in its `order`. A dictionary the
user has switched off must not produce suggestions, since tapping one would show
nothing.

## Why Nothing Else Changes
- **Closest matches** (`lib/widgets/empty_prompt.dart:70`) are left exactly as they
  are. They render as plain `Text`, but the whole results body is wrapped in
  `TapSearchWrapper` (`lib/screens/search_screen.dart:676`), so they are already
  tappable to search. They remain the final fallback for a misspelling.
- **The search results path** is untouched. It already consults `lookup`; this
  thread only brings the dropdown up to the same coverage.
- **The index build and its JSON cache** are untouched — no rebuild, no cache
  format change, no schema version bump.
- **The two text-cleaning paths** (`_cleanPali()` and `IntentService._clean()`, per
  `AGENTS.md`) are not involved. This is a suggestion-sourcing change, not a
  query-cleaning change.

## New Behaviour
`_updateAutocomplete()` becomes async. Two consequences to handle:

- **Stale results.** The user may type further during the await. Capture the query
  before the call and abandon the result if the field no longer matches.
- **Disposal.** Guard on `mounted` before touching the overlay.

## Test Coverage
`test/database/dao_prefix_suggestions_test.dart` (new), against a fixture DB — data
logic, not UI, so within the `AGENTS.md` testing rule.

Tier 3, `searchLookupKeysPrefix()`:
- an inflected form prefix returns keys the in-memory index lacks
- an EPD English prefix returns keys
- **`kamma` does not return `kammā`** — the guard against fuzzy matching
- **`kama` does not return `kamma`** — no double-consonant collapsing
- the exact query itself is included, not excluded
- a nonsense prefix returns empty
- the limit is respected

Tier 2, `searchDictWordsPrefix()`:
- returns words from a named dictionary
- a disabled dictionary contributes nothing
- duplicate rows for one word collapse to a single suggestion
- the same word in two dictionaries collapses to a single suggestion
- **exact prefix only**, matching tier 3

## Files Changed
- `lib/database/dao.dart` — new `searchLookupKeysPrefix()` and
  `searchDictWordsPrefix()`
- `lib/providers/autocomplete_provider.dart` — two new fallback providers
- `lib/screens/search_screen.dart` — `_updateAutocomplete()` becomes async, tiered
- `test/database/dao_prefix_suggestions_test.dart` (new)
