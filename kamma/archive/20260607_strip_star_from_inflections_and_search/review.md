# Review — strip `*` from irregular inflection stems

## Outcome: COMPLETE

## Summary

Fixed literal `*` appearing in inflection tables for fully-irregular stems
(`!*`), e.g. the `pivi aor` table showed `*pivi`, `*apaṃsu`. Root cause was the
Dart irregular check (`stem == '*'`) missing the `!*` variant and the stem-clean
regex only stripping a leading `!`.

## Changes

- `lib/models/inflection_table_builder.dart` — `extractWordForms` &
  `buildInflectionTable`: irregular check `RegExp(r'^[!*]+$')`, stem clean
  `stem.replaceAll(RegExp(r'[!*]'), '')`. Matches Python source
  (`generate_inflection_tables.py:173`).
- `lib/widgets/tap_search_wrapper.dart` — `_cleanPali()` strips `*` for parity
  with `intent_service._clean()` (AGENTS.md "Two Search Paths").
- Tests: `!*` cases in `inflection_table_builder_test.dart`; `*pivi` → `pivi`
  in `intent_service_test.dart`.

## Verification

- User confirmed the fix works on-device.
- New tests pass; all `intent_service` tests pass.
- `coderabbit review --agent`: 0 findings.

## Known pre-existing issue (out of scope)

`buildInflectionTable all forms are occurring by default when no lookupKeys
provided` fails on clean `main` (verified via `git stash`). The code sets
`isOccurring = lookupKeys != null && ...`, so it is `false` when `lookupKeys`
is null, contradicting the test. Left for a separate thread.
