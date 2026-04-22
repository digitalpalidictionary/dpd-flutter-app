import 'dart:convert';

import 'package:dpd_flutter_app/providers/history_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('HistoryNotifier', () {
    test('starts with empty recent and navigation state', () {
      final notifier = HistoryNotifier(prefs);

      expect(notifier.state.entries, isEmpty);
      expect(notifier.state.navigationEntries, isEmpty);
      expect(notifier.state.currentIndex, -1);
      expect(notifier.state.currentQuery, isNull);
    });

    test('navigateTo updates recency and appends navigation stack', () {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('dhamma');
      notifier.navigateTo('kamma');

      expect(
        notifier.state.entries.map((e) => e.query).toList(),
        ['kamma', 'dhamma'],
      );
      expect(notifier.state.navigationEntries, ['dhamma', 'kamma']);
      expect(notifier.state.currentIndex, 1);
      expect(notifier.state.currentQuery, 'kamma');
    });

    test('navigateTo deduplicates recent history but preserves navigation path', () {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('dhamma');
      notifier.navigateTo('kamma');
      notifier.navigateTo('dhamma');

      expect(
        notifier.state.entries.map((e) => e.query).toList(),
        ['dhamma', 'kamma'],
      );
      expect(notifier.state.navigationEntries, ['dhamma', 'kamma', 'dhamma']);
      expect(notifier.state.currentQuery, 'dhamma');
    });

    test('navigateTo prunes forward branch when branching from older entry', () {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('a');
      notifier.navigateTo('b');
      notifier.navigateTo('c');

      notifier.goBack();
      notifier.goBack();
      expect(notifier.state.currentQuery, 'a');
      expect(notifier.state.forwardQuery, 'b');

      notifier.navigateTo('d');

      expect(notifier.state.navigationEntries, ['a', 'd']);
      expect(notifier.state.currentQuery, 'd');
      expect(notifier.state.backQuery, 'a');
      expect(notifier.state.canGoForward, isFalse);
      expect(
        notifier.state.entries.map((e) => e.query).toList(),
        ['d', 'c', 'b', 'a'],
      );
    });

    test('goBack and goForward walk the navigation stack', () {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('a');
      notifier.navigateTo('b');
      notifier.navigateTo('c');

      expect(notifier.state.currentQuery, 'c');
      expect(notifier.state.backQuery, 'b');

      notifier.goBack();
      expect(notifier.state.currentQuery, 'b');
      expect(notifier.state.backQuery, 'a');
      expect(notifier.state.forwardQuery, 'c');

      notifier.goBack();
      expect(notifier.state.currentQuery, 'a');
      expect(notifier.state.canGoBack, isFalse);

      notifier.goForward();
      expect(notifier.state.currentQuery, 'b');
      expect(notifier.state.forwardQuery, 'c');
    });

    test('resetPosition leaves recent history intact and reopens latest navigation on back', () {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('a');
      notifier.navigateTo('b');
      notifier.resetPosition();

      expect(notifier.state.currentQuery, isNull);
      expect(notifier.state.canGoBack, isTrue);
      expect(notifier.state.canGoForward, isFalse);
      expect(notifier.state.backQuery, 'b');

      notifier.goBack();
      expect(notifier.state.currentQuery, 'b');
    });

    test('removeAt only removes recent history entries', () {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('a');
      notifier.navigateTo('b');
      notifier.navigateTo('c');
      notifier.removeAt(1);

      expect(
        notifier.state.entries.map((e) => e.query).toList(),
        ['c', 'a'],
      );
      expect(notifier.state.navigationEntries, ['a', 'b', 'c']);
      expect(notifier.state.currentQuery, 'c');
    });

    test('clear empties recent history without breaking session navigation', () {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('a');
      notifier.navigateTo('b');
      notifier.clear();

      expect(notifier.state.entries, isEmpty);
      expect(notifier.state.navigationEntries, ['a', 'b']);
      expect(notifier.state.currentQuery, 'b');

      notifier.goBack();
      expect(notifier.state.currentQuery, 'a');
    });

    test('navigateTo enforces max 50 entries for recent and navigation history', () {
      final notifier = HistoryNotifier(prefs);

      for (var i = 0; i < 55; i++) {
        notifier.navigateTo('term$i');
      }

      expect(notifier.state.entries.length, 50);
      expect(notifier.state.entries.first.query, 'term54');
      expect(notifier.state.navigationEntries.length, 50);
      expect(notifier.state.navigationEntries.first, 'term5');
      expect(notifier.state.navigationEntries.last, 'term54');
      expect(notifier.state.currentQuery, 'term54');
    });

    test('persists recent history to SharedPreferences', () async {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('dhamma');
      notifier.navigateTo('kamma');

      await Future<void>.delayed(Duration.zero);
      final stored = prefs.getString('dpd_history');
      expect(stored, isNotNull);
      final list = (jsonDecode(stored!) as List)
          .map((e) => e is String ? e : e['q'] as String)
          .toList();
      expect(list, ['kamma', 'dhamma']);
    });

    test('loads persisted recent history and navigation state', () async {
      await prefs.setString('dpd_history', jsonEncode(['kamma', 'dhamma']));
      await prefs.setString(
        'dpd_nav',
        jsonEncode(['dhamma', 'kamma']),
      );

      final notifier = HistoryNotifier(prefs);

      expect(
        notifier.state.entries.map((e) => e.query).toList(),
        ['kamma', 'dhamma'],
      );
      expect(notifier.state.navigationEntries, ['dhamma', 'kamma']);
      expect(notifier.state.currentIndex, 2);
      expect(notifier.state.currentQuery, isNull);
      expect(notifier.state.backQuery, 'kamma');
      expect(notifier.state.canGoBack, isTrue);
    });

    test('clear persists empty recent history', () async {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('a');
      notifier.clear();

      await Future<void>.delayed(Duration.zero);
      final stored = prefs.getString('dpd_history');
      expect(stored, isNotNull);
      final list = (jsonDecode(stored!) as List).cast<String>();
      expect(list, isEmpty);
    });

    test('resetPosition persists no-active-query sentinel across reload', () async {
      final notifier = HistoryNotifier(prefs);

      notifier.navigateTo('a');
      notifier.navigateTo('b');
      notifier.resetPosition();

      await Future<void>.delayed(Duration.zero);

      final restoredPrefs = await SharedPreferences.getInstance();
      final restored = HistoryNotifier(restoredPrefs);

      expect(restored.state.navigationEntries, ['a', 'b']);
      expect(restored.state.currentIndex, 2);
      expect(restored.state.currentQuery, isNull);
      expect(restored.state.backQuery, 'b');
      expect(restored.state.canGoBack, isTrue);
      expect(restored.state.canGoForward, isFalse);
    });
  });

  group('HistoryState', () {
    test('currentEntry returns null when there is no active navigation query', () {
      const state = HistoryState();
      expect(state.currentEntry, isNull);
    });

    test('currentEntry falls back to the active navigation query', () {
      final state = HistoryState(
        recentEntries: [
          HistoryEntry(query: 'a', timestamp: DateTime(2024)),
          HistoryEntry(query: 'c', timestamp: DateTime(2024, 1, 3)),
        ],
        navigationEntries: const ['a', 'b', 'c'],
        currentNavigationIndex: 1,
      );

      expect(state.currentEntry?.query, 'b');
      expect(state.currentQuery, 'b');
    });

    test('backQuery and forwardQuery reflect the navigation cursor', () {
      final state = HistoryState(
        recentEntries: [
          HistoryEntry(query: 'c', timestamp: DateTime(2024, 1, 3)),
          HistoryEntry(query: 'b', timestamp: DateTime(2024, 1, 2)),
          HistoryEntry(query: 'a', timestamp: DateTime(2024)),
        ],
        navigationEntries: const ['a', 'b', 'c'],
        currentNavigationIndex: 1,
      );

      expect(state.backQuery, 'a');
      expect(state.forwardQuery, 'c');
      expect(state.canGoBack, isTrue);
      expect(state.canGoForward, isTrue);
    });
  });
}
