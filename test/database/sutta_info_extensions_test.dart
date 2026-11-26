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

    group('dhammaGift', () {
      test('read link is the short lowercased path', () {
        const suttaInfo = SuttaInfoData(dpdSutta: 'aggisutta', scCode: 'SN35.28');
        expect(
          suttaInfo.dhammaGift,
          'https://dhamma.gift/sn35.28',
        );
      });

      test('range scCode keeps its hyphen', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'pasadabahulabrahmanavatthu',
          scCode: 'DHP383-423',
        );
        expect(
          suttaInfo.dhammaGift,
          'https://dhamma.gift/dhp383-423',
        );
      });

      test('no scCode -> null', () {
        const suttaInfo = SuttaInfoData(dpdSutta: 'something');
        expect(suttaInfo.dhammaGift, isNull);
      });

      // One live row carries an empty-string scCode rather than null.
      test('empty scCode -> null', () {
        const suttaInfo = SuttaInfoData(dpdSutta: 'something', scCode: '');
        expect(suttaInfo.dhammaGift, isNull);
      });
    });

    group('tbwLegacy', () {
      test('generic book link uses f.dhamma.gift host', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'aggisutta',
          scCode: 'SN35.28',
          bookCode: 'SN',
        );
        expect(
          suttaInfo.tbwLegacy,
          'https://f.dhamma.gift/bw/sn/sn35.28.html',
        );
      });

      test('iti book uses it/it.html page', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'it',
          scCode: 'iti1',
          bookCode: 'ITI',
        );
        expect(
          suttaInfo.tbwLegacy,
          'https://f.dhamma.gift/bw/it/it.html',
        );
      });

      test('unsupported book code -> null', () {
        const suttaInfo = SuttaInfoData(
          dpdSutta: 'pātimokkha',
          scCode: 'pli-tv-bu-vb-pj1',
          bookCode: 'VIN',
        );
        expect(suttaInfo.tbwLegacy, isNull);
      });

      test('no scCode -> null', () {
        const suttaInfo = SuttaInfoData(dpdSutta: 'something');
        expect(suttaInfo.tbwLegacy, isNull);
      });
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

    // Rows copied from sutta_info in dpd.db.
    group('ePitaka link', () {
      test('a sutta links by its SuttaCentral code, in lower case', () {
        const suttaInfo = SuttaInfoData(
          dpdCode: 'AN4.126',
          dpdSutta: 'dutiyamettāsutta',
          dpdSuttaVar: '',
          scCode: 'AN4.126',
          cstVagga: '3. Bhayavaggo',
          scVagga: '13. Bhayavagga',
          bjtVagga: '2. kesivaggo',
        );
        expect(suttaInfo.epitakaLink, 'epitaka://sutta?code=an4.126');
        expect(
          suttaInfo.epitakaWebLink,
          'https://epitaka.org/app/sutta?code=an4.126',
        );
      });

      test('the SuttaCentral code wins over the DPD code', () {
        const suttaInfo = SuttaInfoData(
          dpdCode: 'TH1',
          dpdSutta: 'subhūtittheragāthā',
          dpdSuttaVar: '',
          scCode: 'THAG1.1',
          cstVagga: '1. Paṭhamavaggo',
          scVagga: 'Ekakanipāta, Paṭhamavagga',
          bjtVagga: '4. mahāvaggo',
        );
        expect(suttaInfo.epitakaCode, 'thag1.1');
      });

      test('the DPD code is used when there is no SuttaCentral code', () {
        const suttaInfo = SuttaInfoData(
          dpdCode: 'SN46.36',
          dpdSutta: 'yonisomanasikārasutta',
          dpdSuttaVar: '',
          scCode: '',
          cstVagga: '4. Nīvaraṇavaggo',
        );
        expect(suttaInfo.epitakaCode, 'sn46.36');
      });

      test('a saṃyutta has no link', () {
        const suttaInfo = SuttaInfoData(
          dpdCode: 'SN1',
          dpdSutta: 'devatāsaṃyutta',
          dpdSuttaVar: '',
          scCode: 'SN1.1',
          cstVagga: '1. Naḷavaggo',
          scVagga: '1. Naḷavagga',
          bjtVagga: '1. naḷavaggo',
        );
        expect(suttaInfo.epitakaLink, isNull);
        expect(suttaInfo.epitakaWebLink, isNull);
      });

      test('a paṇṇāsaka has no link', () {
        const suttaInfo = SuttaInfoData(
          dpdCode: 'MN1-50',
          dpdSutta: 'mūlapaṇṇāsapāḷi',
          dpdSuttaVar: 'mūlapaṇṇāsaka 1',
          scCode: 'MN1',
          cstVagga: '1. Mūlapariyāyavaggo',
          scVagga: 'Mūlapariyāyavagga',
          bjtVagga: '1. mūlapariyāyavaggo',
        );
        expect(suttaInfo.isPannasaka, isTrue);
        expect(suttaInfo.epitakaLink, isNull);
      });
    });
  });
}
