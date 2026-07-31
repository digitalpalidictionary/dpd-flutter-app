import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/database/sutta_info_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuttaInfoExtensions', () {
    test('scVaggaLink strips uppercase diacritics from generic vagga slugs', () {
      const suttaInfo = SuttaInfoData(
        dpdSutta: 'aggikhandhopamasutta',
        dpdCode: 'SN35.28-33',
        scCode: 'sn35.28',
        scVagga: '3. Ādittavagga',
      );

      expect(
        suttaInfo.scVaggaLink,
        'https://suttacentral.net/sn35-adittavagga',
      );
    });

    group('s4ntLink', () {
      test('DN/MN sutta -> exact page, no fragment', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'brahmajālasutta',
          scCode: 'DN1',
        );
        expect(
          suttaInfo.s4ntLink,
          'https://s.4nt.org/dn/dn1/index.html',
        );
      });

      test('bare nipāta-only AN code -> no fragment', () {
        const suttaInfo = SuttaInfoData(dpdSutta: 'ekakanipāta', scCode: 'AN1');
        expect(
          suttaInfo.s4ntLink,
          'https://s.4nt.org/an/an1/index.html',
        );
      });

      test('SN sutta code with default fragment', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'aggisutta',
          scCode: 'SN35.28',
        );
        expect(
          suttaInfo.s4ntLink,
          'https://s.4nt.org/sn/sn35/index.html#sn35.28',
        );
      });

      test('SN sutta code with an overridden fragment', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'phaggunapeyyālaṃ',
          scCode: 'SN12.93-103',
        );
        expect(
          suttaInfo.s4ntLink,
          'https://s.4nt.org/sn/sn12/index.html#sn12.93-213',
        );
      });

      test('KN book code with default fragment', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'appamādavaggo',
          scCode: 'DHP21-32',
        );
        expect(
          suttaInfo.s4ntLink,
          'https://s.4nt.org/kn/dhp/index.html#dhp21',
        );
      });

      test('unsupported book code -> null', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'pātimokkha',
          scCode: 'pli-tv-bu-vb-pj1',
        );
        expect(suttaInfo.s4ntLink, isNull);
      });

      test('no scCode -> null', () {
        const suttaInfo = SuttaInfoData(dpdSutta: 'something');
        expect(suttaInfo.s4ntLink, isNull);
      });
    });
  });
}
