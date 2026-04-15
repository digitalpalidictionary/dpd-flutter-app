## Phase 1: Case-insensitive lookup queries

- [x] `dao.dart:searchExact` — use `.collate(Collate.noCase)` on lookupKey comparison
  → verify: search "mn12" returns MN12 headwords

- [x] `dao.dart:searchPartial` — use noCase on lookupKey range comparisons
  → verify: search "mn1" returns partial matches including MN1xx codes

- [x] `dao.dart:searchClosestMatches` — use noCase on both lookup_key strategies
  → verify: closest matches for "mn1" includes sutta codes

- [x] `dao.dart:searchRoots`, `getLookupRow`, `checkWordsInLookup` — noCase consistency
  → verify: all lookupKey queries case-insensitive
  → note: getLookupRow uses exact-first then noCase fallback to avoid
    getSingleOrNull crash on 180 case-duplicate pairs (e.g. "AN"/"an")

- [x] Verify Pali word searches still work
  → verify: `flutter analyze` clean, `flutter test` all pass
