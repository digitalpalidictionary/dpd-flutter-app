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

## Phase 3: DAO & Provider Layer [checkpoint: 8de00ee]

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

## Phase 4: Shared Card Widget Foundation [checkpoint: ad44059]

- [x] Task: Create `DpdSecondaryCard` base widget in `lib/widgets/secondary/`
    - [ ] Accepts `String title`, `Widget content`, optional `Widget? footer`
    - [ ] Renders h3-equivalent header: font-size 130%, margin-top 10px, margin-bottom 1px, bold
    - [ ] Renders content in primary-bordered container: 2px solid primary (`#00BFFF`), 7px border-radius, padding 3px 7px, line-height 150%
- [x] Task: Create `TertiaryCard` variant widget
    - [ ] Same structure as `DpdSecondaryCard` but border uses secondary GREEN color (`hsl(158, 100%, 35%)`)
    - [ ] Padding 3px 5px (slightly narrower than DpdSecondaryCard's 3px 7px)
    - [ ] Used by Abbreviations and Help cards only
- [x] Task: Add secondary/tertiary color constants to `DpdColors`
    - [ ] `secondaryColor` = `hsl(158, 100%, 35%)` — green for tertiary borders and table headers
    - [ ] `epdColor` = `hsl(205, 79%, 48%)` — primary-text blue for EPD headwords
    - [ ] `hrColor` = `hsla(0, 0%, 50%, 0.25)` — gray-transparent for variant table separators

## Phase 5: Card Widget Implementations [checkpoint: f696b9c]

- [x] Task: Implement `DeconstructorCard` widget
- [x] Task: Implement `GrammarDictCard` widget
- [x] Task: Implement `AbbreviationCard` widget
- [x] Task: Implement `HelpCard` widget
- [x] Task: Implement `EpdCard` widget
- [x] Task: Implement `VariantCard` widget
- [x] Task: Implement `SpellingCard` widget
- [x] Task: Implement `SeeCard` widget

## Phase 6: Search Screen Integration

- [x] Task: Integrate secondary results into `SearchScreen` results list
    - [x] After existing headword and root result widgets, render secondary card widgets
    - [x] Use `SecondaryResultsProvider` to get ordered list of typed results
    - [x] Map each result type to its corresponding card widget
    - [x] Only render cards for non-null results (empty columns produce no output)
- [x] Task: Ensure correct ordering in all three display modes
    - [x] Inline mode: cards appear in scrollable list after headword/root entries
    - [x] Accordion mode: cards appear below accordion entries
    - [x] Bottom Sheet mode: cards appear in scrollable content area
- [x] Task: Verify cards respect theme (light/dark) and user font size settings
- [x] Task: Run `flutter analyze` — ensure no warnings or errors
- [x] Task: Run `flutter test` — ensure all tests pass
- [x] Task: Conductor - User Manual Verification 'All Phases' (Protocol in workflow.md)
