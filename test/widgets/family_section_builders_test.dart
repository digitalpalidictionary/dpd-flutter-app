import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/widgets/family_section_builders.dart';

FamilyRootData _rootFamily(int count) => FamilyRootData(
  rootFamilyKey: '√kar 1 √kar',
  rootKey: '√kar 1',
  rootFamily: '√kar',
  rootMeaning: 'do',
  html: '',
  data: '[]',
  count: count,
);

Future<String> _rootHeaderText(WidgetTester tester, int count) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) =>
              buildRootFamilyHeader(context, _rootFamily(count)),
        ),
      ),
    ),
  );
  final rich = tester.widget<Text>(find.byType(Text));
  return rich.textSpan!.toPlainText();
}

void main() {
  group('buildRootFamilyHeader', () {
    testWidgets('one member is singular', (tester) async {
      expect(
        await _rootHeaderText(tester, 1),
        contains('1 word belongs to the root family '),
      );
    });

    testWidgets('many members is plural', (tester) async {
      expect(
        await _rootHeaderText(tester, 5),
        contains('5 words belong to the root family '),
      );
    });
  });
}
