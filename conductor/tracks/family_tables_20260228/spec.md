# Spec: Family Tables

## Overview

Add five family section buttons and their expandable content sections to the entry display, replicating the DPD webapp's family sections with complete visual parity. The five family types are:

1. **Root Family** — Words sharing the same Pāḷi root (e.g., √kara)
2. **Word Family** — Words belonging to the same word family
3. **Compound Family** — Compounds containing a specific word (single or multiple compound families per headword)
4. **Idioms** — Idiomatic expressions containing a word
5. **Sets** — Thematic sets a word belongs to (single or multiple sets per headword)

## Data Source

Use the existing `dpd.db` database directly (no mobile.db changes). Each family table (`family_root`, `family_word`, `family_compound`, `family_idiom`, `family_set`) has a `data` JSON column containing a list of 4-tuples: `[lemma, pos, meaning, completion_symbol]`. This structured data will be parsed and rendered as native Flutter widgets.

## Functional Requirements

### FR-1: Drift Table Definitions
Add Drift table definitions for all five family tables: `family_root`, `family_word`, `family_compound`, `family_idiom`, `family_set`. Each needs its primary key column(s), `data` (text/JSON), and `count` (integer).

### FR-2: DAO Queries
Add DAO methods to query each family table:
- Root family: query by `root_key` + `root_family` (composite key)
- Word family: query by `word_family`
- Compound family: query by `compound_family` (may return multiple rows for headwords with space-separated `family_compound`)
- Idiom: query by `idiom` (may return multiple rows)
- Set: query by `set` (may return multiple rows)

### FR-3: Reusable FamilyTable Widget
Create a single reusable widget that renders any family type. It receives:
- A header string (e.g., "**N** words belong to the root family **√kara** (to do)")
- A list of parsed data tuples `(lemma, pos, meaning, completion)`
- A footer configuration (message text, link text, feedback URL)

The widget renders inside a `DpdSectionContainer` with:
- Header: `<p class="heading underlined">` equivalent — bold count, descriptive text, bold family name
- Table: Native Flutter table with columns for lemma (bold), pos (bold), meaning, completion symbol
- Footer: `DpdFooter` widget with appropriate feedback link

### FR-4: Family Buttons
Add toggle buttons to the entry button bar for each applicable family type:
- "root family" — shown when `family_root` is non-empty
- "word family" — shown when `family_word` is non-empty
- "compound family" / "compound families" — shown when applicable (single vs multiple)
- "idioms" — shown when applicable
- "set" / "sets" — shown when applicable (single vs multiple)

Each button toggles visibility of its corresponding section.

### FR-5: Header Text Parity
Match the webapp's header text patterns exactly:
- Root: "**N** word(s) belong to the root family **√X** (meaning)"
- Word: "**N** words which belong to the **X** family"
- Compound (single): "**N** compound(s) which contain(s) **X**"
- Compound (multiple): Jump-to navigation + per-family headers with ⤴ links
- Idiom: "**N** idiomatic expression(s) which contain(s) **X**"
- Set (single): "**lemma** belongs to the set of **X**"
- Set (multiple): Jump-to navigation + per-set headers with ⤴ links

### FR-6: Multiple Families Support
For compound families and sets, a headword can belong to multiple families (space-separated in the headword column). When multiple families exist:
- Show "compound families" / "sets" button (plural)
- Display a "jump to" navigation header at the top
- Show each sub-family with its own header, separated by overline styling
- Include ⤴ back-to-top links

## Non-Functional Requirements

- **NFR-1:** Family data queries should complete in <50ms
- **NFR-2:** The reusable widget pattern must work for all five family types without type-specific widget code

## Acceptance Criteria

- [ ] All five family buttons appear on appropriate entries
- [ ] Tapping a button toggles the corresponding section
- [ ] Family table displays lemma, pos, meaning, and completion symbol
- [ ] Header text matches webapp patterns for each family type
- [ ] Multiple compound families / sets show jump-to navigation
- [ ] Footer shows appropriate feedback link per family type
- [ ] Visual styling matches webapp (heading underlined, table layout, footer)

## Out of Scope

- Mobile.db build script changes (use dpd.db directly for now)
- Clickable lemma links within family tables (navigation to other entries)
- Root info and root matrix sections
- Caching or performance optimization beyond basic query indexing
