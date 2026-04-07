import 'package:flutter_test/flutter_test.dart';

import 'package:dpd_flutter_app/utils/transliteration.dart';
import 'package:dpd_flutter_app/utils/velthuis.dart';

void main() {
  group('toRoman', () {
    setUpAll(() => initTransliteration());

    test('passes IAST through unchanged', () {
      expect(toRoman('rāga'), 'rāga');
      expect(toRoman('dhamma'), 'dhamma');
    });

    test('passes pure ASCII through unchanged', () {
      // Pure ASCII (no diacritics) is returned as-is — avoids misdetection as hk/velthuis
      expect(toRoman('Namo'), 'Namo');
      expect(toRoman('namo'), 'namo');
    });

    test('converts Devanagari to IAST', () {
      expect(toRoman('धम्म'), 'dhamma');
    });

    test('empty string returns empty', () {
      expect(toRoman(''), '');
    });
  });

  group('velthuis', () {
    test('converts long vowels', () {
      expect(velthuis('aa'), 'ā');
      expect(velthuis('ii'), 'ī');
      expect(velthuis('uu'), 'ū');
    });

    test('converts retroflex consonants', () {
      expect(velthuis('.t'), 'ṭ');
      expect(velthuis('.d'), 'ḍ');
      expect(velthuis('.n'), 'ṇ');
      expect(velthuis('.m'), 'ṃ');
      expect(velthuis('.l'), 'ḷ');
    });

    test('converts a full word', () {
      expect(velthuis('dhamma.m'), 'dhammaṃ');
      expect(velthuis('raaga'), 'rāga');
    });

    test('leaves already-iast text unchanged', () {
      expect(velthuis('rāga'), 'rāga');
    });

    test('empty string returns empty', () {
      expect(velthuis(''), '');
    });
  });
}
