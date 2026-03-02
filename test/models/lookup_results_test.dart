import 'dart:convert';

import 'package:dpd_flutter_app/models/lookup_results.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── DeconstructorResult ────────────────────────────────────────────────────

  group('DeconstructorResult.fromJson', () {
    test('parses list[str] JSON correctly', () {
      final json = jsonEncode(['ava + loketi', 'ava + loka + eti']);
      final result = DeconstructorResult.fromJson('avaloketi', json);
      expect(result, isNotNull);
      expect(result!.headword, 'avaloketi');
      expect(result.deconstructions, ['ava + loketi', 'ava + loka + eti']);
    });

    test('returns null for null input', () {
      expect(DeconstructorResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(DeconstructorResult.fromJson('test', ''), isNull);
    });

    test('parses single-element list', () {
      final json = jsonEncode(['ava + loketi']);
      final result = DeconstructorResult.fromJson('avaloketi', json);
      expect(result!.deconstructions.length, 1);
    });
  });

  // ── GrammarDictResult ──────────────────────────────────────────────────────

  group('GrammarDictResult.fromJson', () {
    test('parses list[list[str,str,str]] correctly', () {
      final json = jsonEncode([
        ['dhamma', 'masc', 'nom sg'],
        ['dhamma', 'masc', 'voc sg'],
      ]);
      final result = GrammarDictResult.fromJson('dhamma', json);
      expect(result, isNotNull);
      expect(result!.headword, 'dhamma');
      expect(result.entries.length, 2);
      expect(result.entries[0].headword, 'dhamma');
      expect(result.entries[0].pos, 'masc');
      expect(result.entries[0].components, hasLength(3));
      // 'nom sg' splits to ['nom', 'sg', '']
      expect(result.entries[0].components[0], 'nom');
      expect(result.entries[0].components[1], 'sg');
      expect(result.entries[0].components[2], '');
    });

    test('splits grammar_string into up to 3 components padded with empty', () {
      // grammar_string has 2 parts separated by spaces → padded to 3
      final json = jsonEncode([
        ['dhamma', 'masc', 'nom sg'],
      ]);
      final result = GrammarDictResult.fromJson('dhamma', json);
      expect(result!.entries[0].components, hasLength(3));
    });

    test('handles reflx prefix: first two words joined as one component', () {
      final json = jsonEncode([
        ['karoti', 'reflx', 'reflx nom sg'],
      ]);
      final result = GrammarDictResult.fromJson('karoti', json);
      expect(result!.entries[0].components[0], 'reflx nom');
      expect(result.entries[0].components[1], 'sg');
      expect(result.entries[0].components[2], '');
    });

    test('handles "in comps" as single component', () {
      final json = jsonEncode([
        ['dhamma', 'masc', 'in comps'],
      ]);
      final result = GrammarDictResult.fromJson('dhamma', json);
      expect(result!.entries[0].components[0], 'in comps');
      expect(result.entries[0].components[1], '');
      expect(result.entries[0].components[2], '');
    });

    test('returns null for null input', () {
      expect(GrammarDictResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(GrammarDictResult.fromJson('test', ''), isNull);
    });
  });

  // ── AbbreviationResult ─────────────────────────────────────────────────────

  group('AbbreviationResult.fromJson', () {
    test('parses dict with all optional fields', () {
      final json = jsonEncode({
        'meaning': 'adjective',
        'pāli': 'visesana',
        'example': 'loka',
        'explanation': 'describes a noun',
      });
      final result = AbbreviationResult.fromJson('adj', json);
      expect(result, isNotNull);
      expect(result!.headword, 'adj');
      expect(result.meaning, 'adjective');
      expect(result.pali, 'visesana');
      expect(result.example, 'loka');
      expect(result.explanation, 'describes a noun');
    });

    test('parses dict with only required meaning field', () {
      final json = jsonEncode({'meaning': 'adjective'});
      final result = AbbreviationResult.fromJson('adj', json);
      expect(result!.meaning, 'adjective');
      expect(result.pali, isNull);
      expect(result.example, isNull);
      expect(result.explanation, isNull);
    });

    test('returns null for null input', () {
      expect(AbbreviationResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(AbbreviationResult.fromJson('test', ''), isNull);
    });
  });

  // ── HelpResult ─────────────────────────────────────────────────────────────

  group('HelpResult.fromJson', () {
    test('parses JSON-encoded string (double-encoded)', () {
      // The DB stores a JSON-encoded string: json.dumps("Use the search bar...")
      final innerString = 'Use the search bar to look up words.';
      final json = jsonEncode(innerString); // produces '"Use the search bar..."'
      final result = HelpResult.fromJson('search', json);
      expect(result, isNotNull);
      expect(result!.headword, 'search');
      expect(result.helpText, innerString);
    });

    test('returns null for null input', () {
      expect(HelpResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(HelpResult.fromJson('test', ''), isNull);
    });
  });

  // ── EpdResult ──────────────────────────────────────────────────────────────

  group('EpdResult.fromJson', () {
    test('parses list[list[str,str,str]] tuples', () {
      final json = jsonEncode([
        ['dhamma', 'masc', 'truth, law'],
        ['dhamma', '', 'doctrine'],
      ]);
      final result = EpdResult.fromJson('dhamma', json);
      expect(result, isNotNull);
      expect(result!.headword, 'dhamma');
      expect(result.entries.length, 2);
      expect(result.entries[0].headword, 'dhamma');
      expect(result.entries[0].posInfo, 'masc');
      expect(result.entries[0].meaning, 'truth, law');
      expect(result.entries[1].posInfo, '');
    });

    test('returns null for null input', () {
      expect(EpdResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(EpdResult.fromJson('test', ''), isNull);
    });
  });

  // ── VariantResult ──────────────────────────────────────────────────────────

  group('VariantResult.fromJson', () {
    test('parses nested dict{corpus: {book: [[context, variant]]}} structure',
        () {
      final json = jsonEncode({
        'CST4': {
          'dn1': [
            ['context text here', 'variant reading'],
          ],
        },
        'BJT': {
          'dn1': [
            ['another context', 'bjt variant'],
          ],
        },
      });
      final result = VariantResult.fromJson('dhamma', json);
      expect(result, isNotNull);
      expect(result!.headword, 'dhamma');
      expect(result.variants.containsKey('CST4'), isTrue);
      expect(result.variants['CST4']!.containsKey('dn1'), isTrue);
      expect(result.variants['CST4']!['dn1']![0][0], 'context text here');
      expect(result.variants['CST4']!['dn1']![0][1], 'variant reading');
    });

    test('returns null for null input', () {
      expect(VariantResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(VariantResult.fromJson('test', ''), isNull);
    });
  });

  // ── SpellingResult ─────────────────────────────────────────────────────────

  group('SpellingResult.fromJson', () {
    test('parses list[str]', () {
      final json = jsonEncode(['dhamma', 'dhammo']);
      final result = SpellingResult.fromJson('dhama', json);
      expect(result, isNotNull);
      expect(result!.headword, 'dhama');
      expect(result.spellings, ['dhamma', 'dhammo']);
    });

    test('returns null for null input', () {
      expect(SpellingResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(SpellingResult.fromJson('test', ''), isNull);
    });
  });

  // ── SeeResult ──────────────────────────────────────────────────────────────

  group('SeeResult.fromJson', () {
    test('parses list[str]', () {
      final json = jsonEncode(['kamma', 'kamma 2']);
      final result = SeeResult.fromJson('karma', json);
      expect(result, isNotNull);
      expect(result!.headword, 'karma');
      expect(result.seeHeadwords, ['kamma', 'kamma 2']);
    });

    test('returns null for null input', () {
      expect(SeeResult.fromJson('test', null), isNull);
    });

    test('returns null for empty string', () {
      expect(SeeResult.fromJson('test', ''), isNull);
    });
  });
}
