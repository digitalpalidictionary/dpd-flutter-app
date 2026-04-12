# Spec: Add "other abbreviations" lookup rendering to the Flutter app

## Overview
The mobile app should support the newly added `abbrev_other` lookup-table column and render it with the same user-facing behavior as the DPD webapp, using the smallest possible Flutter changes and without changing any existing result behavior.

## What it should do
- Read the new `abbrev_other` column from the `lookup` table in the mobile database.
- Parse `abbrev_other` into a dedicated secondary-result model in the Flutter app.
- Show an `other abbreviations.` entry in the summary area when this result exists, matching the webapp behavior.
- Render the detailed result as a compact two-column table matching the webapp structure:
  - left column: source
  - right column: meaning, followed by notes when present
- Integrate this result into the existing secondary-result ordering and source visibility system with minimal disruption.
- Normalize `abbrev_other` lookup keys in the database builder by removing one trailing `.` and merging dotted and undotted forms into the same lookup entry.
- Preserve all existing behavior for normal abbreviations, help, grammar, deconstructor, variants, spelling, see, headwords, roots, and other dictionaries.

## Constraints
- Make minimal changes only.
- Do not change existing functionality outside the new `abbrev_other` path.
- Reuse existing Flutter patterns for summary entries, secondary cards, compact mode, and secondary-result parsing.
- Follow existing theme and card styling; do not introduce hardcoded colors.
- The webapp parity reference is in the sibling `../dpd-db/` repo:
  - `exporter/webapp/templates/abbreviations_other_summary.html`
  - `exporter/webapp/templates/abbreviations_other.html`
  - `exporter/webapp/toolkit.py`
  - `exporter/webapp/data_classes.py`
  - `db/lookup/help_abbrev_add_to_lookup.py`
- Current Flutter state discovered in repo:
  - `lib/database/tables.dart` has `lookup.abbrev` but no `lookup.abbrev_other`
  - `lib/providers/secondary_results_provider.dart` parses abbreviations, deconstructor, grammar, help, EPD, variant, spelling, and see, but not other abbreviations
  - `lib/providers/summary_provider.dart` has no summary type or source mapping for other abbreviations
  - `lib/screens/search_screen.dart` has no source handling, target id, or widget mapping for other abbreviations
  - `lib/widgets/secondary/secondary_result_cards.dart` has `AbbreviationCard` but no equivalent card for webapp `other abbreviations`
  - `lib/providers/dict_provider.dart` defines built-in DPD source metadata, so a new source id likely needs to be added there too
- Because the lookup table schema changed, Drift schema code must be updated consistently in the app.

## How we'll know it's done
- The app code recognizes `abbrev_other` rows from the lookup table.
- A query that returns `abbrev_other` produces:
  - a summary entry labeled `other abbreviations.`
  - a scroll target to the rendered section
  - a rendered section showing the rows in a two-column table
- Dotted and undotted `abbrev_other` keys compile into the same lookup entry, so searches like `abs` find data originally keyed as `abs.`.
- Existing abbreviation rendering still behaves exactly as before.
- Static verification passes for the changed files, and any required generated Drift code is in sync.

## What's not included
- No redesign of the existing abbreviations UI.
- No changes to unrelated lookup result types or search behavior.
- No changes to non-`abbrev_other` database export logic in `../dpd-db/`.
- No new UI tests.
