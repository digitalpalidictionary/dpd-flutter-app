# Grammar Tab Webapp Parity Specification

## Overview
Implement exact visual and functional parity between the Flutter app grammar tab and the dpd webapp grammar tab (reference: `/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/webapp/templates/dpd_headword.html` lines 995-1175).

## Functional Requirements

### 1. Database Schema Updates
- Add missing fields to `tables.dart`: `non_ia`, `cognate`, `link`, `phonetic`, `compound_construction`, `var_phonetic`, `var_text`, `origin`
- Establish relationship to `DpdRoots` table for root details (`root_has_verb`, `root_group`, `root_meaning`, `sanskrit_root`, `sanskrit_root_class`, `sanskrit_root_meaning`, `root_in_comps`)
- *Note: No local database migration scripts are necessary, as the app simply downloads the `dpd.db` file directly.*

### 2. Dart Extensions for Computed Data
- Create `lib/database/dpd_headword_extensions.dart` providing an `extension DpdHeadwordGrammar on DpdHeadword`:
  - `lemmaClean` - Regex cleanup of lemma_1
  - `lemmaTradClean` - Placeholder for Python-dependent conversion
  - `lemmaIpa` - Placeholder for Python-dependent conversion  
  - `rootClean` - Regex cleanup of root_key
  - `cleanConstruction()` - Port logic from Python `meaning_construction.py`
  - `grammarLine` - Port `makeGrammarLine()` function from Python
- *Note: Ensure regex operations utilize `RegExp(..., multiLine: true, unicode: true)` for proper handling of Pāḷi diacritics.*

### 3. Grammar Table Widget
- Create `lib/widgets/grammar_table.dart` matching webapp HTML table structure
- Use Flutter's native `Table` widget with `IntrinsicColumnWidth` for the labels column and `FlexColumnWidth` for the values column to achieve HTML table parity
- Use `flutter_html`'s `Html(data: ...)` widget for fields marked `|safe` in the web template (`construction`, `phonetic`, `compound_construction`, `commentary`, `notes`)
- Add footer with "Did you spot a mistake?" link to Google Form, ensuring URL parameters (like lemma) are properly encoded using `Uri.encodeComponent`
- Replace current `buildGrammarRows()` usage in all entry display components

### 4. Audio Integration
- Audio functionality will be handled in a separate issue. For now, implement simple, stateless UI placeholders.
- Render SVG-styled play buttons for male1, male2, female1 genders matching the webapp visuals without active playback logic.

### 5. Field-by-Field Parity
All fields from webapp template must be implemented with same conditional logic:

| Webapp Field | Implementation | Status |
|-------------|----------------|--------|
| `lemma_clean` | `headword.lemmaClean` | ✅ |
| `lemma_trad_clean` | `headword.lemmaTradClean` | ⏳ Placeholder |
| `lemma_ipa` | `headword.lemmaIpa` | ⏳ Placeholder |
| Audio buttons | Static UI placeholders | ⏳ Placeholder |
| `d.grammar` | `headword.grammarLine` | ✅ |
| `family_root` | Direct field | ✅ |
| Root details | `DpdRoots` join | ✅ |
| `construction` | Direct field + `flutter_html` | ✅ |
| `derivative + suffix` | Direct fields | ✅ |
| `phonetic` | New field + `flutter_html` | ⏳ |
| `compound_type + compound_construction` | Direct + new field + `flutter_html` | ⏳ |
| `antonym`, `synonym`, `variant` | Direct fields | ✅ |
| `commentary`, `notes` | Direct fields + `flutter_html` | ✅ |
| `cognate`, `link`, `non_ia` | New fields | ⏳ |
| `sanskrit` | Direct field | ✅ |
| Sanskrit root details | `DpdRoots` join | ✅ |

## Non-Functional Requirements

### Performance
- Table rendering should be efficient with many conditional checks
- Database joins should be optimized

### Maintainability
- Break down table rendering into modular, nullable functions (e.g., `TableRow? _buildLemmaRow(...)`) to avoid massive widget build methods. Filter null rows before passing them to the `Table` widget.
- Code should be clean, straightforward, and avoid over-engineering.

### Compatibility
- Graceful handling of missing audio API
- Placeholder values for Python-dependent computations

## Acceptance Criteria

1. **Visual Match**: Grammar tab in Flutter app looks identical to webapp
2. **All Fields**: All 23+ fields display with same conditional logic and `Html` rendering where appropriate.
3. **Table Structure**: Native `Table` widget with proper sizing instead of fixed-width Rows.
4. **Footer Link**: "Did you spot a mistake?" link matches webapp and is safely URL-encoded.
5. **Clean Code**: Computed fields are encapsulated in Dart extensions.

## Out of Scope

1. **IPA Conversion**: Full implementation of Python aksharamukha library
2. **Traditional Lemma Conversion**: Python-dependent conversion
3. **Actual Audio Playback**: UI placeholders only
4. **Database Re-creation**: Handled implicitly by downloading the DB file.

## References
- Webapp template: `/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/webapp/templates/dpd_headword.html` (lines 995-1175)
- Python logic: `/home/bodhirasa/MyFiles/3_Active/dpd-db/tools/meaning_construction.py`
- Current Flutter implementation: `lib/widgets/entry_content.dart` `buildGrammarRows()`
- Database schema: `lib/database/tables.dart`