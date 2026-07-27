import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/utils/diacritics.dart';

/// The expectations below are the exact `word_fuzzy` values stored in the
/// shipped mobile database, which the Python exporter generates by dropping
/// every Unicode combining mark. If `stripDiacritics` stops reproducing them,
/// exact dictionary lookups silently return nothing for the affected words.
void main() {
  group('stripDiacritics matches the exporter', () {
    test('folds Pāḷi diacritics', () {
      expect(stripDiacritics('anāthapiṇḍika'), 'anatapindika');
      expect(stripDiacritics('ānanda'), 'ananda');
      expect(stripDiacritics('ñāṇamoli'), 'nanamoli');
      expect(stripDiacritics('saṃyutta'), 'samyuta');
    });

    test('folds Sanskrit diacritics', () {
      // These regressed once: ś, ṣ and ṛ were absent from the map, so a
      // quarter of Apte and a third of Monier-Williams could not be matched.
      expect(stripDiacritics('aṃśa'), 'amsa');
      expect(stripDiacritics('ṛṣi'), 'rsi');
      expect(stripDiacritics('akaniṣṭha'), 'akanista');
      expect(stripDiacritics('aikṣava'), 'aiksava');
      expect(stripDiacritics('ṝ'), 'r');
      expect(stripDiacritics('ḹ'), 'l');
    });

    test('folds stray European diacritics found in the source data', () {
      expect(stripDiacritics('ç'), 'c');
      expect(stripDiacritics('â'), 'a');
      expect(stripDiacritics('ö'), 'o');
      expect(stripDiacritics('ü'), 'u');
      expect(stripDiacritics('ň'), 'n');
      expect(stripDiacritics('ĩ'), 'i');
    });

    test('drops combining marks, including decomposed input', () {
      // Precomposed and decomposed spellings must fold identically.
      expect(stripDiacritics('ă'), 'a'); // combining breve
      expect(stripDiacritics('ā'), stripDiacritics('ā'));
      expect(stripDiacritics('ṅ'), stripDiacritics('ṅ'));
    });

    test('collapses aspirates and doubled consonants', () {
      expect(stripDiacritics('buddha'), 'buda');
      expect(stripDiacritics('dhamma'), 'dama');
      expect(stripDiacritics('khaṇḍa'), 'kanda');
    });

    test('strips root markers and spaces', () {
      expect(stripDiacritics('√gam'), 'gam');
      expect(stripDiacritics('akaniṭṭhā devā'), 'akanitadeva');
    });

    test('leaves plain ASCII untouched', () {
      expect(stripDiacritics('tissa'), 'tisa');
      expect(stripDiacritics('a'), 'a');
      expect(stripDiacritics(''), '');
    });
  });
}
