# Plan: Family Tables

## Phase 1: Database Layer — Drift Tables & DAO Queries [checkpoint: ee59154]

- [x] Task 1.1: Add Drift table definitions for all five family tables (a2ce740)
  - [x] Add `FamilyRootTable` with columns: `root_family_key` (PK), `root_key`, `root_family`, `root_meaning`, `data`, `count`
  - [x] Add `FamilyWordTable` with columns: `word_family` (PK), `data`, `count`
  - [x] Add `FamilyCompoundTable` with columns: `compound_family` (PK), `data`, `count`
  - [x] Add `FamilyIdiomTable` with columns: `idiom` (PK), `data`, `count`
  - [x] Add `FamilySetTable` with columns: `set_` (PK), `data`, `count`
  - [x] Register all five tables in `AppDatabase` annotation in `database.dart`
  - [x] Run `dart run build_runner build --delete-conflicting-outputs` to regenerate

- [x] Task 1.2: Add DAO query methods for each family table (9c88b54)
  - [x] Register new tables in `DpdDao` `@DriftAccessor` annotation
  - [x] Add `getRootFamily(String rootKey, String familyRoot)` → single result
  - [x] Add `getWordFamily(String wordFamily)` → single result
  - [x] Add `getCompoundFamilies(List<String> compoundFamilies)` → list of results
  - [x] Add `getIdioms(List<String> idioms)` → list of results
  - [x] Add `getSets(List<String> sets)` → list of results
  - [x] Run code generation

- [x] Task 1.3: Write tests for family DAO queries (9c88b54)
  - [x] Test root family lookup by composite key
  - [x] Test word family lookup
  - [x] Test compound family lookup with single and multiple keys
  - [x] Test idiom lookup with single and multiple keys
  - [x] Test set lookup with single and multiple keys
  - [x] Test empty/null key handling

## Phase 2: Reusable FamilyTable Widget [checkpoint: 56d025b]

- [x] Task 2.1: Create data model for parsed family data (5f4a94d)
  - [x] Create `FamilyEntry` class with fields: `lemma`, `pos`, `meaning`, `completion`
  - [x] Create `parseFamilyData(String jsonData)` → `List<FamilyEntry>`

- [x] Task 2.2: Write tests for family data parsing (5f4a94d)
  - [x] Test parsing valid JSON data from each family type
  - [x] Test parsing empty/null data
  - [x] Test parsing malformed JSON

- [x] Task 2.3: Create reusable `FamilyTableWidget` (3cfc9f3)
  - [x] Create widget accepting: header widget, `List<FamilyEntry>`, footer config
  - [x] Render inside `DpdSectionContainer`
  - [x] Build native `Table` with columns: lemma (bold), pos (bold), meaning, completion symbol
  - [x] Add `DpdFooter` at bottom with configurable feedback URL
  - [x] Style header as "heading underlined" (bold text, underline border, matching webapp)

## Phase 3: Family Section Integration [checkpoint: 06898cd]

- [x] Task 3.1: Create family section builder functions (8edb503)
  - [x] Create header builder for each family type matching webapp text patterns:
    - Root: "N word(s) belong to the root family X (meaning)"
    - Word: "N words which belong to the X family"
    - Compound: "N compound(s) which contain(s) X"
    - Idiom: "N idiomatic expression(s) which contain(s) X"
    - Set: "lemma belongs to the set of X"
  - [x] Create footer config for each family type with correct feedback form section names

- [x] Task 3.2: Create multi-family section widget for compound families and sets (8edb503)
  - [x] Build "jump to" navigation header when multiple sub-families exist
  - [x] Render each sub-family with its own header separated by overline styling
  - [x] Add ⤴ back-to-top scroll links between sub-families

- [x] Task 3.3: Add family buttons to entry button bar (8edb503)
  - [x] Add "root family" button — shown when `familyRoot` is non-empty
  - [x] Add "word family" button — shown when `familyWord` is non-empty
  - [x] Add "compound family" / "compound families" button — single vs multiple
  - [x] Add "idioms" button — shown when `familyIdioms` is non-empty
  - [x] Add "set" / "sets" button — shown when `familySet` has single vs multiple entries
  - [x] Each button toggles visibility of its corresponding section

- [x] Task 3.4: Wire family sections into entry screen (8edb503)
  - [x] Replace current `buildFamilyRows` ExpansionTile with individual family button/section pairs
  - [x] Add Riverpod providers or local state to manage section visibility toggles
  - [x] Load family data from DAO when section is opened (lazy load)
  - [x] Parse JSON data and pass to `FamilyTableWidget`

## Phase 4: User Verification & Fix-up

- [~] Task 4.1: User visual verification of root family section
  - [ ] User tests root family button and section on multiple entries
  - [ ] Fix any layout, data, or styling issues found

- [ ] Task 4.2: User visual verification of word family section
  - [ ] User tests word family button and section on multiple entries
  - [ ] Fix any layout, data, or styling issues found

- [ ] Task 4.3: User visual verification of compound family section
  - [ ] User tests single compound family entries
  - [ ] User tests multiple compound families with jump-to navigation
  - [ ] Fix any layout, data, or styling issues found

- [ ] Task 4.4: User visual verification of idioms section
  - [ ] User tests idioms button and section on multiple entries
  - [ ] Fix any layout, data, or styling issues found

- [ ] Task 4.5: User visual verification of sets section
  - [ ] User tests single set entries
  - [ ] User tests multiple sets with jump-to navigation
  - [ ] Fix any layout, data, or styling issues found

- [ ] Task: Conductor - User Manual Verification 'Phase 4: User Verification & Fix-up' (Protocol in workflow.md)
