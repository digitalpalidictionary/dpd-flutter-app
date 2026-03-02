# Spec: Frequency Table

## Overview

Add a "Frequency" button to dictionary entries that displays a native Flutter frequency heatmap table, replicating the webapp's frequency visualization. The table shows word occurrence counts across four Pāḷi text corpora (CST, BJT, SYA, SC) with a blue gradient heatmap indicating relative frequency. Data is sourced from the `freq_data` JSON column (not `freq_html`).

All visual details are captured in `webapp_reference.md` — that file is the single source of truth for styling and structure.

## Functional Requirements

### FR-1: Database Schema Update
- Add `freq_data` column (TEXT, nullable) to the `DpdHeadwords` Drift table definition
- Regenerate Drift code with `build_runner`

### FR-2: Frequency Data Model
- Parse `freq_data` JSON into a Dart model class (`FrequencyData`)
- Fields: `freqHeading` (String), `cstFreq`/`cstGrad`, `bjtFreq`/`bjtGrad`, `syaFreq`/`syaGrad`, `scFreq`/`scGrad` (all `List<int>`)
- Array lengths: CST=49, BJT=39, SYA=30, SC=19
- Handle empty/null `freq_data` gracefully (no button shown)

### FR-3: Frequency Button
- Label: "Frequency"
- Position: After all family buttons (last in button row)
- Uses existing `DpdSectionButton` widget
- Only shown when `freq_data` is non-empty
- Toggles frequency section visibility

### FR-4: Frequency Table Widget
- Native Flutter `Table` widget (no WebView/HTML rendering)
- Wrapped in `SingleChildScrollView` with horizontal scrolling
- Wrapped in `DpdSectionContainer` with standard section padding
- Table structure: see `webapp_reference.md` Section 6 for complete row/cell/index mapping
- Rowspans: see `webapp_reference.md` Section 7
- Gradient cells: see `webapp_reference.md` Section 5
- Void/gap cells: see `webapp_reference.md` Section 4

### FR-5: Heading
- Displayed above the table inside the section container
- Dynamic text from `FreqHeading` field (contains HTML `<b>` tags → render bold inline)
- See `webapp_reference.md` Section 2 for variants

### FR-6: Corpus Legend
- Below the table, four lines: CST, BJT, SYA, MST with full names
- See `webapp_reference.md` Section 9

### FR-7: Footer
- Use `DpdFooter` widget with link to frequency explanation page
- URL: `https://digitalpalidictionary.github.io/features/frequency/`
- Feedback link matching existing pattern

### FR-8: Empty State
- When `freq_data` is empty/null: no button shown at all
- When heading says "no exact matches": show heading + explanatory text, no table

## Non-Functional Requirements
- Dark mode support: text colors invert appropriately (see `webapp_reference.md` Section 5 dark mode rules)
- Performance: JSON parsing should be lazy (only when section expanded)
- Visual parity with webapp frequency table

## Acceptance Criteria
1. Frequency button appears after family buttons for entries with frequency data
2. Tapping the button shows/hides the frequency table section
3. Table matches webapp layout: 4 corpus column groups, vertical category labels, gap columns, rowspans
4. Gradient heatmap colors match webapp (11 blue levels from DpdColors.freq)
5. Horizontal scrolling works for the wide table
6. Dark mode renders correctly
7. Empty entries show no button; zero-frequency entries show appropriate message
8. Settings integration: one-button-toggle mode works with frequency

## Out of Scope
- Frequency data generation/calculation (handled by Go pipeline)
- Modifying `freq_html` column usage
- Adding frequency search/filtering capabilities
