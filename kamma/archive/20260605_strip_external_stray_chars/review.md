## Thread
- **ID:** 20260605_strip_external_stray_chars
- **Objective:** Strip stray characters from external (shared) searches and show the cleaned word in the search bar.

## Files Changed
- `lib/services/intent_service.dart` — blacklist → Unicode allowlist cleaning; curly-apostrophe normalise; edge trim.
- `test/services/intent_service_test.dart` — added markdown / apostrophe / hyphen / Devanagari cases.
- `lib/screens/search_screen.dart` — post-frame `initState` seed so external cold-start lookups populate the search bar.

## Findings
| # | Severity | Location | What | Why | Fix |
|---|----------|----------|------|-----|-----|
| 1 | (resolved) | search_screen.dart initState | First attempt mutated `searchBarTextProvider` during initState → red screen on cold start | Riverpod forbids provider writes during build | Moved seed into `addPostFrameCallback` |
| 2 | nit | assets/help/changelog.json | Auto-changelog bump (v0.1.10) from a prior commit, unrelated to this thread | Not part of this fix | Exclude from this thread's commit |

## Fixes Applied
- Reworked the initState crash into a guarded post-frame callback (`!mounted`, `_controller.text.isNotEmpty`).

## Test Evidence
- `flutter analyze lib/services/intent_service.dart` → No issues.
- `flutter analyze lib/screens/search_screen.dart` → No issues.
- `flutter test test/services/intent_service_test.dart` → 13/13 pass.
- `flutter test` (full) → 1 failure in `summary_section_test.dart`; confirmed PRE-EXISTING (passes in isolation, also fails in full suite on clean baseline — order-dependent test pollution, unrelated to this thread).
- Device: user confirmed cold-start share now shows the word in the editable bar without crash; warm + in-app tap unaffected.

## Verdict
PASSED
- Review date: 2026-06-05
- Reviewer: kamma (inline)
