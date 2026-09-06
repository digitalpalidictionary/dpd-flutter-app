import 'package:dpd_flutter_app/providers/citation_provider.dart';
import 'package:dpd_flutter_app/theme/dpd_scheme.dart';
import 'package:dpd_flutter_app/widgets/secondary/citation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Future<String?> Function(Ref) citation) {
  final palette = palettesFor(DpdScheme.nila).light;
  return ProviderScope(
    overrides: [citationProvider.overrideWith(citation)],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, extensions: [palette]),
      home: const Scaffold(body: CitationCard()),
    ),
  );
}

const _citation =
    'Bodhirasa Bhikkhu. Digital Pāḷi Dictionary. Version v0.4.20260906. '
    'https://www.dpdict.net/';

void main() {
  testWidgets('shows the citation stored in the database', (tester) async {
    await tester.pumpWidget(_wrap((_) async => _citation));
    await tester.pumpAndSettle();

    expect(find.text(_citation), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
  });

  testWidgets('falls back when the database has no citation', (tester) async {
    await tester.pumpWidget(_wrap((_) async => null));
    await tester.pumpAndSettle();

    expect(find.textContaining('citation is unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsNothing);
  });

  testWidgets('falls back when the lookup throws', (tester) async {
    await tester.pumpWidget(_wrap((_) async => throw Exception('no db')));
    await tester.pumpAndSettle();

    expect(find.textContaining('citation is unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsNothing);
  });
}
