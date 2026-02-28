# Plan: Dynamic Inflection Tables

## Phase 1: Database & Data Model [checkpoint: ]

- [x] Task: Add InflectionTemplates Drift table definition to tables.dart [3b64692]
  - [x] Define table with `pattern` (text PK), `like` (text), `data` (text/JSON)
  - [x] Regenerate Drift code with `build_runner`

- [x] Task: Create inflection data model [a999031]
  - [x] Define `InflectionTableData` class: headers, rows, heading text, button label
  - [x] Define `InflectionCell` class: list of forms, grammar tooltip
  - [x] Define `InflectionForm` class: stem, ending, full word

- [ ] Task: Write tests for inflection table builder logic
  - [ ] Test standard declension (e.g., `a masc` pattern with known stem)
  - [ ] Test conjugation (e.g., `pr` pattern)
  - [ ] Test irregular stem (`*`) — template contains full forms
  - [ ] Test already-inflected stem (`!`) — returns table but limited inflections
  - [ ] Test indeclinable stem (`-`) — returns null/no table
  - [ ] Test multiple endings in one cell
  - [ ] Test empty endings produce empty cells

- [ ] Task: Implement inflection table builder
  - [ ] Parse 3D JSON array from template data
  - [ ] Clean stem (strip `!` and `*` markers)
  - [ ] Build header row from row 0 odd columns
  - [ ] Build data rows: column 0 = row label, odd columns = stem + ending
  - [ ] Extract grammar tooltip from even columns
  - [ ] Determine button label (Declension vs Conjugation) from pos
  - [ ] Generate heading text with pattern, like, and lemma
  - [ ] Handle all special stem cases

- [ ] Task: Create template cache provider
  - [ ] Riverpod provider that loads all 153 templates into memory on first access
  - [ ] Keyed by pattern string for O(1) lookup

- [ ] Task: Conductor - User Manual Verification 'Phase 1: Database & Data Model' (Protocol in workflow.md)

## Phase 2: Widget & Integration [checkpoint: ]

- [ ] Task: Create InflectionTable widget
  - [ ] Render heading text (pattern, like/irregular)
  - [ ] Render native Flutter Table with headers, row labels, and cells
  - [ ] Style to match webapp: borders, bold endings, centered cells, rounded corners, nowrap headers
  - [ ] Handle multiple forms per cell (line breaks)
  - [ ] Handle empty cells

- [ ] Task: Extract reusable InflectionSection widget
  - [ ] Wraps InflectionTable + frequency sub-section + DpdFooter
  - [ ] Accepts headword data and template cache
  - [ ] Handles the "no table" case (indeclinable)

- [ ] Task: Integrate into AccordionCard, InlineEntryCard, and EntryBottomSheet
  - [ ] Replace current `DpdHtmlTable(data: h.inflectionsHtml!)` with new InflectionSection
  - [ ] Update button label from "Inflections" to "Declension"/"Conjugation" based on pos
  - [ ] Keep frequency rendering via DpdHtmlTable unchanged

- [ ] Task: Integrate into EntryScreen
  - [ ] Replace current raw Html inflection rendering with new InflectionSection
  - [ ] Update ExpansionTile title to "Declension"/"Conjugation"

- [ ] Task: Add DpdFooter to inflection section
  - [ ] Feedback link matching grammar/examples footer pattern

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Widget & Integration' (Protocol in workflow.md)
