# Plan: Add "other abbreviations" lookup rendering to the Flutter app

## Phase 1: Add data-model and source plumbing for the new lookup column
- [x] Update the lookup-table schema in `lib/database/tables.dart`
  - [x] Add the new nullable `abbrevOther` Drift column mapped from DB column `abbrev_other` on the `Lookup` table
  - [x] Confirm the change is limited to the lookup table and does not alter existing columns
- [x] Update database schema/version metadata as needed in `lib/database/database.dart`
  - [x] Bump the required schema version only if this app uses schema-version gating for lookup-table shape changes
  - [x] Keep the migration behavior unchanged apart from the version number if a bump is required
- [x] Regenerate Drift database code
  - [x] Regenerate `lib/database/database.g.dart` so `LookupData` exposes the new `abbrevOther` field
  - [x] Verify generated code includes the new column mapping and no unrelated manual edits are needed
- [x] Add a dedicated secondary-result model in `lib/models/lookup_results.dart`
  - [x] Create a minimal parsed model for `abbrev_other`
  - [x] Match the webapp payload shape from `../dpd-db/exporter/webapp/data_classes.py`, where rows come from `result.abbrev_other_unpack`
  - [x] Keep parsing defensive so malformed or empty JSON returns `null` rather than breaking existing flows
- [x] Wire the new result into secondary parsing in `lib/providers/secondary_results_provider.dart`
  - [x] Parse `row.abbrevOther`
  - [x] Insert the result into the existing secondary ordering in the smallest sensible place, keeping all existing result ordering stable
- [x] Add source metadata in `lib/providers/dict_provider.dart`
  - [x] Add one new built-in source id and label for `other abbreviations`
  - [x] Preserve existing saved visibility/order behavior as much as current initialization logic allows
- [x] Automatic verification for Phase 1
  - [x] Run static verification for the touched data/plumbing files and confirm generated code is in sync

## Phase 2: Add summary and rendering parity for "other abbreviations"
- [x] Extend summary typing in `lib/models/summary_entry.dart` if needed
  - [x] Add the minimal new summary entry type required for `other abbreviations`
- [x] Add summary generation in `lib/providers/summary_provider.dart`
  - [x] Add source-id mapping for the new secondary result type
  - [x] Create a summary entry whose wording matches the webapp summary intent: `<headword> other abbreviations.`
  - [x] Use a dedicated target id so tapping the summary scrolls to the rendered section
- [x] Add search-screen source routing in `lib/screens/search_screen.dart`
  - [x] Update `_secondaryForSource()` to find the new result type
  - [x] Update the source switch so the new source renders with the other secondary sections
  - [x] Add a stable target id in `_secondaryTargetId()`
  - [x] Add compact-mode and full-mode widget dispatch in `_buildSecondaryItem()`
- [x] Implement the detailed card in `lib/widgets/secondary/secondary_result_cards.dart`
  - [x] Add a minimal card/widget for `other abbreviations`
  - [x] Mirror the webapp output from `abbreviations_other.html`: heading plus a two-column table of source and meaning/notes
  - [x] Reuse existing card/table styling patterns instead of introducing a new design system
  - [x] Preserve current `AbbreviationCard` behavior unchanged
- [x] Automatic verification for Phase 2
  - [x] Run static verification for the touched UI/provider/model files
  - [x] Read the changed rendering code to confirm the UI path is limited to the new result type

## Phase 3: End-to-end verification and thread bookkeeping
- [x] Normalize dotted and undotted `abbrev_other` keys in `../dpd-db/db/lookup/help_abbrev_add_to_lookup.py`
  - [x] Remove one trailing `.` before grouping `abbrev_other` rows
  - [x] Merge dotted and undotted forms into a single lookup entry for `abbrev_other`
  - [x] Sort imported `abbreviations_other.tsv` rows by abbreviation before grouping so packed row order is stable
- [x] Re-read the final implementation against `../dpd-db/exporter/webapp/templates/abbreviations_other_summary.html` and `abbreviations_other.html`
  - [x] Confirm summary wording, section targeting, and table structure match the webapp intent
- [x] Re-read `spec.md` and ensure all required behavior is implemented with no scope creep
- [x] Update the thread `plan.md` task markers to reflect actual completion state during execution
- [x] Automatic verification for Phase 3
  - [x] Run the most relevant final verification command(s) for the changed code and record any residual issues directly in the plan if something cannot be fully verified
  - [x] Prepare concise user testing steps for the exact new behavior
