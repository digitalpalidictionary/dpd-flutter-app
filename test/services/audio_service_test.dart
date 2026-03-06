import 'package:flutter_test/flutter_test.dart';

import 'package:dpd_flutter_app/services/audio_service.dart';

void main() {
  group('AudioService.buildUrl', () {
    test('lemma without trailing digits builds correct URL', () {
      expect(
        AudioService.buildUrl('dhamma', 'male'),
        'https://dpdict.net/audio/dhamma?gender=male',
      );
    });

    test('lemma with trailing digit stripped', () {
      expect(
        AudioService.buildUrl('dhamma 1', 'female'),
        'https://dpdict.net/audio/dhamma?gender=female',
      );
    });

    test('lemma with trailing digit and suffix stripped', () {
      expect(
        AudioService.buildUrl('saṅgha 1.1', 'male1'),
        'https://dpdict.net/audio/sa%E1%B9%85gha?gender=male1',
      );
    });

    test('female1 gender maps correctly', () {
      expect(
        AudioService.buildUrl('dhamma', 'female1'),
        'https://dpdict.net/audio/dhamma?gender=female1',
      );
    });

    test('male2 gender maps correctly', () {
      expect(
        AudioService.buildUrl('nibbāna 2', 'male2'),
        'https://dpdict.net/audio/nibb%C4%81na?gender=male2',
      );
    });
  });
}
