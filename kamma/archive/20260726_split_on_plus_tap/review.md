# Review: Split On Plus When Tapping A Compound

## Outcome: PASSED — ready to finalize

Manual Android verification confirmed by the user on 2026-07-26: tapping either half
of a plus-joined compound searches only that half.

## What Was Checked

**Correctness.** `extractWordAt` is a pure function over `(text, offset)`. Adding
`'+'` to `_isWordBoundary` is the whole behavioural change; both the left-walk and
the right-walk consult the same predicate, so the two halves split symmetrically.

**The move to top level is behaviour-preserving.** `_extractWordAt` and
`_isWordBoundary` never touched `_TapSearchWrapperState` — no `ref`, no `context`,
no fields. Lifting them out of the class changes nothing at runtime. The sole call
site, `_getWordAtPosition()`, was updated.

**`@visibleForTesting` is correctly applied.** The annotation warns only on use from
a *different* library outside `test/`. `_getWordAtPosition()` lives in the same file,
so there is no violation — confirmed by a clean `flutter analyze` on this file.

**Double-tap mode deliberately untouched.** It reads `SelectedContent.plainText`
from `SelectionArea`, whose Unicode word-break rules already treat `+` as a break.
Nothing to fix, so nothing was changed.

**No sibling duplication of this logic.** `extractWordAt` is the only word-extraction
routine in the Dart codebase. The Android floating bubble captures text the user
highlighted in another app and routes it through the intent funnel; it does not do
its own word-boundary expansion, so it is unaffected.

**`AGENTS.md` two-search-paths rule considered and found not to apply.** That rule
governs the two *text-cleaning* paths (`_cleanPali` and `IntentService._clean`).
This change is to tap-position word extraction, which has no counterpart on the
intent side — shared text is highlighted by hand, so the user has already chosen the
span. Neither cleaning function was modified.

## Follow-Up Noted, Not Fixed
`IntentService._clean()` strips `+` outright via `_disallowedPattern`, so sharing the
whole string `Abhimaṅgala+sammata` from another app yields `Abhimaṅgala sammata`,
which matches nothing. That is a pre-existing gap, out of scope for this thread, and
worth its own thread if it ever bites in practice.

## Unrelated Dirty File
`assets/help/changelog.json` is modified in the working tree, but that is the
build-time asset catching up with commit `ff461c0`, not part of this thread. It must
not be swept into this commit.

## Verification
- `coderabbit review --agent`: 0 findings (scope was `lib/widgets/tap_search_wrapper.dart`
  and the unrelated `assets/help/changelog.json`; the new test file is untracked and so
  was outside its diff)
- `flutter analyze`: 0 errors; nothing reported for the changed file
- `flutter test`: full suite green
- `flutter test test/widgets/tap_search_wrapper_test.dart`: 8/8
- Real Android device: confirmed by the user
