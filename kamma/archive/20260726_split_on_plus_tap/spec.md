# Spec: Split On Plus When Tapping A Compound

## Problem
Some dictionary text shows a compound joined by a plus sign with no spaces, e.g.
`Abhimaṅgala+sammata`. Tapping either half searches the whole string
`Abhimaṅgala+sammata`, which matches nothing, so the user gets no results.

## Root Cause
`_isWordBoundary()` in `lib/widgets/tap_search_wrapper.dart:150` treats only
whitespace (` `, `\n`, `\t`, `\r`) as a word boundary. `_extractWordAt()` therefore
expands the tap outward across the `+` and returns both halves as one word.

The spaced form (`udaka + phāsukaṭṭhāna`) already works, because the spaces are
boundaries.

## Fix
Add `+` to `_isWordBoundary()`. One character, one line.

Tapping `Abhimaṅgala` returns `Abhimaṅgala`; tapping `sammata` returns `sammata`.
Landing exactly on the `+` returns the half to its left, because `start` walks left
over non-boundaries while `end` stops immediately. That is the same behaviour a tap
on a space already has today, and it beats returning nothing, so it is kept as is.

## Why Nothing Else Changes
- **Double-tap mode** already works: it uses Flutter's `SelectionArea` word
  selection, whose Unicode word-break rules already treat `+` as a break.
- **`_cleanPali()`** is not touched. It cannot help here — it runs after extraction
  and has no idea which half was tapped.
- **`_normalizeQuery()` / share intent** are not touched. This is a tap-position
  problem, not a query-cleaning problem, so the "two search paths" rule in
  `AGENTS.md` does not apply — `IntentService._clean()` receives text the user
  highlighted by hand, where the highlight already picks the intended half.
- **Hyphens** need no equivalent change: `_normalizeQuery()` already strips `-`, so
  `abhi-maṅgala` resolves to `abhimaṅgala` correctly today.

## Test Coverage
Promote `_extractWordAt` to a top-level `@visibleForTesting` function in the same
file (same precedent as `IntentService.clean()` in the bracket-stripping thread) and
add `test/widgets/tap_search_wrapper_test.dart` covering:
- Tap left of `+` in `Abhimaṅgala+sammata` → `Abhimaṅgala`
- Tap right of `+` → `sammata`
- Tap exactly on the `+` → the left half (matches existing space behaviour)
- Spaced form `udaka + phāsukaṭṭhāna` still returns each word
- Plain single word unaffected
- Multiple pluses (`a+b+c`)

This is data logic on a pure string function, not a UI test, so it is within the
`AGENTS.md` testing rule.

## Files Changed
- `lib/widgets/tap_search_wrapper.dart`
- `test/widgets/tap_search_wrapper_test.dart` (new)
