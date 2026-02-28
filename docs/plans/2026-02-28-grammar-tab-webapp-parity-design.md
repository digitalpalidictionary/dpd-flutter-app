# Grammar Tab Webapp Parity Design
**Date**: 2026-02-28  
**Goal**: Match the dpd webapp grammar tab exactly in the Flutter app

## Current State Analysis

### Webapp Grammar Tab (Reference)
- **Location**: `/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/webapp/templates/dpd_headword.html` (lines 995-1175)
- **Structure**: HTML table with conditional rendering for each field
- **Fields Displayed**: 23+ fields including lemma_clean, lemma_trad_clean, lemma_ipa, grammar, root details, construction, derivative, phonetic, compound_type, antonym, synonym, variant, commentary, notes, cognate, link, non_ia, sanskrit, Sanskrit root details
- **Audio Integration**: Play buttons for male1, male2, female1 audio files
- **Footer**: "Did you spot a mistake?" link to Google Form

### Flutter App Current Implementation
- **Location**: `lib/widgets/entry_content.dart` - `buildGrammarRows()` function
- **Structure**: Simple list of label-value pairs in accordion
- **Fields Displayed**: Only 13 fields (pos, grammar, derivedFrom, neg, verb, trans, plusCase, derivative, stem, pattern, rootKey, rootSign, rootBase, compoundType)
- **Missing**: Audio, table layout, many data fields, conditional rendering logic

## Design Decisions

### 1. Database Schema Updates
Add missing fields from webapp to Flutter database schema:

**Fields to Add:**
- `non_ia` (String) - Non-IA script information
- `cognate` (String) - English cognate
- `link` (String) - Web links (JSON string/list)
- `phonetic` (String) - Phonetic changes
- `compound_construction` (String) - Compound construction details
- `var_phonetic` (String) - Variant phonetic
- `var_text` (String) - Variant text
- `origin` (String) - Word origin

**Database Relationships:**
- Add relationship to `DpdRoots` table for: `root_has_verb`, `root_group`, `root_meaning`, `sanskrit_root`, `sanskrit_root_class`, `sanskrit_root_meaning`, `root_in_comps`

### 2. Computed Fields Module
Create `lib/database/computed_fields.dart` with placeholders for Python-dependent calculations:

```dart
class ComputedFields {
  // Simple regex-based computations (implement now)
  static String lemmaClean(String lemma1) {
    // Remove trailing number pattern: "dhamma 1.01" → "dhamma"
    return lemma1.replaceAll(RegExp(r' \d+\.\d+$'), '');
  }
  
  static String lemmaTradClean(String lemma1) {
    // Placeholder - requires Python aksharamukha library
    return lemma1; // Return same for now
  }
  
  static String lemmaIpa(String lemmaClean) {
    // Placeholder - requires Python aksharamukha library
    return ''; // Empty string for now
  }
  
  static String rootClean(String rootKey) {
    return rootKey.replaceAll(RegExp(r' \d+\.\d+$'), '');
  }
  
  // Construction cleaning logic from Python
  static String cleanConstruction(String construction) {
    if (construction.isEmpty) return '';
    // Simplified version - remove line 2, brackets, phonetic changes
    String cleaned = construction;
    cleaned = cleaned.replaceAll(RegExp(r'\n.*$'), '');
    cleaned = cleaned.replaceAll('(', '').replaceAll(')', '');
    cleaned = cleaned.replaceAll(RegExp(r'> .[^ ]*? '), '');
    cleaned = cleaned.replaceAll(RegExp(r'> .[^ ]*?$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\[.*\] \+| \+ \[.*\]$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\?\\? '), '');
    return cleaned;
  }
}
```

### 3. Grammar Table Widget Architecture
Create `lib/widgets/grammar_table.dart`:

```dart
class GrammarTable extends StatelessWidget {
  final DpdHeadword headword;
  final DpdRoot? dpdRoot; // Joined root data
  
  const GrammarTable({required this.headword, this.dpdRoot});
  
  @override
  Widget build(BuildContext context) {
    final computed = ComputedFields();
    final rows = <GrammarTableRow>[];
    
    // Build rows exactly matching webapp template order and conditions
    if (headword.lemmaClean.isNotEmpty) {
      rows.add(GrammarTableRow(
        label: 'Lemma',
        value: computed.lemmaClean(headword.lemma1),
      ));
    }
    
    if (headword.lemmaTradClean != headword.lemmaClean) {
      rows.add(GrammarTableRow(
        label: 'Traditional Lemma',
        value: computed.lemmaTradClean(headword.lemma1),
      ));
    }
    
    // IPA row with audio buttons
    final ipa = computed.lemmaIpa(headword.lemmaClean);
    if (ipa.isNotEmpty) {
      rows.add(GrammarTableRow(
        label: 'IPA',
        value: Row(
          children: [
            Text('/$ipa/'),
            if (headword.audioMale1 != null) AudioButton(...),
            if (headword.audioMale2 != null) AudioButton(...),
            if (headword.audioFemale1 != null) AudioButton(...),
          ],
        ),
      ));
    }
    
    // Continue with all other fields...
    
    return Column(
      children: [
        Table(...), // Main table
        GrammarFooter(headword: headword), // Feedback link
      ],
    );
  }
}
```

### 4. Audio Service Placeholder
Create `lib/services/audio_service.dart`:

