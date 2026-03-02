# Plan: Lookup-Based Secondary Search Results

## Phase 1: Database Schema & Code Generation

- [x] Task: Add `deconstructor` and `epd` columns to Lookup table in `lib/database/tables.dart`
    - [x] Add `TextColumn get deconstructor => text().nullable()();`
    - [x] Add `TextColumn get epd => text().nullable()();`
- [x] Task: Run `dart run build_runner build --delete-conflicting-outputs` to regenerate Drift code
- [x] Task: Verify the app compiles cleanly with `flutter analyze` [62acb6e]

## Phase 2: Data Models & JSON Parsing [checkpoint: 0d0a285]

- [x] Task: Write failing tests for all 8 data model JSON parsers (Red Phase)
    - [ ] Test `DeconstructorResult` parses `list[str]` JSON correctly
    - [ ] Test `GrammarDictResult` parses `list[list[str,str,str]]` and splits components to 3-element padded list
    - [ ] Test `AbbreviationResult` parses `dict` with required `meaning` and optional `pali`, `example`, `explanation`
    - [ ] Test `HelpResult` parses JSON-encoded string (double-encoded: `json.loads()` yields a plain string)
    - [ ] Test `EpdResult` parses `list[list[str,str,str]]` tuples
    - [ ] Test `VariantResult` parses nested `dict{corpus: {book: [[context, variant]]}}` structure
    - [ ] Test `SpellingResult` parses `list[str]`
    - [ ] Test `SeeResult` parses `list[str]`
    - [ ] Test all models return empty/null for empty string or null input
- [x] Task: Implement data models in `lib/models/lookup_results.dart` (Green Phase)
    - [ ] `DeconstructorResult` — fields: `String headword`, `List<String> deconstructions`
    - [ ] `GrammarDictEntry` — fields: `String headword`, `String pos`, `List<String> components` (always length 3, padded with empty strings)
    - [ ] `GrammarDictResult` — fields: `String headword`, `List<GrammarDictEntry> entries`
    - [ ] `AbbreviationResult` — fields: `String headword`, `String meaning`, `String? pali`, `String? example`, `String? explanation`
    - [ ] `HelpResult` — fields: `String headword`, `String helpText`
    - [ ] `EpdEntry` — fields: `String headword`, `String posInfo`, `String meaning`
    - [ ] `EpdResult` — fields: `String headword`, `List<EpdEntry> entries`
    - [ ] `VariantResult` — fields: `String headword`, `Map<String, Map<String, List<List<String>>>> variants`
    - [ ] `SpellingResult` — fields: `String headword`, `List<String> spellings`
    - [ ] `SeeResult` — fields: `String headword`, `List<String> seeHeadwords`
    - [ ] Each model has a factory `fromJson(String headword, String? jsonString)` that returns null if input is null/empty
- [x] Task: Run tests — confirm all pass [404a407]

## Phase 3: DAO & Provider Layer

- [x] Task: Write failing tests for secondary results parsing from a Lookup row (Red Phase)
    - [ ] Test that a Lookup row with populated columns produces the correct list of typed results
    - [ ] Test that a Lookup row with all-empty secondary columns produces an empty results list
    - [ ] Test that result ordering matches: abbreviations → deconstructor → grammar → help → EPD → variant → spelling → see
- [x] Task: Extend `DpdDao` — ensure existing lookup queries return all columns (Green Phase)
    - [ ] Verify existing `select` on Lookup table already fetches full row (Drift default)
    - [ ] If not, update query to include all columns
- [x] Task: Create `SecondaryResultsProvider` in `lib/providers/`
    - [ ] Accept a `LookupData` row (already fetched by search)
    - [ ] Parse each non-empty column into its typed model using the factory constructors
    - [ ] Return `List<Object>` of results in webapp order (abbreviations, deconstructor, grammar, help, EPD, variant, spelling, see)
    - [ ] Skip any column that is null or empty string
- [x] Task: Run tests — confirm all pass [809536a]

## Phase 4: Shared Card Widget Foundation

- [ ] Task: Create `DpdSecondaryCard` base widget in `lib/widgets/secondary/`
    - [ ] Accepts `String title`, `Widget content`, optional `Widget? footer`
    - [ ] Renders h3-equivalent header: font-size 130%, margin-top 10px, margin-bottom 1px, bold
    - [ ] Renders content in primary-bordered container: 2px solid primary (`#00BFFF`), 7px border-radius, padding 3px 7px, line-height 150%
