import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/models/family_data.dart';

void main() {
  group('parseFamilyData', () {
    test('parses valid JSON with multiple entries', () {
      const json =
          '[["karoti","pr","to do","√"],["kāraka","masc","doer","✓"]]';
      final entries = parseFamilyData(json);
      expect(entries.length, 2);
      expect(entries[0].lemma, 'karoti');
      expect(entries[0].pos, 'pr');
      expect(entries[0].meaning, 'to do');
      expect(entries[0].completion, '√');
      expect(entries[1].lemma, 'kāraka');
      expect(entries[1].pos, 'masc');
    });

    test('parses single-entry JSON', () {
      const json = '[["dhamma","masc","truth","✓"]]';
      final entries = parseFamilyData(json);
      expect(entries.length, 1);
      expect(entries.first.lemma, 'dhamma');
      expect(entries.first.completion, '✓');
    });

    test('returns empty list for null input', () {
      final entries = parseFamilyData(null);
      expect(entries, isEmpty);
    });

    test('returns empty list for empty string', () {
      final entries = parseFamilyData('');
      expect(entries, isEmpty);
    });

    test('returns empty list for malformed JSON', () {
      final entries = parseFamilyData('not valid json {{{');
      expect(entries, isEmpty);
    });

    test('returns empty list for empty JSON array', () {
      final entries = parseFamilyData('[]');
      expect(entries, isEmpty);
    });

    test('parses entries with Pāḷi characters correctly', () {
      const json =
          '[["saṅkhāra","masc","formation","✓"],["viññāṇa","nt","consciousness","√"]]';
      final entries = parseFamilyData(json);
      expect(entries.length, 2);
      expect(entries[0].lemma, 'saṅkhāra');
      expect(entries[1].lemma, 'viññāṇa');
      expect(entries[1].pos, 'nt');
    });
  });
}
