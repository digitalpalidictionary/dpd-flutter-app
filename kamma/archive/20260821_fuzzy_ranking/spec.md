# Spec — Rank fuzzy search results by closeness, not just alphabet

## Overview

A user reported: *"When you write a declension in the search bar, like rupaṁ for
example (maybe unaware of the undeclined form for that word) then it doesn't
show the dictionary entry for rupa, or even rupaṁ."*

Their diagnosis was wrong on two counts, but the underlying complaint is real.

**Declension lookup already works.** `rūpaṃ` is a `lookup_key` in the database
and maps directly to the eight `rūpa` headwords. Any inflected form resolves to
its undeclined entry through the `lookup` table.

**There is no `rupa` or `rupaṃ`.** Verified against the mobile database: no
`lookup_key` starts with unmacroned `rupa` at all. The user simply omitted the
macron.

**But the fuzzy fallback that should rescue them is unusable in practice.**
Searching `rupaṁ` *does* return the `rūpa` headwords — ranked 6th to 13th, buried
under five full `ruppa` entries. In the default classic display mode each result
is a complete dictionary entry, so `rūpa` sits several screens down. The user
scrolled, saw only `ruppa`, and concluded the word wasn't there.

## Verified current behaviour

Measured by running the app's own `DpdDao` against
`../dpd-db/exporter/share/dpd-mobile.db`:

```
"rupaṁ"   exact=0  partial=0  fuzzy=13
          ruppa | ruppanta | ruppamāna 1 | ruppamāna 2 | ruppi |
          rūpa 1 | rūpa 2 | … | rūpa 8

"kammam"  fuzzy=31
          kama 1 | kama 2 | kama 3 | kami | kamma 1 | …

"dhammam" fuzzy=32
          dama | damas | damma 1.1 | damma 1.2 | dāma 1 | dāma 2 |
          dhama | dhamanta 1 | dhamanta 2 | dhami 1 | dhami 2 | dhamma 1.01 | …
```

In every case the word the user actually wanted is present but pushed down by
alphabetically earlier near-misses.

## Root cause

`searchFuzzy` (`lib/database/dao.dart:124`) does an indexed range scan on
`fuzzy_key`, then hands the resulting headword ids to `_fetchHeadwords`
(`lib/database/dao.dart:173`), which sorts purely by `paliSortKey(lemma1)`.
There is no relevance signal at all: a row whose `fuzzy_key` **equals** the
query's key (`rūpaṃ` → `rupam`, a diacritics-only difference) is treated
identically to one that merely **starts with** it (`ruppamāna` → `rupamana`).
Because `ru` sorts before `rū` in the Pāḷi alphabet, `ruppa*` always wins.

The external-dictionary fuzzy tier has the same defect:
`DictRawSearchResults.fromRows` (`lib/providers/dict_provider.dart:226`) sorts
`fuzzyRows` by `paliSortKey(word)` and nothing else.

## What it should do

Rank fuzzy results by closeness to what the user typed, using a two-part score
(lower is closer):

1. **Tier** — the candidate's fuzzy key equals the query's fuzzy key (0), or
   merely starts with it (1).
2. **Length delta** — `|candidate.length - query.length|`, comparing the
   *undiacriticised original* strings.

Alphabetical order remains the tiebreak within an equal score.

Length delta is the key signal. The fuzzy key folds away three different things
— diacritics, aspirate `h`, and doubled consonants — but only the last two
change the character count. So an equal length means the candidate differs from
the query by diacritics alone, which is exactly the mistake a user makes when
they omit a macron.

Worked example, query `rupaṁ` (normalised `rupaṃ`, length 5, key `rupam`):

| candidate | key | len | tier | delta | score |
|---|---|---|---|---|---|
| `rūpaṃ` | `rupam` | 5 | 0 | 0 | **0** |
| `ruppaṃ` | `rupam` | 6 | 0 | 1 | 1 |
| `ruppamāna` | `rupamana` | 9 | 1 | 4 | 1004 |

Expected outcome: `rūpa 1`–`rūpa 8` first, then `ruppa`, `ruppanta`, and so on.
Likewise `kamma 1` ahead of `kama`/`kāma` for `kammam`, and `dhamma 1.01` ahead
of `dama`/`dāma`/`dhama` for `dhammam`.

## Scope

Both fuzzy tiers, confirmed with the user:

- **DPD headwords** — `searchFuzzy` in `lib/database/dao.dart`
- **External dictionaries** — `DictRawSearchResults.fromRows` in
  `lib/providers/dict_provider.dart`

