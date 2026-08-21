# Review — Rank fuzzy search results by closeness

**Verdict: PASSED**

## Methods performed

**Spec review** — an independent agent (fresh context, no memory of the implementation) read `spec.md` (including both addenda) end to end and confirmed the code matches every documented behavior: the `tier*1000+delta` scoring formula, the tier-0/tier-1 split, the dropdown's Guard 1/Guard 2 preservation, and the "only fires when literal exact is empty" rule for `exactResultsProvider`.

**Plan review** — no undocumented deviations. The one deviation from the original plan text — extracting `_rankedHeadwordsByCloseness` as a shared helper mid-Phase-6 after discovering `searchFuzzyExact` mis-sorted alphabetically — is recorded in `plan.md` at the point it happened, with the bug it fixed. `_fetchHeadwords` was confirmed untouched and still load-bearing for `searchExact`/`searchPartial`.

**Diff review** — matches the plan's architecture decisions (single `int` score, no premature abstraction, ranking applied only inside `searchFuzzy`/`searchFuzzyExact`, never in `_fetchHeadwords`). No N+1 queries; every new method is a single bounded query. The `search_screen.dart` dropdown restructuring was checked step-by-step against spec's 7-step resolution and both guards hold.

**Test review** — the independent reviewer ran the full suite itself: 381/381 pass, `flutter analyze` shows only the same 51 pre-existing infos. DB-backed tests are skip-guarded for a checkout without the sibling `../dpd-db` repo. Assertions verify actual ordering (`lessThan`, index comparisons), not just non-emptiness.

**Regression/edge-case review** — confirmed no path lets the `exactResultsProvider` rescue override a genuine literal exact hit (`buddha` case: `literalExact=2`, no rescue call). Confirmed no dead code was introduced or orphaned.

## CodeRabbit

Ran in the foreground (`coderabbit review --agent --base main --type uncommitted`), completed on the first attempt. One finding:

- **Minor** — `searchFuzzyExactKeyMatches` applied the SQL `limit` *before* sorting by `fuzzyCloseness`. Since it's an equality match, all matching rows are already tier 0; if a key were ever ambiguous enough to have more than `limit` (20) real words sharing it, the limit could silently drop the actual closest candidates before the ranking sort ever saw them.

**Fixed**: removed the SQL-level `limit`, sort the full result set by closeness first, then `take(limit)`. Re-verified: `flutter analyze` clean, all `fuzzy_exact_key_matches_test.dart` and `fuzzy_ranking_test.dart` cases pass, full suite still 381/381.

## Non-blocking notes (not fixed, judged not worth the complexity)

- `searchFuzzyExactKeyMatches` still has its own inline closeness-comparator, structurally parallel to `_rankedHeadwordsByCloseness` but not literally shared (different return shape — raw `lookupKey` strings vs. resolved headwords). Both currently agree; a future change to the tie-break rule would need to touch both. Not worth a shared abstraction for two call sites.
- `_rankedHeadwordsByCloseness` calls `_fetchHeadwords` (which does its own alphabetical sort internally) and then immediately re-sorts by score. Redundant but harmless at the row counts involved (≤50).

## Manual testing

User confirmed on an Android device, after each phase:
- Main-screen Fuzzy tier: `rupaṁ`/`kammam`/`dhammam` all correctly rank the intended word first.
- Dropdown: `kammam`/`dhammam` correctly suggest `kammaṃ`/`dhammaṃ` at the top, instant paint preserved for ordinary typing.
- Main-screen Exact tier promotion: `kammam`/`dhammam` now show `kamma`/`dhamma` first (not `kammakāri`/`dhammacchariya`), and `buddha` is unaffected.

## Outcome

No blocking issues remain. Ready to finalize.
