import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/utils/text_filters.dart';

void main() {
  group('filterApostrophe', () {
    test('returns text unchanged when show is true', () {
      expect(filterApostrophe("mahā'pi", show: true), "mahā'pi");
    });

    test('removes apostrophes when show is false', () {
      expect(filterApostrophe("mahā'pi", show: false), 'mahāpi');
    });

    test('removes multiple apostrophes when show is false', () {
      expect(filterApostrophe("y'eva mahā'pi", show: false), 'yeva mahāpi');
    });

    test('returns empty string unchanged', () {
      expect(filterApostrophe('', show: false), '');
      expect(filterApostrophe('', show: true), '');
    });

    test('returns text with no apostrophes unchanged', () {
      expect(filterApostrophe('nibbāna', show: false), 'nibbāna');
    });
  });

  group('filterNiggahita', () {
    test('returns text unchanged when circle is false (ṃ)', () {
      expect(filterNiggahita('saṃsāra', circle: false), 'saṃsāra');
    });

    test('substitutes ṃ with ṁ when circle is true', () {
      expect(filterNiggahita('saṃsāra', circle: true), 'saṁsāra');
    });

    test('substitutes all occurrences', () {
      expect(filterNiggahita('saṃsāraṃ', circle: true), 'saṁsāraṁ');
    });

    test('handles uppercase Ṃ', () {
      expect(filterNiggahita('Ṃ', circle: true), 'Ṁ');
    });

    test('returns empty string unchanged', () {
      expect(filterNiggahita('', circle: true), '');
    });

    test('returns text without niggahita unchanged', () {
      expect(filterNiggahita('nibbāna', circle: true), 'nibbāna');
    });

    test('leaves an already-circle ṁ untouched in both modes', () {
      expect(filterNiggahita('saṁsāra', circle: true), 'saṁsāra');
      expect(filterNiggahita('saṁsāra', circle: false), 'saṁsāra');
    });
  });

  group('canonicalNiggahita', () {
    test('folds ṁ back to ṃ', () {
      expect(canonicalNiggahita('saṁsāra'), 'saṃsāra');
    });

    test('folds uppercase Ṁ back to Ṃ', () {
      expect(canonicalNiggahita('Ṁ'), 'Ṃ');
    });

    test('leaves canonical text unchanged', () {
      expect(canonicalNiggahita('saṃsāra'), 'saṃsāra');
      expect(canonicalNiggahita('nibbāna'), 'nibbāna');
      expect(canonicalNiggahita(''), '');
    });

    test('round-trips with filterNiggahita', () {
      const canonical = 'saṃsāraṃ Ṃ';
      expect(
        canonicalNiggahita(filterNiggahita(canonical, circle: true)),
        canonical,
      );
    });
  });
}