The scoring rule lives in one shared helper so the two paths cannot drift apart.

## Constraints

- **`_fetchHeadwords` is shared** by `searchExact` (line 73), `searchPartial`
  (line 115) and `searchFuzzy` (line 149). Its alphabetical sort must not
  change — the ranking is applied afterwards, inside `searchFuzzy` only.
- **No database or exporter change.** `fuzzy_key` and `word_fuzzy` are already
  present and correct; this is pure presentation ordering.
- **The 50-row lookup limit is safe.** The range scan walks the
  `idx_lookup_fuzzy_key` index in `fuzzy_key` order, and an exact-key row always
  sorts before any longer prefix extension of it, so tier-0 candidates are never
  truncated away. Verified: for `rupam` the first two rows returned are `ruppaṃ`
  and `rūpaṃ`.
- No UI changes. The "Fuzzy Results" divider and tier layout stay as they are.
- Per AGENTS.md, tests cover data logic only — no UI tests.

## Assumptions & uncertainties

- **Assumed:** comparing `String.length` is adequate for length delta. All Pāḷi
  and Sanskrit diacritics in the data are precomposed BMP characters, so code
  units equal characters. Decomposed input typed by a user would inflate the
  length and mis-score; judged rare enough to ignore, and it degrades to today's
  behaviour rather than breaking.
- **Assumed:** `DictEntry.wordFuzzy` is populated for every row the fuzzy query
  can return — it must be, since `searchDictFuzzy` matches on that column.
  To confirm when implementing.
- **Assumed:** the external-dictionary fuzzy tier is grouped per dictionary and
  each group is short, so ranking there is an improvement rather than a fix for
  an acute problem. The user asked for it anyway.
- **Not verified:** how the ranking behaves for non-Pāḷi (English) dictionary
  words, where length delta carries less meaning. Expected to be harmless.

## How we'll know it's done

- Searching `rupaṁ` lists `rūpa 1`–`rūpa 8` before any `ruppa` entry.
- Searching `kammam` lists `kamma 1` before `kama 1`.
- Searching `dhammam` lists `dhamma 1.01` before `dama`.
- Exact and partial tiers are byte-for-byte unchanged for the same queries.
- The scoring helper has unit tests covering: equal key + equal length, equal key
  + longer candidate, prefix-only match, and alphabetical tiebreak.
- `flutter test` passes in full.

## What's not included

- Editing distance, phonetic matching, or frequency weighting.
- Changing the `lookup`/`fuzzy_key` data or the exporter.
- Reordering the exact or partial tiers.

## Addendum — the autocomplete dropdown needs its own fix

After the above shipped, the user tested and found the **dropdown** (the
suggestion list shown while typing, before a search is committed) still
disagreed with the now-fixed main screen: for `kammam` the dropdown showed
`kāmaṃ` while the main screen showed `kammakāri`/`kamma 1`; for `dhammam` the
dropdown showed `dhamamāna` while the main screen showed `dhammacchariya`.

**This is not the same bug and not fixed by the change above.** The dropdown
never calls `searchFuzzy` at all. It runs a completely separate pipeline in
`lib/providers/autocomplete_provider.dart`, with its own tiered fallback in
`_updateAutocomplete` (`lib/screens/search_screen.dart:204`).

### Root cause, verified

Tier 1 (`autocompleteSuggestionsProvider`) is a binary-search prefix match
against an in-memory index built once from **bare lemmas only**
(`dao.getAllLemmas()` + roots + root families — see `searchIndexProvider`,
`lib/providers/autocomplete_provider.dart:12`). The match rule is
`key.startsWith(normalizedQuery)`, where both `key` and `normalizedQuery` are
`stripDiacritics(...).toLowerCase()`.

`stripDiacritics` collapses doubled consonants (`AGENTS.md` "Fuzzy Keys" /
`lib/utils/diacritics.dart`). This is where the two tiers structurally diverge:

- The lemma `kamma` collapses to `kama` (4 chars) — **shorter** than the
  query's collapsed form.
- The query `kammam` (standing in for `kammaṃ` typed without the nasal mark)
  collapses to `kamam` (5 chars).
- `kama` cannot satisfy `key.startsWith('kamam')` — it's not even long enough.
  The lemma is excluded from the candidate set entirely, not merely ranked low.

The word the user actually wants, `kammaṃ`, is the **inflected accusative
form** — a `lookup_key` row, not a lemma. It isn't in the index at all,
because the index is built from lemmas only. Verified directly against the
lookup table:

