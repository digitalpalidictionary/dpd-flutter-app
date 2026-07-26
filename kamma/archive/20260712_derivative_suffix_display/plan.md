# Plan: Derivative (suffix) grammar row displays correctly

Tracking: DPD Android app beta issue #227 (do not comment/close until user says so).

## Architecture Decisions
1. **Restore the column at the source.** Add `derivative` to the mobile exporter's
   `HEADWORD_COLUMNS` instead of reconstructing it app-side — the data exists in the
   full DB and this is the same pattern every other kept column follows.
2. **Bump the schema version in lockstep.** Adding a column changes the schema, so
   `DB_SCHEMA_VERSION` and `requiredDbSchemaVersion`/`schemaVersion` go `6 → 7` together;
   the app then fetches a fresh DB rather than reading a v6 file missing the column.
3. **Match the webapp render exactly.** Gate the row on `derivative` (not `suffix`) and
   render `$derivative ($suffix)`, with the suffix parenthetical omitted when empty.
4. **Regenerate, never hand-edit.** `database.g.dart` comes from `build_runner`.

## Phases

### Phase 1 — dpd-db mobile export
- [x] Add `"derivative"` to `HEADWORD_COLUMNS` in `../dpd-db/exporter/mobile/mobile_exporter.py`
      (next to `construction`/`suffix`) and remove `derivative` from the `Dropped:` comment (line 27).
  → verify: DONE — `"derivative"` at line 53; `Dropped:` comment (line 27) no longer lists it.
- [x] Bump `DB_SCHEMA_VERSION` `6 → 7` in `mobile_exporter.py`.
  → verify: DONE — line 130 reads `DB_SCHEMA_VERSION: int = 7`.
- [~] Rebuild the mobile DB export (user runs the exporter under `uv run`).
  → verify: exported DB's `dpd_headwords` table has a `derivative` column with non-empty values.
     AWAITING USER — the exporter is run by the user; app-side Phase 2 bumps to match v7.

### Phase 2 — Flutter schema
- [x] Add `TextColumn get derivative => text().nullable()();` to `lib/database/tables.dart`
      (beside `suffix`, line 45).
  → verify: DONE — column present in `tables.dart`.
- [x] Bump `requiredDbSchemaVersion` and `schemaVersion` `6 → 7` in `lib/database/database.dart`.
  → verify: DONE — both read 7.
- [x] Regenerate Drift code: `dart run build_runner build --delete-conflicting-outputs`.
  → verify: DONE — 287 outputs written; `derivative` present in `database.g.dart` (48 refs); analyze clean.
- [x] Add `String? get derivative => headword.derivative;` to `DpdHeadwordWithRoot` in
      `lib/database/dao.dart` (beside `suffix`, line 808).
  → verify: DONE — analyze clean.

### Phase 3 — Render the row
- [x] Rewrite `_buildDerivativeRow` (`lib/widgets/grammar_table.dart:186-193`): gate on
      `derivative` non-empty; build value as `derivative` + (` ($suffix)` only when suffix
      non-empty); keep `filter: n`.
  → verify: DONE — analyze clean; renders `$derivative ($suffix)`, `$derivative` alone when suffix empty.

### Phase 4 — Verification
- [x] `flutter analyze` + full `flutter test`.
  → verify: DONE (2026-07-12) — analyze clean on changed files; 297 tests passed.
- [ ] Manual on Android (user): install the fresh v7 DB; a word with a derivative shows
      `Derivative  kita (ṇvu)` matching the webapp; a word without one shows no row.
  → verify: user confirmation.

## Cross-repo note
Phase 1 lands in `../dpd-db/`; Phases 2–3 land in this app repo. Both must ship together
because the schema version bump makes them interdependent — an app on v7 will reject a v6
DB and vice-versa.