```dart
class AudioService {
  static Future<void> playAudio({
    required String headword,
    required String gender, // 'male1', 'male2', 'female1'
  }) async {
    // Placeholder - will integrate with external API
    // For now, log the intent
    print('Audio requested: $headword ($gender)');
    // TODO: Implement actual audio playback
  }
}

class AudioButton extends StatelessWidget {
  final String headword;
  final String gender;
  final String title;
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.play_arrow),
      onPressed: () => AudioService.playAudio(
        headword: headword,
        gender: gender,
      ),
      tooltip: title,
    );
  }
}
```

## Implementation Phases

### Phase 1: Database Schema & Core Data (Priority)
1. Add missing fields to `lib/database/tables.dart`
2. Update `lib/database/database.g.dart` (regenerate)
3. Create `lib/database/computed_fields.dart` with basic implementations
4. Update database queries to join with `DpdRoots` table

### Phase 2: Grammar Table UI
1. Create `lib/widgets/grammar_table.dart` matching webapp template
2. Implement conditional rendering for all fields
3. Add table styling to match webapp `.grammar` CSS class
4. Replace current `buildGrammarRows()` usage with new table

### Phase 3: Audio Integration
1. Investigate audio API endpoints from webapp
2. Implement `AudioService` with actual API calls
3. Add audio file caching
4. Test playback functionality

### Phase 4: Advanced Computations (Future)
1. IPA conversion (requires Python aksharamukha port or service)
2. Traditional lemma conversion (Python dependency)
3. Other Python-dependent calculations

## Webapp Template Field Mapping

Here's the exact field-by-field mapping from webapp template to Flutter implementation:

| Webapp Template Line | Field | Flutter Implementation | Status |
|---------------------|-------|----------------------|--------|
| 1002 | `{{d.i.lemma_clean}}` | `ComputedFields.lemmaClean(headword.lemma1)` | ✅ Regex-based |
| 1008 | `{{d.i.lemma_trad_clean}}` | `ComputedFields.lemmaTradClean(headword.lemma1)` | ⏳ Placeholder |
| 1015 | `{{d.i.lemma_ipa}}` | `ComputedFields.lemmaIpa(headword.lemmaClean)` | ⏳ Placeholder |
| 1017-1036 | Audio buttons | `AudioButton` widgets | ⏳ Placeholder |
| 1041 | `{{d.grammar}}` | `makeGrammarLine(headword)` from `meaning_construction.py` | ✅ Logic to port |
| 1047 | `{{d.i.family_root}}` | `headword.familyRoot` | ✅ Direct field |
| 1054-1055 | Root details | `headword.dpdRoot` relationship | ✅ Needs join |
| 1062 | `{{d.i.rt.root_in_comps}}` | `headword.dpdRoot?.rootInComps` | ✅ Needs join |
| 1068 | `{{d.i.root_base}}` | `headword.rootBase` | ✅ Direct field |
| 1073 | `{{d.i.construction|safe}}` | `headword.construction` (with cleaning) | ✅ Needs cleaning |
| 1080 | `{{d.i.derivative}} ({{d.i.suffix}})` | `headword.derivative + " (" + headword.suffix + ")"` | ✅ Direct fields |
| 1085 | `{{d.i.phonetic|safe}}` | `headword.phonetic` (new field) | ⏳ Needs DB add |
| 1092 | `{{d.i.compound_type}} ({{d.i.compound_construction|safe}})` | `headword.compoundType + " (" + headword.compoundConstruction + ")"` | ⏳ Needs DB add |
| 1097 | `{{d.i.antonym}}` | `headword.antonym` | ✅ Direct field |
| 1103 | `{{d.i.synonym}}` | `headword.synonym` | ✅ Direct field |
| 1108 | `{{d.i.variant}}` | `headword.variant` | ✅ Direct field |
| 1114 | `{{d.i.commentary|safe}}` | `headword.commentary` | ✅ Direct field |
| 1120 | `{{d.i.notes|safe}}` | `headword.notes` | ✅ Direct field |
| 1126 | `{{d.i.cognate}}` | `headword.cognate` (new field) | ⏳ Needs DB add |
| 1132-1138 | `{{d.i.link_list}}` | `headword.link` parsing (new field) | ⏳ Needs DB add |
| 1144 | `{{d.i.non_ia}}` | `headword.nonIa` (new field) | ⏳ Needs DB add |
| 1151 | `{{d.i.sanskrit}}` | `headword.sanskrit` | ✅ Direct field |
| 1160-1162 | Sanskrit root details | `headword.dpdRoot?.sanskritRoot` etc. | ✅ Needs join |

## Success Criteria

1. **Exact visual match** to webapp grammar tab
2. **All fields displayed** with same conditional logic
3. **Same ordering** as webapp template
4. **Audio buttons** functional (placeholders acceptable initially)
5. **Footer link** to Google Form matches webapp
6. **Table structure** identical (2-column table with th/td)

## Open Questions

1. **Audio API**: Need to investigate webapp audio endpoint URLs
2. **IPA Conversion**: Long-term solution needed for Python dependency
3. **Database Migration**: Strategy for adding fields to existing databases
4. **Performance**: Table rendering performance with many conditional checks

## Next Steps

1. **Approve this design**
2. **Begin Phase 1 implementation** (database schema + computed fields)
3. **Implement Phase 2** (UI table)
4. **Add Phase 3** (audio integration)
5. **Document Phase 4** (advanced computations) as future work

This design prioritizes architecture and structure over Python-dependent computations, using placeholders where needed to maintain momentum.