- [ ] Task: Create `TertiaryCard` variant widget
    - [ ] Same structure as `DpdSecondaryCard` but border uses secondary GREEN color (`hsl(158, 100%, 35%)`)
    - [ ] Padding 3px 5px (slightly narrower than DpdSecondaryCard's 3px 7px)
    - [ ] Used by Abbreviations and Help cards only
- [ ] Task: Add secondary/tertiary color constants to `DpdColors`
    - [ ] `secondaryColor` = `hsl(158, 100%, 35%)` — green for tertiary borders and table headers
    - [ ] `epdColor` = `hsl(205, 79%, 48%)` — primary-text blue for EPD headwords
    - [ ] `hrColor` = `hsla(0, 0%, 50%, 0.25)` — gray-transparent for variant table separators

## Phase 5: Card Widget Implementations

- [ ] Task: Implement `DeconstructorCard` widget
    - [ ] Header: "deconstructor: {headword}" — h3 equivalent
    - [ ] Container: `div.dpd` — 2px solid primary, 7px radius, padding 3px 7px
    - [ ] Content: Plain text strings from `deconstructions` list, each on own line separated by line breaks
    - [ ] Footer: `DpdFooter` with three links — "read the docs" (https://digitalpalidictionary.github.io/features/deconstructor/), "suggest improvements" (Google Form with entry.326955045=Deconstructor), "add missing words" (Google Form)
- [ ] Task: Implement `GrammarDictCard` widget
    - [ ] Header: "grammar: {headword}" — h3 equivalent
    - [ ] Container: `div.dpd` — 2px solid primary, 7px radius
    - [ ] Content: Table widget with columns: pos (bold), comp1, comp2, comp3, "of", word
    - [ ] Table CSS rules: no borders, `border-collapse: collapse`, `padding: 2px 10px 0px 0px`, left-aligned, `vertical-align: center`
    - [ ] Empty component cells (`comp == ""`) are hidden entirely (`display: none` equivalent — simply omit from row)
    - [ ] Table headers: "pos", (blank), (blank), (blank), (blank), "word" — NO sort arrows
    - [ ] Footer: `DpdFooter` with "read the docs" link (https://digitalpalidictionary.github.io/features/grammardict/)
- [ ] Task: Implement `AbbreviationCard` widget
    - [ ] Header: "{headword}" — NO prefix, just the abbreviation itself, h3 equivalent
    - [ ] Container: `div.tertiary` — 2px solid GREEN (`--secondary`), 7px radius, padding 3px 5px
    - [ ] Content: Key-value table using `table.help` styling:
        - [ ] `th` width 10%, color GREEN (`--secondary`), font-weight 700, left-aligned, vertical-align top
        - [ ] `td` width 90%, left-aligned, vertical-align top
        - [ ] Row "Abbreviation": value = **{headword}** (bold) — ALWAYS shown
        - [ ] Row "Meaning": value = {meaning} — ALWAYS shown
        - [ ] Row "Pāḷi": value = {pali} — ONLY if non-empty
        - [ ] Row "Example": value = {example} — ONLY if non-empty
        - [ ] Row "Information": value = {explanation} — ONLY if non-empty
    - [ ] NO footer
- [ ] Task: Implement `HelpCard` widget
    - [ ] Header: "{headword}" — NO prefix, h3 equivalent
    - [ ] Container: `div.tertiary` — 2px solid GREEN, 7px radius, padding 3px 5px
    - [ ] Content: Key-value table using `table.help` styling (identical CSS to AbbreviationCard):
        - [ ] Row "Help": value = **{headword}** (bold) — ALWAYS shown
        - [ ] Row "Meaning": value = {helpText} — ALWAYS shown
    - [ ] NO footer
- [ ] Task: Implement `EpdCard` widget
    - [ ] Header: "English: {headword}" — h3 equivalent
    - [ ] Container: `div.dpd` — 2px solid primary, 7px radius
    - [ ] Content: For each `EpdEntry`, a paragraph containing:
        - [ ] Bold headword in primary-text color (`hsl(205, 79%, 48%)`) — `.epd` class
        - [ ] If `posInfo` non-empty: " {posInfo}."
        - [ ] " {meaning}."
    - [ ] NO footer
- [ ] Task: Implement `VariantCard` widget
    - [ ] Header: "variants: {headword}" — h3 equivalent
    - [ ] Container: `div.dpd` — 2px solid primary, 7px radius
    - [ ] Content: Table with 4 columns and header row:
        - [ ] Headers: "source", "filename", "context", "variant"
        - [ ] Table CSS: `border-collapse: collapse`, no borders, `padding: 2px 10px 0px 0px`, left-aligned
        - [ ] Iterate outer map (corpus → books): between each corpus group, insert a full-width `<hr>` separator row (1px solid gray-transparent `hsla(0,0%,50%,0.25)`)
        - [ ] Iterate books → entries: each entry is a row with corpus, book, context, variant
        - [ ] First 2 columns (source, filename) use `white-space: nowrap` equivalent
    - [ ] Footer: `DpdFooter` with "read the docs" link (https://digitalpalidictionary.github.io/features/variants/)
- [ ] Task: Implement `SpellingCard` widget
    - [ ] Header: "spelling: {headword}" — h3 equivalent
    - [ ] Container: `div.dpd` — 2px solid primary, 7px radius
    - [ ] Content: For each spelling in list: "incorrect spelling of ***{spelling}***" (bold italic). Multiple entries separated by line breaks.
    - [ ] NO footer
- [ ] Task: Implement `SeeCard` widget
    - [ ] Header: "see: {headword}" — h3 equivalent
    - [ ] Container: `div.dpd` — 2px solid primary, 7px radius
    - [ ] Content: For each headword in list: "see ***{headword}***" (bold italic). Multiple entries separated by line breaks.
    - [ ] NO footer

## Phase 6: Search Screen Integration

- [ ] Task: Integrate secondary results into `SearchScreen` results list
    - [ ] After existing headword and root result widgets, render secondary card widgets
    - [ ] Use `SecondaryResultsProvider` to get ordered list of typed results
    - [ ] Map each result type to its corresponding card widget
    - [ ] Only render cards for non-null results (empty columns produce no output)
- [ ] Task: Ensure correct ordering in all three display modes
    - [ ] Inline mode: cards appear in scrollable list after headword/root entries
    - [ ] Accordion mode: cards appear below accordion entries
    - [ ] Bottom Sheet mode: cards appear in scrollable content area
- [ ] Task: Verify cards respect theme (light/dark) and user font size settings
- [ ] Task: Run `flutter analyze` — ensure no warnings or errors
- [ ] Task: Run `flutter test` — ensure all tests pass
- [ ] Task: Conductor - User Manual Verification 'All Phases' (Protocol in workflow.md)