```
lookup_key='kamma'   fuzzy_key='kama'    -- too short, excluded from tier 1
lookup_key='kammaṃ'  fuzzy_key='kamam'   -- exact match, but not indexed by tier 1
lookup_key='kāmaṃ'   fuzzy_key='kamam'   -- exact match, IS a lemma, coincidentally wins
```

`kāmaṃ` is a real, unrelated headword (an indeclinable) whose own key happens
to equal the query's collapsed key exactly, so it passes the prefix test and
wins tier 1 by accident. Once tier 1 returns anything non-empty, `_updateAutocomplete`
returns immediately — tiers 2/3 (dict, lookup-prefix) never run. Same mechanism
for `dhammam` → `damam`: lemma `dhamma` collapses to `dama` (too short,
excluded), `dhamamāna` collapses to `damamana` (a genuine but unrelated prefix
match that wins), and the wanted `dhammaṃ` is once again an inflected lookup
row absent from the index.

Confirmed against the database: `select lookup_key from lookup where
fuzzy_key='kamam'` returns `kamaṃ, kammaṃ, kāmaṃ, khamaṃ, kkamaṃ` — a small,
well-defined set of genuine exact-fuzzy-key matches, the same signal
`searchFuzzy` already uses as tier 0.

### What it should do

Add a new tier-0 rescue to the dropdown: an **exact** `fuzzy_key` equality
lookup (not a prefix scan) against the `lookup` table, ranked with the same
`fuzzyCloseness` helper already built for the main screen. Because this asks
"does a real inflected form have exactly this folded form", it directly finds
`kammaṃ`/`dhammaṃ` — the rows tier 1's lemma-only index structurally cannot
reach.

Ordering requirement: when this tier-0 rescue finds anything, its results must
appear **ahead of** tier 1's, since a tier-0 exact-fuzzy-key match is strictly
stronger evidence of intent than a coincidental prefix hit. Tapping a
suggestion from this tier sets the search box to that literal `lookup_key`
(e.g. `kammaṃ`), which then matches `searchExact` and resolves to `kamma`
directly — the same words with the same content as what the main screen
already ranks first.

### Constraint: preserve the two documented latency guards

`_updateAutocomplete` has two invariants recorded in its own comments that
this change must not break:

- **Guard 1** — tier 1 must answer and paint **before the function's first
  `await`**, so a keystroke that tier 1 can already answer stays perfectly
  synchronous (no DB round trip). The exact-fuzzy-key rescue requires a DB
  query and cannot run before tier 1's synchronous check without regressing
  every keystroke's latency.
- **Guard 2** — no DB tier may run while `searchIndexProvider` is still
  loading at startup (checked via `.hasValue`, not a synchronous provider
  value), to avoid hitting the database on every keystroke during the
  in-memory index's one-time build.

Resolution: keep tier 1 exactly as-is, still shown synchronously first if it
has a hit. Run the tier-0 rescue query immediately afterward (still gated by
Guard 2), and if it returns anything, **re-render the overlay** with the
rescue results prepended ahead of whatever tier 1 already showed, deduplicated
by literal string. If tier 1 was empty, the sequence falls through unchanged
into tiers 2/3 exactly as before, except now also gated by an empty tier-0
result. This means tier 1's synchronous paint (Guard 1) is untouched — the
rescue can only *upgrade* the overlay a moment later, never delay its first
appearance in the already-working case.

The tier-0 rescue is naturally cheap and rarely fires while a word is still
being typed: `fuzzy_key` equality (not prefix) only matches when the *entire*
typed string, once folded, equals a complete real word's folded form — which
is uncommon for a half-typed prefix and common only near the end of typing a
(possibly macron-omitted) inflected form. It also hits an indexed column with
an equality predicate, cheaper than the range scans already run for tiers 1/3.

### Scope (addendum)

- `lib/database/dao.dart` — new method, exact `fuzzy_key` equality query
  ranked by the existing `fuzzyCloseness` helper.
- `lib/providers/autocomplete_provider.dart` — new provider wrapping it.
- `lib/screens/search_screen.dart` — `_updateAutocomplete` restructured as
  described above.
- Per AGENTS.md, no UI tests. The new DAO method is data logic and gets a
  DB-backed unit test, following the existing pattern in
  `test/database/fuzzy_ranking_test.dart`. The tier-merge control flow lives
  in a widget's private method and is deliberately left unverified by test —
  covered instead by the plan's manual Android check.

### How we'll know it's done (addendum)

- Typing `kammam` shows `kammaṃ` (or another genuine exact-fuzzy-key match)
  at the top of the dropdown, ahead of `kāmaṃ`.
