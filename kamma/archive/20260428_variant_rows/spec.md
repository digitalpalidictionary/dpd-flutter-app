## Overview
Sync the grammar table's variant display logic with the GoldenDict Jinja template (`exporter/goldendict/templates/dpd_headword.jinja`), which was updated to support two new fields: `var_phonetic` (phonetic variant) and `var_text` (textual variant).

## What it should do
- Show **"Variant"** row only when `variant` is set AND both `varPhonetic` and `varText` are null
- Show **"Phonetic Variant"** row when `varPhonetic` is set
- Show **"Textual Variant"** row when `varText` is set
- `var_phonetic` and `var_text` can coexist in the same entry

## Assumptions & uncertainties
- `varPhonetic` and `varText` columns already exist in `tables.dart` and `dao.dart` getters — confirmed
- `buildKvTextRow` handles nullable strings safely — confirmed by existing usage

## Constraints
- Touch only `lib/widgets/grammar_table.dart`
- Follow existing `buildKvTextRow` pattern

## How we'll know it's done
- `flutter analyze lib/widgets/grammar_table.dart` reports no issues
- Logic mirrors Jinja template exactly

## What's not included
- No changes to DB schema, DAO, or any other file
