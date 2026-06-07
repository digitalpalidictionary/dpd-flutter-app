# Strip `*` from irregular inflection stems (and search input)

## Problem

Fully-irregular conjugation/declension forms render with a literal `*`
prefix in the inflection table — e.g. the `pivi aor` table shows `*pivi`,
`*apaṃsu` instead of `pivi`, `apaṃsu`.

## Root cause

`apaṃsu` is a real headword: `pos=aor`, `stem='!*'`, `pattern='pivi aor'`.
The DB uses two irregular stem markers, often combined:

- `*`  — fully irregular (endings ARE the full forms, no stem)
- `!*` — same, with the `!` "already-inflected" marker prefixed

In `lib/models/inflection_table_builder.dart`:

- `isIrregular = stem == '*'` is **false** for `'!*'`.
- `cleanStem = stem.replaceAll(RegExp(r'^[!]'), '')` strips only the leading
  `!`, leaving `'*'`.
- `word = '$cleanStem$e'` → `'*' + ending` → `*pivi`, `*apaṃsu`, …

## Reference (Python source of truth)

`../dpd-db/db/inflections/generate_inflection_tables.py:173`:

```python
stem = re.sub(r"\!|\*", "", i.stem)
```

Python strips **all** `!` and `*` anywhere in the stem, so both `*` and `!*`
collapse to an empty stem and the endings render as full forms. The Dart code
must match this.

## Fix

1. `inflection_table_builder.dart` — in both `extractWordForms` and
   `buildInflectionTable`:
   - Recognise any all-marker stem as irregular: `RegExp(r'^[!*]+$')`.
   - Strip both markers anywhere: `stem.replaceAll(RegExp(r'[!*]'), '')`.

2. Search-input parity (defensive, per AGENTS.md "Two Search Paths"):
   - `intent_service._clean()` already strips `*` (allowlist) — verified by
     existing test `*dhamma*` → `dhamma`.
   - Add `*` stripping to `tap_search_wrapper._cleanPali()` so both paths
     behave identically if a stray `*` is ever selected/shared.

## Out of scope

The "(irregular)" heading label is driven separately; making `!*` consistent
with `*` for the heading falls out of the `isIrregular` change and is not a
behaviour regression.