- Typing `dhammam` shows `dhammaṃ` at the top of the dropdown, ahead of
  `dhamamāna`.
- Tapping either resolves to the same headword the main screen's fuzzy tier
  already ranks first for that query.
- A query with no genuine exact-fuzzy-key match (the common case) shows
  exactly what today's tier 1 shows, with no added latency to its first paint.
- `flutter test` passes in full; `flutter analyze` reports no new issues.

## Addendum 2 — the main screen's Partial tier outranks the fix, too

After Phase 5 shipped, the user tested again: the dropdown now correctly shows
`kammaṃ` for `kammam`, but the **main screen's own top result** is
`kammakāri`, not `kamma` — still not matching the dropdown. Same complaint for
`dhammam` → main screen shows `dhammacchariya` instead of `dhamma`.

**This is a third, distinct bug**, verified directly against the database
with `dao.searchExact` / `dao.searchPartial` / `dao.searchFuzzy` run
side-by-side for `kammam`:

```
exact=0  partial=2  fuzzy=31
partial: kammamakari | kammamakāsi
fuzzy(top10): kamma 1 | kamma 2 | kamma 5 | kamma 6 | kamma 7 | kamma 8 | …
```

`kamma` (the word the fix correctly ranks first *within* the Fuzzy tier) is
never the problem — it's already top of Fuzzy. The problem is that
`SplitResultsList` renders tiers in a fixed order — Exact, then a "Partial
Results" divider, then a "Fuzzy Results" divider — and **Partial renders
above Fuzzy unconditionally**. `dao.searchPartial('kammam')` performs a
literal substring/prefix scan on `lookup_key` (diacritics-sensitive, not
folded) and genuinely finds two real headwords: `kammamakari` and
`kammamakāsi`. These are real dictionary headwords whose sandhi-joined
inflected forms happen to literally start with the ASCII text "kammam" — a
coincidence of Pāḷi orthography (`kammaṃ` + a following word commonly liaises
to "kammam-"), completely unrelated to the user's intent. Because Partial
renders before Fuzzy, this coincidental hit is what the user sees first,
burying the correct `kamma` result one tier further down — exactly the same
*shape* of bug as the one this whole thread started from, just occurring
between tiers instead of within one.

### What it should do

A genuine exact-fuzzy-key match (the same tier-0 signal used throughout this
thread: the entire query, once folded, equals a real lookup key exactly) is
stronger evidence of intent than a merely-coincidental literal partial-prefix
hit. It should be promoted into the **Exact tier** itself — conceptually, a
macron/aspirate/doubling-only difference from a real word *is* an exact match
for practical purposes, just as the dropdown already treats it as the
strongest possible suggestion.

Concretely: `exactResultsProvider` should fall back to the tier-0 fuzzy-exact
lookup **only when the literal exact search finds nothing**. This keeps every
already-working exact search byte-for-byte unchanged (zero risk, zero added
DB cost when a literal hit exists) and only activates the rescue for queries
that would otherwise fall through to the weaker Partial/Fuzzy tiers — exactly
the queries this thread is about.

Once tier-0 matches are promoted into `exact`, the app's existing dedup logic
(`search_screen.dart`'s `exactIds` used to filter `partial`, and
`exactAndPartialIds` used to filter `fuzzy`) needs no changes at all — it
already excludes anything already shown as exact.

### Scope (addendum 2)

- `lib/database/dao.dart` — new method `searchFuzzyExact(String query)`
  returning `List<DpdHeadwordWithRoot>`, mirroring `searchFuzzy`'s resolution
  path (`_extractIds` → `_fetchHeadwords`) but with an **equality** filter on
  `fuzzyKey`, not a prefix range.
- `lib/providers/search_provider.dart` — `exactResultsProvider` calls the new
  method only when `dao.searchExact(query)` returns empty.
- No change to `searchExact`, `searchPartial`, `_fetchHeadwords`, or the tier
  divider layout in `split_results_list.dart`.

### How we'll know it's done (addendum 2)

- Searching `kammam` shows `kamma 1`–`kamma 8` in the (undivided) top section,
  ahead of the "Partial Results" divider and `kammamakari`/`kammamakāsi`.
- Searching `dhammam` shows `dhamma 1.01` etc. ahead of
  `dhammamacchariya`/`dhammamaccharī`/`dhammamadesesi`/`dhammamabhiññāya`.
- A query with a genuine literal exact hit (e.g. `buddha`) is byte-for-byte
  unaffected — no extra DB query runs, since `searchExact` already returns
  non-empty.
- `flutter test` passes in full; `flutter analyze` reports no new issues.
