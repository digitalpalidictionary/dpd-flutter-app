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
    test('starts with empty state', () {
      final notifier = HistoryNotifier(prefs);
      expect(notifier.state.entries, isEmpty);
      expect(notifier.state.currentIndex, -1);
    });

    test('add inserts term at front', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('dhamma');
      notifier.add('kamma');
      expect(notifier.state.entries, ['kamma', 'dhamma']);
      expect(notifier.state.currentIndex, 0);
    });

    test('add deduplicates and moves to front', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('dhamma');
      notifier.add('kamma');
      notifier.add('dhamma');
      expect(notifier.state.entries, ['dhamma', 'kamma']);
      expect(notifier.state.currentIndex, 0);
    });

    test('add ignores empty string', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('');
      expect(notifier.state.entries, isEmpty);
    });

    test('add enforces max 50 entries', () {
      final notifier = HistoryNotifier(prefs);
      for (var i = 0; i < 55; i++) {
        notifier.add('term$i');
      }
      expect(notifier.state.entries.length, 50);
      expect(notifier.state.entries.first, 'term54');
    });

    test('goBack increments index', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('a');
      notifier.add('b');
      notifier.add('c');
      expect(notifier.state.currentIndex, 0);

      notifier.goBack();
      expect(notifier.state.currentIndex, 1);
      expect(notifier.state.currentEntry, 'b');

      notifier.goBack();
      expect(notifier.state.currentIndex, 2);
      expect(notifier.state.currentEntry, 'a');
    });

    test('goBack stops at end', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('a');
      notifier.add('b');

      notifier.goBack();
      notifier.goBack();
      expect(notifier.state.currentIndex, 1);
      expect(notifier.state.canGoBack, false);
    });

    test('goForward decrements index', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('a');
      notifier.add('b');
      notifier.add('c');

      notifier.goBack();
      notifier.goBack();
      expect(notifier.state.currentIndex, 2);

      notifier.goForward();
      expect(notifier.state.currentIndex, 1);
      expect(notifier.state.currentEntry, 'b');
    });

    test('goForward stops at index 0', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('a');
      notifier.add('b');

      notifier.goForward();
      expect(notifier.state.currentIndex, 0);
      expect(notifier.state.canGoForward, false);
    });

    test('clear resets state', () {
      final notifier = HistoryNotifier(prefs);
      notifier.add('a');
      notifier.add('b');
      notifier.clear();
      expect(notifier.state.entries, isEmpty);
      expect(notifier.state.currentIndex, -1);
    });

    test('persists to SharedPreferences', () async {
      final notifier = HistoryNotifier(prefs);
      notifier.add('dhamma');
      notifier.add('kamma');

      await Future<void>.delayed(Duration.zero);
      final stored = prefs.getString('dpd_history');
      expect(stored, isNotNull);
      final list = (jsonDecode(stored!) as List).cast<String>();
      expect(list, ['kamma', 'dhamma']);
    });

    test('loads from SharedPreferences', () async {
      await prefs.setString(
        'dpd_history',
        jsonEncode(['kamma', 'dhamma']),
      );
      final notifier = HistoryNotifier(prefs);
      expect(notifier.state.entries, ['kamma', 'dhamma']);
      expect(notifier.state.currentIndex, -1);
    });

    test('clear persists empty state', () async {
      final notifier = HistoryNotifier(prefs);
      notifier.add('a');
      notifier.clear();

      await Future<void>.delayed(Duration.zero);
      final stored = prefs.getString('dpd_history');
      expect(stored, isNotNull);
      final list = (jsonDecode(stored!) as List).cast<String>();
      expect(list, isEmpty);
    });
  });

  group('HistoryState', () {
    test('currentEntry returns null when index is -1', () {
      const state = HistoryState();
      expect(state.currentEntry, isNull);
    });

    test('currentEntry returns correct entry', () {
      const state = HistoryState(
        entries: [
          HistoryEntry(query: 'a'),
          HistoryEntry(query: 'b'),
          HistoryEntry(query: 'c'),
        ],
        currentIndex: 1,
      );
      expect(state.currentEntry?.query, 'b');
    });

    test('canGoBack is false for empty entries', () {
      const state = HistoryState();
      expect(state.canGoBack, false);
    });

    test('canGoForward is false at index 0', () {
      const state = HistoryState(
        entries: [HistoryEntry(query: 'a')],
        currentIndex: 0,
      );
      expect(state.canGoForward, false);
    });
  });
}
