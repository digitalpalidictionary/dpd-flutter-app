# Plan: Split On Plus When Tapping A Compound

## Status: COMPLETE

## Task 1: Make `+` a word boundary in tap-to-search — DONE
- Added `char == '+'` to `_isWordBoundary()`
- Lifted `_extractWordAt` / `_isWordBoundary` out of `_TapSearchWrapperState` to
  top-level functions in the same file; `extractWordAt` marked `@visibleForTesting`
  (same precedent as `IntentService.clean()`)
- Call site in `_getWordAtPosition()` updated to `extractWordAt(...)`
- File: `lib/widgets/tap_search_wrapper.dart`
- Verified: `flutter analyze` reports nothing for this file

## Task 2: Regression test — DONE
- Created `test/widgets/tap_search_wrapper_test.dart`, 8 tests, all passing
- Covers both halves of `Abhimaṅgala+sammata`, a tap on the `+`, the spaced
  `udaka + phāsukaṭṭhāna` form, `a+b+c`, plain words, and out-of-range offsets

### Deviation from spec (corrected in spec.md)
The spec first claimed a tap landing exactly on the `+` would return `''`. The test
proved otherwise: `start` walks left over non-boundaries while `end` stops at once,
so it returns the left half (`Abhimaṅgala`). That matches how a tap on a space
already behaves and is better than returning nothing, so the code was left alone and
`spec.md` was corrected.

## Task 3: Smoke gate — DONE
- `flutter analyze`: 0 errors (94 pre-existing infos, all in the vendored
  `pali_transliterator/` and unrelated files)
- `flutter test`: full suite, all tests passed
- Real Android tap check confirmed by the user on 2026-07-26
- `coderabbit review --agent`: 0 findings

## Commit Message
```
fix: tapping half of a plus-joined compound now searches just that half

Text like "Abhimaṅgala+sammata" was searched whole and found nothing.
The single-tap word extractor treated only whitespace as a word
boundary, so it swallowed the plus and returned both halves. Added "+"
as a boundary, lifted the extractor to a testable top-level function,
and covered it with tests.
```
