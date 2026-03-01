# Plan: Frequency Table

## Phase 1: Data Layer

- [x] Task: Add `freq_data` column to DpdHeadwords Drift table definition in `lib/database/tables.dart` 9f2e2ed
- [~] Task: Run `dart run build_runner build --delete-conflicting-outputs` to regenerate Drift code
- [ ] Task: Create `FrequencyData` model class (`lib/models/frequency_data.dart`) with JSON parsing
  - Fields: freqHeading, cstFreq/cstGrad (49), bjtFreq/bjtGrad (39), syaFreq/syaGrad (30), scFreq/scGrad (19)
  - Factory constructor `fromJson(String json)` and `isEmpty` getter
- [ ] Task: Write tests for `FrequencyData` model — parsing, empty handling, edge cases
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Data Layer' (Protocol in workflow.md)

## Phase 2: Frequency Table Widget

- [ ] Task: Create `FrequencyTable` widget (`lib/widgets/frequency_table.dart`)
  - Build native Flutter Table from FrequencyData
  - Implement complete row/cell/index mapping per `webapp_reference.md` Section 6
  - Implement all rowspans per `webapp_reference.md` Section 7
  - Implement gradient cell styling (gr0–gr10) using DpdColors.freq
  - Implement void cells and gap columns
  - Implement vertical text category labels (Vinaya, Sutta, Abhidhamma, Aññā)
  - Implement header rows (corpus names with tooltips, M/A/Ṭ sub-columns)
  - Wrap table in SingleChildScrollView for horizontal scrolling
- [ ] Task: Create `FrequencySection` widget (`lib/widgets/frequency_section.dart`)
  - Heading with bold word from FreqHeading
  - FrequencyTable
  - Corpus legend (CST, BJT, SYA, MST full names)
  - Explanation link
  - DpdFooter with feedback link
  - Empty state handling
  - Wrap in DpdSectionContainer with standard padding
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Frequency Table Widget' (Protocol in workflow.md)

## Phase 3: Button Integration

- [ ] Task: Add frequency button to `EntryBottomSheet` — after family buttons, using DpdSectionButton
  - Only show when freq_data is non-empty
  - Toggle frequency section visibility
  - Integrate with one-button-toggle mode (settings)
- [ ] Task: Add frequency button to `EntryContent` widget (same pattern)
- [ ] Task: Add frequency button to `InlineEntryCard` widget (same pattern)
- [ ] Task: Verify dark mode rendering of frequency table and gradient cells
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Button Integration' (Protocol in workflow.md)
