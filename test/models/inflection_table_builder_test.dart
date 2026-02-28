import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/models/inflection_table_builder.dart';

// 3D array helpers: [row][col][cell_values]
String _encodeGrid(List<List<List<String>>> grid) => jsonEncode(grid);

// A minimal 2-column (sg/pl) grid for a masc-a noun.
// Row 0: headers. Rows 1+: case rows.
// Odd cols = endings, even cols > 0 = grammar tooltips.
final _aMascGrid = _encodeGrid([
  [
    [''],
    ['sg'],
    [''],
    ['pl'],
    [''],
  ],
  [
    ['nom'],
    ['o'],
    ['nom sg'],
    ['ā'],
    ['nom pl'],
  ],
  [
    ['acc'],
    ['aṃ'],
    ['acc sg'],
    ['e'],
    ['acc pl'],
  ],
]);

// A minimal verb grid for conjugation (pr = present tense).
final _prGrid = _encodeGrid([
  [
    [''],
    ['3rd sg'],
    [''],
    ['3rd pl'],
    [''],
  ],
  [
    ['act'],
    ['ti'],
    ['3 sg'],
    ['nti'],
    ['3 pl'],
  ],
]);

// Grid with multiple endings per cell.
final _multiEndingGrid = _encodeGrid([
  [
    [''],
    ['sg'],
    [''],
  ],
  [
    ['gen'],
    ['assa', 'no'],
    ['gen sg'],
  ],
]);

// Grid with an empty ending producing an empty cell.
final _emptyEndingGrid = _encodeGrid([
  [
    [''],
    ['sg'],
    [''],
  ],
  [
    ['voc'],
    [''],
    ['voc sg'],
  ],
]);

// Irregular grid — cell values are full forms (no stem prefix needed).
final _irregularGrid = _encodeGrid([
  [
    [''],
    ['sg'],
    [''],
  ],
  [
    ['nom'],
    ['atthi'],
    ['nom sg'],
  ],
]);

void main() {
  group('buildInflectionTable', () {
    test('standard a-masc declension returns Declension table', () {
      final result = buildInflectionTable(
        stem: 'dhamm',
        pattern: 'a masc',
        pos: 'masc',
        lemma1: 'dhamma 1',
        templateLike: 'buddha',
        templateData: _aMascGrid,
      );

      expect(result, isNotNull);
      expect(result!.buttonLabel, 'Declension');
      expect(result.headers, ['', 'sg', 'pl']);

      // nom row
      final nomRow = result.rows[0];
      expect(nomRow.$1, 'nom');
      final nomSg = nomRow.$2[0]; // sg cell
      expect(nomSg.forms.length, 1);
      expect(nomSg.forms.first.word, 'dhammo');
      expect(nomSg.grammarTooltip, 'nom sg');

      final nomPl = nomRow.$2[1]; // pl cell
      expect(nomPl.forms.first.word, 'dhammā');

      // heading contains pattern and like
      expect(result.headingText, contains('a masc'));
      expect(result.headingText, contains('buddha'));
    });

    test('conjugation (pr) returns Conjugation button label', () {
      final result = buildInflectionTable(
        stem: 'gaccha',
        pattern: 'pr',
        pos: 'pr',
        lemma1: 'gacchati',
        templateLike: 'gacchati',
        templateData: _prGrid,
      );

      expect(result, isNotNull);
      expect(result!.buttonLabel, 'Conjugation');
      final actRow = result.rows[0];
      expect(actRow.$2[0].forms.first.word, 'gacchati');
      expect(actRow.$2[1].forms.first.word, 'gacchanti');
    });

    test('irregular stem (*) uses template forms as-is', () {
      final result = buildInflectionTable(
        stem: '*',
        pattern: 'irreg',
        pos: 'masc',
        lemma1: 'atthi',
        templateLike: null,
        templateData: _irregularGrid,
      );

      expect(result, isNotNull);
      final nomRow = result!.rows[0];
      expect(nomRow.$2[0].forms.first.word, 'atthi');
      expect(nomRow.$2[0].forms.first.stem, '');
      expect(nomRow.$2[0].forms.first.ending, 'atthi');

      // heading mentions irregular
      expect(result.headingText.toLowerCase(), contains('irregular'));
    });

    test('already-inflected stem (!) strips marker and builds table', () {
      final result = buildInflectionTable(
        stem: '!dhamm',
        pattern: 'a masc',
        pos: 'masc',
        lemma1: 'dhamma 1',
        templateLike: 'buddha',
        templateData: _aMascGrid,
      );

      expect(result, isNotNull);
      final nomRow = result!.rows[0];
      expect(nomRow.$2[0].forms.first.word, 'dhammo');
    });

    test('indeclinable stem (-) returns null', () {
      final result = buildInflectionTable(
        stem: '-',
        pattern: 'ind',
        pos: 'ind',
        lemma1: 'ca',
        templateLike: null,
        templateData: _encodeGrid([
          [
            [''],
            ['ind'],
            [''],
          ],
          [
            ['ind'],
            [''],
            [''],
          ],
        ]),
      );

      expect(result, isNull);
    });

    test('multiple endings in one cell produce multiple forms', () {
      final result = buildInflectionTable(
        stem: 'dhamm',
        pattern: 'a masc',
        pos: 'masc',
        lemma1: 'dhamma 1',
        templateLike: 'buddha',
        templateData: _multiEndingGrid,
      );

      expect(result, isNotNull);
      final genRow = result!.rows[0];
      final genSg = genRow.$2[0];
      expect(genSg.forms.length, 2);
      expect(genSg.forms[0].word, 'dhammassa');
      expect(genSg.forms[1].word, 'dhammno');
    });

    test('empty ending produces empty cell', () {
      final result = buildInflectionTable(
        stem: 'dhamm',
        pattern: 'a masc',
        pos: 'masc',
        lemma1: 'dhamma 1',
        templateLike: 'buddha',
        templateData: _emptyEndingGrid,
      );

      expect(result, isNotNull);
      final vocRow = result!.rows[0];
      final vocSg = vocRow.$2[0];
      expect(vocSg.isEmpty, isTrue);
    });
  });
}
