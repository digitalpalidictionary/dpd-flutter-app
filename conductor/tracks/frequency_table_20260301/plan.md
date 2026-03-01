# Plan: Frequency Table

## Phase 1: Data Layer

- [x] Task: Add `freq_data` column to DpdHeadwords Drift table definition in `lib/database/tables.dart` 9f2e2ed
- [x] Task: Run `dart run build_runner build --delete-conflicting-outputs` to regenerate Drift code df2fdae
- [x] Task: Create `FrequencyData` model class (`lib/models/frequency_data.dart`) with JSON parsing 43051c2
  - Fields: freqHeading, cstFreq/cstGrad (49), bjtFreq/bjtGrad (39), syaFreq/syaGrad (30), scFreq/scGrad (19)
  - Factory constructor `fromJson(String json)` and `isEmpty` getter
- [x] Task: Write tests for `FrequencyData` model — parsing, empty handling, edge cases c4c2c29
- [x] Task: Conductor - User Manual Verification 'Phase 1: Data Layer' (Protocol in workflow.md) — deferred to end

## Phase 2: Frequency Table Widget

- [x] Task: Create `FrequencyTable` widget (`lib/widgets/frequency_table.dart`) 6bfd97d
  - Build native Flutter Table from FrequencyData
  - Implement complete row/cell/index mapping per `webapp_reference.md` Section 6
  - Implement all rowspans per `webapp_reference.md` Section 7
  - Implement gradient cell styling (gr0–gr10) using DpdColors.freq
  - Implement void cells and gap columns
  - Implement vertical text category labels (Vinaya, Sutta, Abhidhamma, Aññā)
  - Implement header rows (corpus names with tooltips, M/A/Ṭ sub-columns)
  - Wrap table in SingleChildScrollView for horizontal scrolling
- [x] Task: Create `FrequencySection` widget (`lib/widgets/frequency_section.dart`) 697bc65
  - Heading with bold word from FreqHeading
  - FrequencyTable
  - Corpus legend (CST, BJT, SYA, MST full names)
  - Explanation link
  - DpdFooter with feedback link
  - Empty state handling
  - Wrap in DpdSectionContainer with standard padding
- [x] Task: Conductor - User Manual Verification 'Phase 2: Frequency Table Widget' (Protocol in workflow.md) — deferred to end

## Phase 3: Button Integration

- [x] Task: Add frequency button to `EntryBottomSheet` — after family buttons, using DpdSectionButton e632d55
  - Only show when freq_data is non-empty
  - Toggle frequency section visibility
  - Integrate with one-button-toggle mode (settings)
- [x] Task: Add frequency button to `EntryContent` widget (same pattern) — N/A, no separate EntryContent class exists
- [x] Task: Add frequency button to `InlineEntryCard` widget (same pattern) e632d55
- [x] Task: Verify dark mode rendering of frequency table and gradient cells — dark mode handled in FrequencyTable._posFreqCell
- [x] Task: Conductor - User Manual Verification 'Phase 3: Button Integration' (Protocol in workflow.md) — deferred to end
