import 'dart:convert';

import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/models/lookup_results.dart';
import 'package:dpd_flutter_app/providers/secondary_results_provider.dart';
import 'package:flutter_test/flutter_test.dart';

LookupData _row({
  String? abbrev,
  String? deconstructor,
  String? grammar,
  String? help,
  String? epd,
  String? variant,
  String? spelling,
  String? see,
}) {
  return LookupData(
    lookupKey: 'test',
    abbrev: abbrev,
    deconstructor: deconstructor,
    grammar: grammar,
    help: help,
    epd: epd,
    variant: variant,
    spelling: spelling,
    see: see,
  );
}

void main() {
  group('SecondaryResultsProvider.parse', () {
    test('populated columns produce correct list of typed results', () {
      final row = _row(
        abbrev: jsonEncode({'meaning': 'adjective'}),
        deconstructor: jsonEncode(['ava + loketi']),
        grammar: jsonEncode([
          ['dhamma', 'masc', 'nom sg'],
        ]),
        help: jsonEncode('Use the search bar.'),
        epd: jsonEncode([
          ['dhamma', 'masc', 'truth'],
        ]),
        variant: jsonEncode({
          'CST4': {
            'dn1': [
              ['context', 'variant'],
            ],
          },
        }),
        spelling: jsonEncode(['dhamma']),
        see: jsonEncode(['kamma']),
      );

      final results = SecondaryResultsProvider.parse('test', row);

      expect(results.length, 8);
      expect(results[0], isA<AbbreviationResult>());
      expect(results[1], isA<DeconstructorResult>());
      expect(results[2], isA<GrammarDictResult>());
      expect(results[3], isA<HelpResult>());
      expect(results[4], isA<EpdResult>());
      expect(results[5], isA<VariantResult>());
      expect(results[6], isA<SpellingResult>());
      expect(results[7], isA<SeeResult>());
    });

    test('all-empty secondary columns produce empty results list', () {
      final row = _row();
      final results = SecondaryResultsProvider.parse('test', row);
      expect(results, isEmpty);
    });

    test('result ordering matches: abbreviations → deconstructor → grammar → help → EPD → variant → spelling → see',
        () {
      final row = _row(
        see: jsonEncode(['kamma']),
        spelling: jsonEncode(['dhamma']),
        abbrev: jsonEncode({'meaning': 'adjective'}),
      );

      final results = SecondaryResultsProvider.parse('test', row);
      expect(results.length, 3);
      expect(results[0], isA<AbbreviationResult>());
      expect(results[1], isA<SpellingResult>());
      expect(results[2], isA<SeeResult>());
    });

    test('only non-null non-empty columns produce results', () {
      final row = _row(
        deconstructor: jsonEncode(['ava + loketi']),
        grammar: '',
        spelling: null,
      );

      final results = SecondaryResultsProvider.parse('test', row);
      expect(results.length, 1);
      expect(results[0], isA<DeconstructorResult>());
    });
  });
}
