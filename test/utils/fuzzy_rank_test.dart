import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/utils/fuzzy_rank.dart';

void main() {
  group('fuzzyCloseness', () {
    test('equal key and equal length scores 0', () {
      final score = fuzzyCloseness(
        query: 'rupam',
        queryFuzzyKey: 'rupam',
        candidate: 'rupam',
        candidateFuzzyKey: 'rupam',
      );
      expect(score, 0);
    });

    test('equal key with a longer candidate scores by length delta', () {
      final score = fuzzyCloseness(
        query: 'rupam',
        queryFuzzyKey: 'rupam',
        candidate: 'ruppam',
        candidateFuzzyKey: 'rupam',
      );
      expect(score, 1);
    });

    test('prefix-only match scores above every equal-key match', () {
      final equalKeyLongDelta = fuzzyCloseness(
        query: 'rupam',
        queryFuzzyKey: 'rupam',
        candidate: 'rupamrupamrupam',
        candidateFuzzyKey: 'rupam',
      );
      final prefixOnly = fuzzyCloseness(
        query: 'rupam',
        queryFuzzyKey: 'rupam',
        candidate: 'ruppamana',
        candidateFuzzyKey: 'rupamana',
      );
      expect(prefixOnly, greaterThan(equalKeyLongDelta));
    });

    test('delta clamps for an extreme length difference', () {
      final score = fuzzyCloseness(
        query: 'a',
        queryFuzzyKey: 'a',
        candidate: 'a' * 5000,
        candidateFuzzyKey: 'a',
      );
      expect(score, 999);
    });

    test('spec worked example: rūpaṃ vs ruppaṃ vs ruppamāna', () {
      const query = 'rupaṃ';
      const queryFuzzyKey = 'rupam';

      final rupa = fuzzyCloseness(
        query: query,
        queryFuzzyKey: queryFuzzyKey,
        candidate: 'rūpaṃ',
        candidateFuzzyKey: 'rupam',
      );
      final ruppa = fuzzyCloseness(
        query: query,
        queryFuzzyKey: queryFuzzyKey,
        candidate: 'ruppaṃ',
        candidateFuzzyKey: 'rupam',
      );
      final ruppamana = fuzzyCloseness(
        query: query,
        queryFuzzyKey: queryFuzzyKey,
        candidate: 'ruppamāna',
        candidateFuzzyKey: 'rupamana',
      );

      expect(rupa, 0);
      expect(ruppa, 1);
      expect(ruppamana, greaterThan(ruppa));
      expect(rupa, lessThan(ruppa));
      expect(ruppa, lessThan(ruppamana));
    });
  });
}
