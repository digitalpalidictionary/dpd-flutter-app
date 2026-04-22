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
  });
}
