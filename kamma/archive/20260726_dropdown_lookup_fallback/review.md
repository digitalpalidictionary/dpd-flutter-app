## Thread
- **ID:** 20260726_dropdown_lookup_fallback
- **Objective:** the autocomplete dropdown only knew ~93k headwords/roots/families while search covered 1.28M lookup keys and six dictionaries; add two fallback tiers (dictionaries, then the lookup table) so the dropdown stops going blank for real, findable words.

## Files Changed
- `lib/database/dao.dart` — `searchLookupKeysPrefix()`, `searchDictWordsPrefix()`
- `lib/providers/autocomplete_provider.dart` — `dictSuggestionsProvider`, `lookupSuggestionsProvider`, shared sort comparator
- `lib/screens/search_screen.dart` — `_updateAutocomplete()` tiered and async; `_suggestionsVisible` gates the no-results verdict; `_autocompleteGeneration` guards against stale async results
- `test/database/dao_prefix_suggestions_test.dart` (new) — 14 tests

## Findings

Independent subagent review (zero prior context) plus two CodeRabbit passes plus manual verification. All findings below were fixed during this review; none remain open.

| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | major | `dao.dart` `searchLookupKeysPrefix` | Sutta codes are stored uppercase (`DN1.1`, 18,301 such keys); the method only range-scanned the lowercased query, so typing `dn1.1` never found `DN1.1` | Confirmed against the real DB: the lowercase range genuinely returns 0 rows for a real uppercase key | Added the same digit-triggered uppercase-range widening already used by `searchExact`/`searchPartial`/`searchClosestMatches`; added 2 regression tests |
| 2 | minor | `autocomplete_provider.dart` `dictSuggestionsProvider` | Awaited `dictMetaAllProvider.future` even when `visibility.enabled` was already empty, so no dictionary could ever match | Wasted await when every dictionary is disabled | Short-circuit on `visibility.enabled.isEmpty` before the await |
| 3 | minor | `dao.dart` both new methods | Guarded on `normalized.isEmpty`, not `normalized.length < 2`; a 2-char raw query that normalizes down to 1 char (e.g. stripped punctuation) could slip past the intended minimum and run an overly broad prefix scan | Inconsistent with the 2-char minimum the callers intend | Changed the guard to `normalized.length < 2` in both methods |
| 4 | major | `search_screen.dart` `_updateAutocomplete` | Making the function async introduced a real regression: cancelling `_autocompleteDebounce` only stops a timer that hasn't fired, not an already-running `await`. `_onSearch` doesn't change `_controller.text`, so a stale in-flight call could resolve after the user hit Enter, find the text unchanged, and reopen the dropdown — also flipping `_suggestionsVisible` back on, defeating the Task 8 fix | Confirmed by tracing the call graph: this exact window didn't exist before this thread, since `_updateAutocomplete` used to be fully synchronous | Added `_autocompleteGeneration`, bumped at every action that should invalidate in-flight autocomplete work (every keystroke, search, clear, go-home, home-search, suggestion-tap); `_updateAutocomplete` captures it once before its first await and abandons its result on mismatch, replacing the weaker text-comparison check |

## Fixes Applied
All four findings above were fixed in this review pass, verified individually with `flutter analyze` + `flutter test`, and re-checked with a second CodeRabbit pass (which returned only finding #4, subsequently fixed and traced by hand since CodeRabbit hit its free-tier rate limit before a third pass could confirm).

## Test Evidence
- `flutter analyze` (full project): 0 new issues; 94 pre-existing info-level issues in vendored `lib/utils/pali_transliterator/`, unrelated to this thread
- `flutter test` (full suite): 318 tests, all passing (316 pre-existing + 2 new sutta-code regression tests)
- `coderabbit review --agent --base main --type uncommitted --dir lib`: run twice — pass 1 found findings #1–3 (fixed), pass 2 found finding #4 (fixed); pass 3 hit the free-tier rate limit (43 min wait) before it could run — finding #4's fix was instead verified by manual trace of all 6 `_autocompleteGeneration` call sites plus `flutter analyze`/`flutter test`
- Independent subagent review (separate context, no memory of implementation): confirmed core design (no fuzzy matching, correct tier order, `_suggestionsVisible` correctly gated including `dispose()`), all 12 original tests pass, no dead code, architecture matches sibling DAO/provider patterns, plan-vs-code fidelity confirmed, testing-rule compliance confirmed (no UI test for `_suggestionsVisible`, per `AGENTS.md`)
- Manual Android verification: confirmed by the user across all 8 verification scenarios in `plan.md`, including the tier-reorder and the no-results-verdict gate

## Verdict
PASSED
- Review date: 2026-07-26
- Reviewer: Claude (independent subagent for initial pass; primary session applied and verified fixes)
