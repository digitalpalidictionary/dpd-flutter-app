## Thread
- **ID:** 20260821_niggahita_universal
- **Objective:** The niggahīta setting (ṃ / ṁ) applies to every piece of Pāḷi the app displays, while stored and searched values stay canonical.

## Files Changed
- `lib/utils/text_filters.dart` — `filterNiggahita` takes a bool, plus new `canonicalNiggahita`, `NiggahitaScope` and `context.nigg`
- `lib/app.dart` — installs `NiggahitaScope` above `MaterialApp`
- `lib/database/dao.dart` — `_foldNiggahita` extracted; external dictionary exact/partial search now folds the query
- `lib/screens/search_screen.dart` — suggestions, Velthuis, all seeding paths, recent-chip search, history tooltips; field re-renders on toggle
- `lib/services/intent_service.dart`, `lib/widgets/tap_search_wrapper.dart` — fold scraped/shared text to canonical before it becomes a query or history entry
- `lib/widgets/entry_content.dart` — the two shared key-value row builders convert centrally
- `lib/widgets/secondary/secondary_card.dart`, `family_section_builders.dart` — shared choke points covering many display sites at once
- `lib/screens/entry_screen.dart`, `lib/screens/root_screen.dart`, and 14 widget files — display conversion at the leaf
- `test/utils/text_filters_test.dart` — new tests for both directions and the round trip

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | blocking | `tap_search_wrapper.dart:164` | Tap-to-search scrapes rendered text, so `ṁ` entered the query and persisted history | Setting became irreversible for tapped words; violated the display-only rule | Fold to canonical in `_cleanPali` and `IntentService._clean` |
| 2 | major | `search_screen.dart:476` | No `context.nigg` in `build`, so no dependency registered and the field never refreshed | Toggling the setting left the search bar stale — the widget the thread was opened for | `ref.listen` on the setting in `build`, re-render the field |
| 3 | major | 12 sites | Phase 3 sweep missed no-results, frequency labels, home chips, root family buttons, tooltips | Setting visibly not universal | `context.nigg` at each |
| 4 | minor | `family_section_builders.dart:22` | Span rebuild dropped `recognizer`, `semanticsLabel`, `locale`, `mouseCursor` | A future tappable header span would silently lose its tap | Convert in `_bold`/`_normal` instead |
| 5 | nit | `dao.dart:663`, `root_matrix_table.dart:83` | Leftover alias; over-long line | Tidiness | Inlined; wrapped |

Dismissed with evidence: entity-encoded niggahīta in dictionary HTML (0 of 241,653 rows); URL corruption (0 of 396,837 href values); grammar-table double conversion (idempotent, and `n` is needed directly by two `Text` widgets).

## Fixes Applied
All five findings above were fixed and re-verified. The plan's false claim that `frequency_table.dart` contained no niggahīta was corrected in place rather than quietly dropped.

## Test Evidence
- `flutter analyze` (scope: whole project) → 51 infos, 0 errors — identical to the pre-thread baseline, so nothing new was introduced
- `flutter test` (scope: whole suite, 364 tests) → pass; 359 at baseline, 5 added for the conversion helpers
- Line-ending audit across all changed files (scope: every file in `git diff`) → unchanged; `entry_screen.dart` and `intent_service.dart` remain CRLF
- Entity/URL safety of the dictionary HTML replace (scope: all 241,653 `dict_entries` rows of the real mobile database) → no entity encoding, no niggahīta in any href
- User confirmed on device: all eight manual steps for Phases 1–3, plus external dictionaries after Phase 4

## Not Verified
- The Phase 5 fixes have not been exercised on device — in particular tap-to-search, the recent-search chips, the history tooltips, and toggling the setting while text sits in the search bar. These are code-verified only.
- Per project rule no UI tests exist, so every display-site conversion is verified by reading and by the user's manual pass, not automatically.
- `dart format` was deliberately not run; formatting matches surrounding code by hand.

## Verdict
PASSED
- Review date: 2026-08-21
- Reviewer: independent subagent (zero-context) + CodeRabbit CLI, findings verified and fixed inline
