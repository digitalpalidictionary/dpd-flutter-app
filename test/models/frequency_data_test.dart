import 'dart:convert';

import 'package:dpd_flutter_app/models/frequency_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FrequencyData.fromJson', () {
    test('parses valid JSON with all fields', () {
      final json = jsonEncode({
        'FreqHeading': 'Frequency of <b>dhamma</b> and its declensions',
        'CstFreq': List.filled(49, 1),
        'CstGrad': List.filled(49, 2),
        'BjtFreq': List.filled(39, 3),
        'BjtGrad': List.filled(39, 4),
        'SyaFreq': List.filled(30, 5),
        'SyaGrad': List.filled(30, 6),
        'ScFreq': List.filled(19, 7),
        'ScGrad': List.filled(19, 8),
      });

      final data = FrequencyData.fromJson(json);

      expect(data.freqHeading,
          'Frequency of <b>dhamma</b> and its declensions');
      expect(data.cstFreq.length, 49);
      expect(data.cstFreq[0], 1);
      expect(data.cstGrad.length, 49);
      expect(data.cstGrad[0], 2);
      expect(data.bjtFreq.length, 39);
      expect(data.bjtFreq[0], 3);
      expect(data.bjtGrad.length, 39);
      expect(data.bjtGrad[0], 4);
      expect(data.syaFreq.length, 30);
      expect(data.syaFreq[0], 5);
      expect(data.syaGrad.length, 30);
      expect(data.syaGrad[0], 6);
      expect(data.scFreq.length, 19);
      expect(data.scFreq[0], 7);
      expect(data.scGrad.length, 19);
      expect(data.scGrad[0], 8);
    });

    test('parses real "a 1.1" JSON data correctly', () {
      final json = jsonEncode({
        'FreqHeading': 'Frequency of <b>a 1.1</b> and its declensions',
        'CstFreq': [
          1, 2, 9, 21, 31, 4, 1, 0, 195, 23, 10, 55, 0, 6, 0, 26, 59, 0, 0,
          29, 0, 0, 0, 2, 92, 103, 53, 78, 414, 136, 254, 119, 99, 265, 314,
          191, 41, 128, 36, 154, 135, 119, 110, 0, 501, 0, 109, 2, 24,
        ],
        'CstGrad': [
          1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0,
          0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
          2, 0, 1, 1, 1,
        ],
        'BjtFreq': [
          0, 0, 0, 0, 0, 13, 0, 0, 4, 129, 220, 672, 6, 2, 0, 1, 243, 0, 0,
          215, 31, 4, 2, 5, 398, 498, 304, 391, 2128, 1057, 1486, 354, 215, 2,
          11, 39, 9, 8, 601,
        ],
        'BjtGrad': [
          0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 3, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1,
          1, 1, 1, 2, 1, 1, 10, 4, 7, 1, 1, 1, 1, 1, 1, 1, 2,
        ],
        'SyaFreq': [
          0, 0, 0, 0, 2, 0, 12, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 8, 4, 2,
          38, 95, 170, 27, 0, 0, 0, 2,
        ],
        'SyaGrad': [
          0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
          1, 1, 1, 1, 0, 0, 0, 1,
        ],
        'ScFreq': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        'ScGrad': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      });

      final data = FrequencyData.fromJson(json);

      expect(data.cstFreq.length, 49);
      expect(data.bjtFreq.length, 39);
      expect(data.syaFreq.length, 30);
      expect(data.scFreq.length, 19);
      expect(data.cstFreq[0], 1);
      expect(data.cstGrad[0], 1);
      expect(data.bjtFreq[28], 2128);
      expect(data.bjtGrad[28], 10);
      expect(data.isEmpty, false);
      expect(data.isNoExactMatches, false);
    });

    test('handles missing FreqHeading as empty string', () {
      final json = jsonEncode({
        'CstFreq': <int>[],
        'CstGrad': <int>[],
        'BjtFreq': <int>[],
        'BjtGrad': <int>[],
        'SyaFreq': <int>[],
        'SyaGrad': <int>[],
        'ScFreq': <int>[],
        'ScGrad': <int>[],
      });

      final data = FrequencyData.fromJson(json);
      expect(data.freqHeading, '');
      expect(data.isEmpty, true);
    });

    test('handles null array fields as empty lists', () {
      final json = jsonEncode({
        'FreqHeading': 'test',
      });

      final data = FrequencyData.fromJson(json);
      expect(data.cstFreq, isEmpty);
      expect(data.bjtGrad, isEmpty);
      expect(data.scFreq, isEmpty);
    });
  });

  group('FrequencyData.isNoExactMatches', () {
    test('returns true for no exact matches heading', () {
      final json = jsonEncode({
        'FreqHeading':
            'There are no exact matches of <b>xyz</b> in any texts.',
        'CstFreq': <int>[],
        'CstGrad': <int>[],
        'BjtFreq': <int>[],
        'BjtGrad': <int>[],
        'SyaFreq': <int>[],
        'SyaGrad': <int>[],
        'ScFreq': <int>[],
        'ScGrad': <int>[],
      });

      final data = FrequencyData.fromJson(json);
      expect(data.isNoExactMatches, true);
    });

    test('returns false for normal heading', () {
      final json = jsonEncode({
        'FreqHeading': 'Frequency of <b>dhamma</b> and its declensions',
        'CstFreq': <int>[],
        'CstGrad': <int>[],
        'BjtFreq': <int>[],
        'BjtGrad': <int>[],
        'SyaFreq': <int>[],
        'SyaGrad': <int>[],
        'ScFreq': <int>[],
        'ScGrad': <int>[],
      });

      final data = FrequencyData.fromJson(json);
      expect(data.isNoExactMatches, false);
    });
  });

  group('parseFrequencyData', () {
    test('returns null for null input', () {
      expect(parseFrequencyData(null), isNull);
    });

    test('returns null for empty string', () {
      expect(parseFrequencyData(''), isNull);
    });

    test('returns null for invalid JSON', () {
      expect(parseFrequencyData('not json'), isNull);
    });

    test('returns FrequencyData for valid JSON', () {
      final json = jsonEncode({
        'FreqHeading': 'test',
        'CstFreq': [1, 2, 3],
        'CstGrad': [1, 1, 1],
        'BjtFreq': <int>[],
        'BjtGrad': <int>[],
        'SyaFreq': <int>[],
        'SyaGrad': <int>[],
        'ScFreq': <int>[],
        'ScGrad': <int>[],
      });

      final result = parseFrequencyData(json);
      expect(result, isNotNull);
      expect(result!.freqHeading, 'test');
      expect(result.cstFreq, [1, 2, 3]);
    });
  });
}
