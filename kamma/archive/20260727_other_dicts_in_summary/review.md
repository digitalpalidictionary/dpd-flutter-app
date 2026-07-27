## Thread
- **ID:** 20260727_other_dicts_in_summary
- **Objective:** Add one summary row per external dictionary with an exact match, ordered by the user's dictionary Settings order, tappable to jump to that dictionary's card.

## Files Changed
- `lib/models/summary_entry.dart` — new `SummaryEntryType.dict`
- `lib/providers/dict_provider.dart` — `dictShortName()` one-word abbreviation map + fallback
- `lib/providers/settings_provider.dart` — `showOtherDictsInSummary` setting, default on
- `lib/providers/summary_provider.dart` — `buildSummaryEntries` rewritten as a single loop over Settings order (was three hardcoded loops); added dictionary-row support
- `lib/widgets/settings_panel.dart` — new toggle tile + help topic below "Construction in summary"
- `lib/widgets/split_results_list.dart` — exact-tier external dictionary card now registers a scroll target (`dict_$sourceId`) via `addTier1`
- `test/providers/dict_provider_test.dart` — `dictShortName` coverage
- `test/providers/summary_provider_test.dart` — 5 new cases for dictionary rows, ordering, and backward compat

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | minor | `summary_provider.dart:62-66` (pre-fix) | `secondaryBySource` stored one `Object` per source id (map overwrite), silently narrowing the old code's "append every matching result" behavior to "last one wins" | Not currently reachable — `SecondaryResultsProvider.parse` guarantees at most one result per source id per query — but the old behavior was append-all, and the new code depended on an external invariant instead of the type system | **Fixed** — `secondaryBySource` now maps to `List<Object>`, dispatch loop emits every result per source in order |

No other findings. Two independent passes ran in parallel: a fresh Sonnet subagent (zero prior context, read spec/plan/AGENTS.md, diffed all files, ran `flutter analyze`/`flutter test` itself) and CodeRabbit (`--base main --type uncommitted --dir lib`). The subagent explicitly checked the `secondaryBySource`/`dictBySource` "last one wins" question, the `dict_$id` scroll-target string match between builder and results list, `dictShortName` edge cases (empty string), Settings plumbing completeness, and the conditional `dictResultsProvider` watch for stale-state risk — no issues on any of those. CodeRabbit's one finding (above) was the only disagreement between the two passes; verified independently against `SecondaryResultsProvider.parse` before fixing.

## Fixes Applied
- `summary_provider.dart`: `secondaryBySource` changed from `Map<String, Object>` to `Map<String, List<Object>>`; dispatch loop now iterates and emits every result for a source id instead of only the last one assigned.

## Test Evidence
- `flutter analyze` (touched files) → 0 issues
- `flutter analyze` (full repo) → 0 issues in touched files; 51 pre-existing infos elsewhere, unrelated
- `flutter test test/providers/summary_provider_test.dart test/widgets/summary_section_test.dart` → pass, post-fix
- `flutter test` (full suite) → 346/346 pass, post-fix
- Manual on-device verification (Pixel 8 Pro, user-confirmed): all spec scenarios pass, including reordering, disabling a dictionary, toggling the new setting, and no-external-hit words. Jump-to-Cone on `dhamma`/`citta` has a perceptible but user-judged-manageable delay — matches the spec's measured ~45ms worst case, not a regression.

## Verdict
PASSED
- Review date: 2026-07-27
- Reviewer: Sonnet subagent (independent, zero prior context) + CodeRabbit CLI, synthesized by session agent
