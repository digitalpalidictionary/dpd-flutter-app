import 'package:dpd_flutter_app/providers/history_provider.dart';
import 'package:dpd_flutter_app/providers/search_provider.dart';
import 'package:dpd_flutter_app/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
  });

  test('records the first external search in history', () {
    container.read(externalSearchHandlerProvider).apply('dhamma');

    final history = container.read(historyProvider);
    expect(history.entries.map((e) => e.query).toList(), ['dhamma']);
    expect(history.currentIndex, 0);
  });

  test('stores display text separately from normalized lookup query', () {
    container.read(externalSearchHandlerProvider).apply(' धम्म ');

    expect(container.read(searchBarTextProvider), 'धम्म');
    expect(container.read(searchQueryProvider), 'dhamma');
    expect(
      container.read(historyProvider).entries.map((e) => e.query).toList(),
      ['dhamma'],
    );
  });

  test('deduplicates external searches through the shared history rule', () {
    container.read(externalSearchHandlerProvider).apply('dhamma');
    container.read(externalSearchHandlerProvider).apply('dhamma');

    expect(
      container.read(historyProvider).entries.map((e) => e.query).toList(),
      ['dhamma'],
    );
  });

  test('ignores empty external search queries for history', () {
    container.read(externalSearchHandlerProvider).apply('   ');

    expect(container.read(searchBarTextProvider), '');
    expect(container.read(searchQueryProvider), '');
    expect(container.read(historyProvider).entries, isEmpty);
  });
}
