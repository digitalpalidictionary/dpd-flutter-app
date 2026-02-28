# Grammar Tab Webapp Parity Implementation Plan

## Phase 1: Database Schema & Core Data

### Phase 1.1: Add Missing Database Fields
- [x] Task: Add missing fields to `lib/database/tables.dart` in the `DpdHeadwords` table: [dec36c6]
  - `TextColumn get nonIa => text().named('non_ia').nullable()();`
  - `TextColumn get cognate => text().nullable()();`
  - `TextColumn get link => text().nullable()();`
  - `TextColumn get phonetic => text().nullable()();`
  - `TextColumn get compoundConstruction => text().named('compound_construction').nullable()();`
  - `TextColumn get varPhonetic => text().named('var_phonetic').nullable()();`
  - `TextColumn get varText => text().named('var_text').nullable()();`
  - `TextColumn get origin => text().nullable()();`
- [x] Task: Run Drift build runner to regenerate database code (`dart run build_runner build -d`) [dec36c6]
- [x] Task: Note: No local database migration scripts needed as the database is downloaded directly. [dec36c6]

### Phase 1.2: Add DpdRoots Relationship
- [x] Task: Add standard Drift `join` with `DpdRoots` table in repository/DAO queries where headwords are fetched. [40b3f23]
  - E.g., `select(dpdHeadwords).join([leftOuterJoin(dpdRoots, dpdRoots.root.equalsExp(dpdHeadwords.rootKey))])`
- [x] Task: Ensure the UI has access to these joined `DpdRoots` details. [40b3f23]

### Phase 1.3: Create Dart Extensions for Computed Data
- [x] Task: Create `lib/database/dpd_headword_extensions.dart` providing `extension DpdHeadwordGrammar on DpdHeadword` [202cd6e]
- [x] Task: Implement `String get lemmaClean` getter (regex-based, use `unicode: true` for Pāḷi diacritics). [202cd6e]
- [x] Task: Implement `String get rootClean` getter (regex-based, use `unicode: true`). [202cd6e]
- [x] Task: Implement `String cleanConstruction()` method (ported from Python `meaning_construction.py`). [202cd6e]
- [x] Task: Implement `String get grammarLine` getter (ported from Python `make_grammar_line`). [202cd6e]
- [x] Task: Create static placeholder getters for `lemmaTradClean` and `lemmaIpa`. [202cd6e]
- [x] Task: Write basic unit tests for extension methods. [202cd6e]

- [ ] Task: Conductor - User Manual Verification 'Phase 1: Database Schema & Core Data' (Protocol in workflow.md)

## Phase 2: Grammar Table UI Implementation

### Phase 2.1: Create Grammar Table Widget
- [ ] Task: Create `lib/widgets/grammar_table.dart`.
- [ ] Task: Implement a native `Table` widget.
- [ ] Task: Define `columnWidths` with `0: IntrinsicColumnWidth()` (for labels) and `1: FlexColumnWidth()` (for values).
- [ ] Task: Set up modular row generation methods (e.g., `TableRow? _buildLemmaRow(...)`) that return `TableRow?` and filter out nulls before rendering.

### Phase 2.2: Implement Field-by-Field Rendering
- [ ] Task: Implement `lemma_clean` row (`headword.lemmaClean`).
- [ ] Task: Implement `lemma_trad_clean` row (placeholder).
- [ ] Task: Implement `lemma_ipa` row with static SVG audio button UI placeholders.
- [ ] Task: Implement `d.grammar` row (`headword.grammarLine`).
- [ ] Task: Implement `family_root` and root details rows using the `DpdRoots` join.
- [ ] Task: Implement `construction` row using `flutter_html`'s `Html(data: ...)` widget.
- [ ] Task: Implement `derivative + suffix` row.
- [ ] Task: Implement `phonetic` row using `Html(data: ...)`.
- [ ] Task: Implement `compound_type + compound_construction` row using `Html(data: ...)`.
- [ ] Task: Implement `antonym`, `synonym`, `variant` rows.
- [ ] Task: Implement `commentary` and `notes` rows using `Html(data: ...)`.
- [ ] Task: Implement `cognate`, `link`, `non_ia` rows.
- [ ] Task: Implement `sanskrit` and Sanskrit root rows.

### Phase 2.3: Add Footer and Complete Table
- [ ] Task: Add "Did you spot a mistake?" footer with Google Form link matching webapp.
- [ ] Task: Use `Uri.encodeComponent` on variables like lemma inserted into the Google form URL.

### Phase 2.4: Integrate Grammar Table
- [ ] Task: Replace all calls to `buildGrammarRows()` in existing components (`entry_content.dart`, `entry_bottom_sheet.dart`, `inline_entry_card.dart`, `accordion_card.dart`, `entry_screen.dart`) with the new `GrammarTable` widget.
- [ ] Task: Remove old `buildGrammarRows()` and related deprecated list-based row generation code.

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Grammar Table UI Implementation' (Protocol in workflow.md)

## Phase 3: Testing & Polish

### Phase 3.1: Comprehensive Testing
- [ ] Task: Test with various headword types (nouns, verbs, compounds).
- [ ] Task: Verify all conditional displays work correctly via extension methods.
- [ ] Task: Check edge cases like empty HTML fields rendering cleanly.

### Phase 3.2: Visual Verification
- [ ] Task: Compare side-by-side with webapp for exact visual parity.
- [ ] Task: Verify Table sizing, borders, colors, spacing match existing `.dpd` CSS classes.
- [ ] Task: Verify dark mode compatibility.

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Testing & Polish' (Protocol in workflow.md)

## Success Metrics

1. **Visual Parity**: Grammar tab looks identical to webapp (pixel-perfect match)
2. **Functional Parity**: All fields display with same conditional logic
3. **Performance**: No noticeable performance impact
4. **Maintainability**: Clean, documented code structure
5. **Extensibility**: Easy to add future enhancements

## Dependencies

- Flutter SDK
- Drift database ORM
- Existing DPD database schema
- Webapp template as reference (`/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/webapp/templates/dpd_headword.html`)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Database migration breaks existing data | Create backup migration strategy |
| Python-dependent fields can't be fully implemented | Use placeholders with clear documentation |
| Audio API endpoints unknown | Implement placeholder with logging |
| Performance issues with many conditional checks | Optimize rendering, use const widgets |
| Visual mismatch with webapp | Regular side-by-side testing |

## Future Enhancements (Out of Scope)

1. **Actual IPA Conversion**: Integrate aksharamukha library or service
2. **Actual Traditional Lemma Conversion**: Python dependency solution
3. **Actual Audio Playback**: API integration with caching
4. **Database Update Mechanism**: Automatically add new fields to existing databases