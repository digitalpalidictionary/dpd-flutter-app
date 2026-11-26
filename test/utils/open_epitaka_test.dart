import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/utils/open_epitaka.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';

// A row copied from sutta_info in dpd.db.
const _an4126 = SuttaInfoData(
  dpdCode: 'AN4.126',
  dpdSutta: 'dutiyamettāsutta',
  dpdSuttaVar: '',
  scCode: 'AN4.126',
  cstVagga: '3. Bhayavaggo',
  scVagga: '13. Bhayavagga',
  bjtVagga: '2. kesivaggo',
);
const _sn1 = SuttaInfoData(
  dpdCode: 'SN1',
  dpdSutta: 'devatāsaṃyutta',
  dpdSuttaVar: '',
  scCode: 'SN1.1',
);

const _app = 'epitaka://sutta?code=an4.126';
const _web = 'https://epitaka.org/app/sutta?code=an4.126';

void main() {
  test('the app opens, and the web link stays unused', () async {
    final tried = <String>[];
    await openInEpitaka(
      _an4126,
      launch: (uri) async {
        tried.add(uri.toString());
        return true;
      },
    );
    expect(tried, [_app]);
  });

  test('with no app to take the link, the web link opens next', () async {
    final tried = <String>[];
    await openInEpitaka(
      _an4126,
      launch: (uri) async {
        tried.add(uri.toString());
        return false;
      },
    );
    expect(tried, [_app, _web]);
  });

  test('a system that throws for a missing app also falls back', () async {
    final tried = <String>[];
    await openInEpitaka(
      _an4126,
      launch: (uri) async {
        tried.add(uri.toString());
        if (uri.scheme == 'epitaka') {
          throw PlatformException(code: 'ACTIVITY_NOT_FOUND');
        }
        return true;
      },
    );
    expect(tried, [_app, _web]);
  });

  test('a group page opens nothing', () async {
    final tried = <String>[];
    await openInEpitaka(
      _sn1,
      launch: (uri) async {
        tried.add(uri.toString());
        return true;
      },
    );
    expect(tried, isEmpty);
  });
}
