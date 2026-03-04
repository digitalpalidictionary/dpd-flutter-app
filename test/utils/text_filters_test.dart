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
    test('returns text unchanged when mode is dot (ṃ)', () {
      expect(filterNiggahita('saṃsāra', mode: NiggahitaFilterMode.dot), 'saṃsāra');
    });

    test('substitutes ṃ with ṁ when mode is circle', () {
      expect(filterNiggahita('saṃsāra', mode: NiggahitaFilterMode.circle), 'saṁsāra');
    });

    test('substitutes all occurrences', () {
      expect(filterNiggahita('saṃsāraṃ', mode: NiggahitaFilterMode.circle), 'saṁsāraṁ');
    });

    test('handles uppercase Ṃ', () {
      expect(filterNiggahita('Ṃ', mode: NiggahitaFilterMode.circle), 'Ṁ');
    });

    test('returns empty string unchanged', () {
      expect(filterNiggahita('', mode: NiggahitaFilterMode.circle), '');
    });

    test('returns text without niggahita unchanged', () {
      expect(filterNiggahita('nibbāna', mode: NiggahitaFilterMode.circle), 'nibbāna');
    });
  });
}
