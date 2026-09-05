## Thread
- **ID:** 20260905_popup_full_results
- **Objective:** Show the full search result stack in the word popup, minus the summary.

## Files Changed
- `lib/widgets/search_results_body.dart` — new; the result-assembly logic extracted from the search screen, now shared by the screen and the popup
- `lib/screens/search_screen.dart` — delegates the body to the shared widget, keeping only the empty-query branch and timing instrumentation
- `lib/widgets/word_popup.dart` — renders the shared body with the summary suppressed, replacing its exact-matches-only list

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | minor | `search_screen.dart:503` | Moving the result watches into the child meant the info view unmounted them; `autoDispose` then discarded the results, so closing an info page showed a spinner instead of the previous results | Contradicted the "no behaviour change to the screen" claim, on a path the device test did not cover | Hold both subscriptions at screen level with a commented `ref.watch`, so they outlive the body |
| 2 | minor | `word_popup.dart:103` | Sheet title rendered the word raw while the new shared no-results state renders it through the niggahīta filter — the two lines disagreed on `ṃ` vs `ṁ` | Cosmetic inconsistency introduced by this change; both were raw before | Apply `context.nigg()` at the title `Text`, display-only, per the AGENTS.md rule |
| 3 | minor | `search_results_body.dart:25` | `showSummary` meant different things per caller: the screen passed the raw setting, the callee silently ANDed in the compact-mode rule | `SearchResultsBody(showSummary: true)` would not obviously be overridden by compact mode | Renamed to `allowSummary` (default true); the widget now reads the user's setting itself and combines all three conditions in one place |
| 4 | nit | `search_screen.dart:904` | `settingsProvider` watched twice for one boolean | Redundant whole-screen rebuild on any settings change | Removed; subsumed by finding 3 |
| 5 | nit | `search_results_body.dart:9` | Import grouping out of order | Cosmetic | Reordered |

No blocking findings. No major findings.

## Fixes Applied
All five findings fixed. Re-verified after the fixes: analyze and the full test suite both
match the baseline.

## Test Evidence
- `flutter analyze` (scope: whole project, `lib/`) → 0 errors, 51 infos — byte-identical to
  the pre-thread baseline, all in `lib/utils/pali_transliterator/*` and other untouched files
- `flutter test` (scope: whole suite, 384 tests) → all passed, matching the baseline count
- CodeRabbit `--agent --include-untracked` (scope: all six changed files, new file included)
  → 0 findings
- Independent-agent review (fresh context, zero-memory prompt) → the 5 findings above,
  reached by mechanically diffing the pre-change `_buildBody` against the extracted widget
- Manual on-device test, Android (scope: popup mode, several tapped words) → all sections
  present, summary absent, **no tangible lag** from the extra queries per tap

## Not Verified
- The five review fixes landed *after* the device test. They are small — a niggahīta filter
  on the sheet title, two subscription-holding watches, and a parameter rename — but the
  build the user exercised did not contain them. Worth one more tap-through before release.
- No runtime verification of the info-view regression in finding 1 or its fix; both were
  established by reading `autoDispose` semantics, not by exercising the path.
- No UI tests exist or were added — the project forbids them for this app.
- Partial and fuzzy tiers in the popup, the no-results state, and compact display mode were
  reasoned through in code but not individually confirmed on device.

## Pre-existing issue found, not fixed here
`InflectionTable` (`lib/widgets/inflection_table.dart:37`) nests its own `TapSearchWrapper`
with no `onWordTap`, so a tap on an inflected form inside the sheet falls through to the
default path and opens a **second** bottom sheet — which the popup's own doc comment says
must not happen. This predates the thread (inflection sections already rendered in the old
popup) and is out of scope, but the popup now surrounds it with far more content, so it will
be hit more often. Logged as a follow-up.

## Verdict
PASSED
- Review date: 2026-09-05
- Reviewer: independent agent review (fresh context) + CodeRabbit; fixes applied and
  re-verified by the implementing session
