## Thread
- **ID:** 20260527_home_screen
- **Objective:** Replace blank empty state with a home screen showing a random word and recent searches

## Files Changed
- `lib/database/dao.dart` — added `fetchRandomWord()` with eligibility filter
- `lib/providers/word_of_day_provider.dart` — new `FutureProvider.autoDispose` for random word
- `lib/widgets/home_content.dart` — new HomeContent, _WordOfDaySection, _RecentSearchesSection
- `lib/screens/search_screen.dart` — _showHome flag, _goHome(), _searchFromHome(), logo/title tap, X button logic, _buildBody routing
- `AGENTS.md` — added critical DB empty-string rule

## Spec Deviations (intentional, user-confirmed during development)
- "Word of the Day" with date seed → pure random word, new on every home screen access
- 10 recent searches → 20
- Word card InkWell → TapSearchWrapper handles all taps naturally (no special navigation)

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | nit | `dao.dart:630` | `isNotNull()` redundant alongside `isNotValue('')` | In SQL, `NULL != ''` is UNKNOWN (falsy), so NULLs are already excluded | Leave — belt-and-suspenders is fine here |
| 2 | nit | `home_content.dart:81` | Extra 2-space indent before `wordAsync.when(...)` | Cosmetic only, valid Dart | Leave — no behaviour impact |
| 3 | nit | `home_content.dart:41,137` | `theme` passed as constructor param when `Theme.of(context)` is available in build | Redundant but not wrong | Leave — consistent with existing pattern in the file |

## Fixes Applied
- Empty-string filter added to `fetchRandomWord()` after user reported words without meaning_1 appearing (`isNotNull()` alone misses `''` values — DB has no NULLs, only empty strings)
- DB empty-string rule documented in `AGENTS.md` and memory

## Test Evidence
- `flutter analyze lib/database/dao.dart lib/providers/word_of_day_provider.dart lib/widgets/home_content.dart lib/screens/search_screen.dart` → No issues found

## Verdict
PASSED
- Review date: 2026-05-27
- Reviewer: kamma (inline)
