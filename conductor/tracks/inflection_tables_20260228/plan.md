# Plan: Dynamic Inflection Tables

## Phase 1: Database & Data Model [checkpoint: 4d87a50]

- [x] Task: Add InflectionTemplates Drift table definition to tables.dart [3b64692]
  - [x] Define table with `pattern` (text PK), `like` (text), `data` (text/JSON)
  - [x] Regenerate Drift code with `build_runner`

- [x] Task: Create inflection data model [a999031]
  - [x] Define `InflectionTableData` class: headers, rows, heading text, button label
  - [x] Define `InflectionCell` class: list of forms, grammar tooltip
  - [x] Define `InflectionForm` class: stem, ending, full word

- [x] Task: Write tests for inflection table builder logic [e98f063]
  - [x] Test standard declension (e.g., `a masc` pattern with known stem)
  - [x] Test conjugation (e.g., `pr` pattern)
  - [x] Test irregular stem (`*`) — template contains full forms
  - [x] Test already-inflected stem (`!`) — returns table but limited inflections
  - [x] Test indeclinable stem (`-`) — returns null/no table
  - [x] Test multiple endings in one cell
  - [x] Test empty endings produce empty cells

- [x] Task: Implement inflection table builder [dd00a35]
  - [x] Parse 3D JSON array from template data
  - [x] Clean stem (strip `!` and `*` markers)
  - [x] Build header row from row 0 odd columns
  - [x] Build data rows: column 0 = row label, odd columns = stem + ending
  - [x] Extract grammar tooltip from even columns
  - [x] Determine button label (Declension vs Conjugation) from pos
  - [x] Generate heading text with pattern, like, and lemma
  - [x] Handle all special stem cases

- [x] Task: Create template cache provider [dd49454]
  - [x] Riverpod provider that loads all 153 templates into memory on first access
  - [x] Keyed by pattern string for O(1) lookup

- [x] Task: Conductor - User Manual Verification 'Phase 1: Database & Data Model' (Protocol in workflow.md) [4d87a50]

## Phase 2: Widget & Integration [checkpoint: ]

- [x] Task: Create InflectionTable widget [239f80d]
  - [x] Render heading text (pattern, like/irregular)
  - [x] Render native Flutter Table with headers, row labels, and cells
  - [x] Style to match webapp: borders, bold endings, centered cells, rounded corners, nowrap headers
  - [x] Handle multiple forms per cell (line breaks)
  - [x] Handle empty cells

- [x] Task: Extract reusable InflectionSection widget [1fc9741]
  - [x] Wraps InflectionTable + frequency sub-section + DpdFooter
  - [x] Accepts headword data and template cache
  - [x] Handles the "no table" case (indeclinable)

- [x] Task: Integrate into AccordionCard, InlineEntryCard, and EntryBottomSheet [b59a599]
  - [x] Replace current `DpdHtmlTable(data: h.inflectionsHtml!)` with new InflectionSection
  - [x] Update button label from "Inflections" to "Declension"/"Conjugation" based on pos
  - [x] Keep frequency rendering via DpdHtmlTable unchanged

- [x] Task: Integrate into EntryScreen [f74562f]
  - [x] Replace current raw Html inflection rendering with new InflectionSection
  - [x] Update ExpansionTile title to "Declension"/"Conjugation"

- [x] Task: Add DpdFooter to inflection section [1fc9741]
  - [x] Feedback link matching grammar/examples footer pattern

- [~] Task: Conductor - User Manual Verification 'Phase 2: Widget & Integration' (Protocol in workflow.md)
  - Fixes applied [5006214]: heading RichText bold, per-cell border/radius, table expansion, frequency removed
