import 'package:flutter_test/flutter_test.dart';

import 'package:dpd_flutter_app/widgets/tap_search_wrapper.dart';

void main() {
  group('extractWordAt', () {
    const compound = 'Abhimaṅgala+sammata';
    final plusIndex = compound.indexOf('+');

    test('tapping the left half returns only the left half', () {
      expect(extractWordAt(compound, 0), 'Abhimaṅgala');
      expect(extractWordAt(compound, plusIndex - 1), 'Abhimaṅgala');
    });

    test('tapping the right half returns only the right half', () {
      expect(extractWordAt(compound, plusIndex + 1), 'sammata');
      expect(extractWordAt(compound, compound.length - 1), 'sammata');
    });

    test('tapping the plus itself falls back to the left half', () {
      expect(extractWordAt(compound, plusIndex), 'Abhimaṅgala');
    });

    test('spaced plus form still returns each word', () {
      const spaced = 'udaka + phāsukaṭṭhāna';
      expect(extractWordAt(spaced, 0), 'udaka');
      expect(extractWordAt(spaced, spaced.indexOf('phā')), 'phāsukaṭṭhāna');
      expect(extractWordAt(spaced, spaced.indexOf('+')), '');
    });

    test('multiple pluses split into separate parts', () {
      const triple = 'a+b+c';
      expect(extractWordAt(triple, 0), 'a');
      expect(extractWordAt(triple, 2), 'b');
      expect(extractWordAt(triple, 4), 'c');
    });

    test('a plain word is unaffected', () {
      expect(extractWordAt('dhamma', 3), 'dhamma');
    });

    test('a word inside a sentence is unaffected', () {
      const sentence = 'evaṃ me sutaṃ';
      expect(extractWordAt(sentence, 5), 'me');
    });

    test('out of range offsets return an empty string', () {
      expect(extractWordAt('dhamma', -1), '');
      expect(extractWordAt('dhamma', 6), '');
      expect(extractWordAt('', 0), '');
    });
  });
}
