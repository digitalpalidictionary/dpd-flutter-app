import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/theme/dpd_scheme.dart';
import 'package:dpd_flutter_app/widgets/sutta_info_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Rows copied from sutta_info in dpd.db.
const _an4126 = SuttaInfoData(
  dpdCode: 'AN4.126',
  dpdSutta: 'dutiyamettāsutta',
  dpdSuttaVar: '',
  scCode: 'AN4.126',
  cstCode: 'AN4.3.3.6',
  cstVagga: '3. Bhayavaggo',
  scVagga: '13. Bhayavagga',
  bjtVagga: '2. kesivaggo',
);
const _sn1 = SuttaInfoData(
  dpdCode: 'SN1',
  dpdSutta: 'devatāsaṃyutta',
  dpdSuttaVar: '',
  scCode: 'SN1.1',
  cstCode: 'SN1.1.1.1',
  cstVagga: '1. Naḷavaggo',
  scVagga: '1. Naḷavagga',
  bjtVagga: '1. naḷavaggo',
);

Future<void> _pump(WidgetTester tester, SuttaInfoData info) =>
    tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: [palettesFor(DpdScheme.nila).light],
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SuttaInfoSection(
              suttaInfo: info,
              headwordId: 1,
              lemma1: 'x',
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('a sutta shows the ePitaka row, with text and not the URL', (
    tester,
  ) async {
    await _pump(tester, _an4126);
    expect(find.text('ePitaka'), findsOneWidget);
    expect(find.text('Open in ePitaka'), findsOneWidget);
    expect(find.textContaining('epitaka://'), findsNothing);
  });

  testWidgets('a group page shows no ePitaka row', (tester) async {
    await _pump(tester, _sn1);
    expect(find.text('Open in ePitaka'), findsNothing);
  });
}
