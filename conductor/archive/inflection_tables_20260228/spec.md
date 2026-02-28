# Spec: Dynamic Inflection Tables

## Overview

Build declension/conjugation tables dynamically in Dart from `stem` + `pattern` + `inflection_templates.data` (JSON grid), achieving visual parity with the DPD webapp inflection tables. This replaces reliance on pre-rendered `inflections_html` for display (though that column remains in the DB for now).

## Functional Requirements

### 1. Add `InflectionTemplates` table to Drift schema
- Define a Drift table matching the Python `inflection_templates` table: `pattern` (PK), `like`, `data` (JSON string).
- Regenerate Drift code.

### 2. Inflection table builder (Dart logic)
- Given a headword's `stem`, `pattern`, `pos`, `lemma_1`, and the matching `InflectionTemplates.data` JSON:
  - Clean the stem (strip `!` and `*` markers).
  - Parse the 3D JSON array (rows × columns × cell values).
  - For each cell at odd column indices > 0 in rows > 0, concatenate `stem + ending` to produce inflected forms.
  - Handle special stems: `*` (irregular, template has full forms), `!` (already inflected), `-` (indeclinable, no table).
- Return a structured data model (not HTML) representing the table: headers, row labels, cells with forms and grammar tooltips.

### 3. Inflection table widget
- Render the structured table data as a native Flutter widget (no `flutter_html`).
- Match webapp styling: bordered table, bold endings, centered cells, `nowrap` headers, rounded corners.
- Heading text: `"{lemma} is {pattern} declension/conjugation (like {like})"` or `"(irregular)"`.
- Button label: "Declension" for pos in `[adj, card, cs, fem, masc, nt, ordin, pp, pron, prp, ptp, root, ve, letter]`, "Conjugation" for pos in `[aor, cond, fut, imp, imperf, opt, perf, pr]`.
- Multiple endings in one cell separated by line breaks.
- Empty endings produce empty cells.

### 4. Integration into all display contexts
- Replace the current `DpdHtmlTable(data: h.inflectionsHtml!)` usage with the new dynamic widget in:
  - `AccordionCard`
  - `InlineEntryCard`
  - `EntryBottomSheet`
  - `EntryScreen`
- Keep frequency (`freqHtml`) rendering unchanged (still uses `DpdHtmlTable`).
- Add `DpdFooter` to the inflection section for consistency.

### 5. Performance
- Table generation must be fast enough for smooth scrolling through search results.
- Cache parsed template data in memory (only 153 templates).
- Optimize for the common case: single DB lookup for template, pure Dart computation for the table.

## Non-Functional Requirements
- Optimized for speed — no perceptible delay when opening the inflection section.
- Native Flutter widgets preferred over HTML rendering for the inflection table.

## Acceptance Criteria
- [ ] Inflection tables render identically to webapp for standard declensions (e.g., `a masc`, `ā fem`).
- [ ] Irregular forms (stem `*`) render correctly (e.g., `atthi`).
- [ ] Indeclinables (stem `-`) show no table.
- [ ] Button says "Declension" or "Conjugation" based on pos.
- [ ] Heading shows pattern and "like" exemplar word.
- [ ] All four display contexts render the dynamic table.
- [ ] Opening the inflection section feels instant.

## Out of Scope
- Graying out unattested forms (requires bundling Tipitaka word set — future track).
- Removing `inflections_html` column from the database (future optimization track).
- Frequency table changes (stays as `DpdHtmlTable` with `freqHtml`).
