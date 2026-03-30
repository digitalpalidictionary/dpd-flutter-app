import 'dart:async';

import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/providers/database_provider.dart';
import 'package:dpd_flutter_app/providers/dict_provider.dart';
import 'package:dpd_flutter_app/providers/settings_provider.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ThrowingDao extends DpdDao {
  _ThrowingDao(super.db);

  @override
  Future<List<DictMetaData>> getAllDictMeta() async {
    throw Exception('meta unavailable');
  }

  @override
  Future<DictMetaData?> getDictMeta(String dictId) async {
    throw Exception('css unavailable');
  }

  @override
  Future<List<DictEntry>> searchDictExact(String word) async {
    throw Exception('exact unavailable');
  }

  @override
  Future<List<DictEntry>> searchDictFuzzy(
    String fuzzyKey, {
    int limit = 50,
  }) async {
    throw Exception('fuzzy unavailable');
  }
}

DictMetaData _meta(String id, String name) {
  return DictMetaData(dictId: id, name: name);
}

DictEntry _entry({
  required int id,
  required String dictId,
  String word = 'buddha',
}) {
  return DictEntry(id: id, dictId: dictId, word: word);
}

DictRawSearchResults _raw({
  List<DictMetaData> meta = const [],
  List<DictEntry> exact = const [],
  List<DictEntry> fuzzy = const [],
}) {
  return DictRawSearchResults.fromRows(
    meta: meta,
    exactRows: exact,
    fuzzyRows: fuzzy,
  );
}

Future<DictSearchResults> _readPresentedResults(
  ProviderContainer container,
  String query,
) async {
  final current = container.read(dictResultsProvider(query));
  if (current.hasValue) return current.requireValue;

  final completer = Completer<DictSearchResults>();
  final sub = container.listen<AsyncValue<DictSearchResults>>(
    dictResultsProvider(query),
    (previous, next) {
      if (next.hasValue && !completer.isCompleted) {
        completer.complete(next.requireValue);
      }
    },
    fireImmediately: true,
  );

  final result = await completer.future;
  sub.close();
  return result;
}

void main() {
  late SharedPreferences prefs;
  late AppDatabase database;
  late DpdDao dao;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DpdDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DictVisibilityNotifier', () {
    test('loads persisted state and ignores corrupted prefs', () async {
      await prefs.setString(
        'dict_visibility',
        '{"order":["mw"],"enabled":["mw"]}',
      );
      final loaded = DictVisibilityNotifier(prefs);
      expect(loaded.state.order, ['mw']);
      expect(loaded.state.enabled, {'mw'});

      await prefs.setString('dict_visibility', '{not json');
      final corrupted = DictVisibilityNotifier(prefs);
      expect(corrupted.state.order, isEmpty);
      expect(corrupted.state.enabled, isEmpty);
    });

    test(
      'initFromMeta seeds initial order and appends new ids to existing state',
      () {
        final notifier = DictVisibilityNotifier(prefs);

        notifier.initFromMeta([_meta('cone', 'Cone'), _meta('mw', 'MW')]);
        expect(notifier.state.order, ['cone', 'mw']);
        expect(notifier.state.enabled, {'cone', 'mw'});

        notifier.toggleDict('mw', false);
        notifier.initFromMeta([
          _meta('cone', 'Cone'),
          _meta('mw', 'MW'),
          _meta('pts', 'PTS'),
        ]);

        expect(notifier.state.order, ['cone', 'mw', 'pts']);
        expect(notifier.state.enabled, {'cone', 'pts'});
      },
    );

    test('setOrder and toggleDict persist updated visibility', () async {
      final notifier = DictVisibilityNotifier(prefs);
      notifier.initFromMeta([_meta('cone', 'Cone'), _meta('mw', 'MW')]);

      await notifier.setOrder(['mw', 'cone']);
      await notifier.toggleDict('cone', false);

      expect(notifier.state.order, ['mw', 'cone']);
      expect(notifier.state.enabled, {'mw'});

      final reloaded = DictVisibilityNotifier(prefs);
      expect(reloaded.state.order, ['mw', 'cone']);
      expect(reloaded.state.enabled, {'mw'});
    });
  });

  group('raw and derived providers', () {
    test(
      'dictMetaAllProvider and dictCssProvider read metadata from dao',
      () async {
        await database
            .into(database.dictMeta)
            .insert(
              DictMetaCompanion.insert(
                dictId: 'cone',
                name: 'Cone',
                css: const Value('.cone {}'),
              ),
            );

        final container = ProviderContainer(
          overrides: [
            daoProvider.overrideWithValue(dao),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );
        addTearDown(container.dispose);

        final meta = await container.read(dictMetaAllProvider.future);
        final css = await container.read(dictCssProvider('cone').future);

        expect(meta.map((item) => item.dictId), ['cone']);
        expect(css, '.cone {}');
      },
    );

    test(
      'metadata and css providers degrade gracefully on dao errors',
      () async {
        final throwingDao = _ThrowingDao(database);
        final container = ProviderContainer(
          overrides: [daoProvider.overrideWithValue(throwingDao)],
        );
        addTearDown(container.dispose);

        final meta = await container.read(dictMetaAllProvider.future);
        final css = await container.read(dictCssProvider('cone').future);

        expect(meta, isEmpty);
        expect(css, isNull);
      },
    );

    test('dictResultsProvider groups rows and handles empty query', () async {
      await database
          .into(database.dictMeta)
          .insert(DictMetaCompanion.insert(dictId: 'cone', name: 'Cone'));
      await database
          .into(database.dictMeta)
          .insert(DictMetaCompanion.insert(dictId: 'mw', name: 'MW'));
      await database
          .into(database.dictEntries)
          .insert(
            DictEntriesCompanion.insert(
              id: const Value(1),
              dictId: 'cone',
              word: 'buddha',
              wordFuzzy: const Value('buddha'),
            ),
          );
      await database
          .into(database.dictEntries)
          .insert(
            DictEntriesCompanion.insert(
              id: const Value(2),
              dictId: 'mw',
              word: 'buddha',
              wordFuzzy: const Value('buddha'),
            ),
          );
      await database
          .into(database.dictEntries)
          .insert(
            DictEntriesCompanion.insert(
              id: const Value(3),
              dictId: 'cone',
              word: 'buddho',
              wordFuzzy: const Value('buddha'),
            ),
          );
      await database
          .into(database.dictEntries)
          .insert(
            DictEntriesCompanion.insert(
              id: const Value(2),
              dictId: 'mw',
              word: 'buddha',
              wordFuzzy: const Value('buddha'),
            ),
            mode: InsertMode.insertOrReplace,
          );

      final container = ProviderContainer(
        overrides: [
          daoProvider.overrideWithValue(dao),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      container.read(dictVisibilityProvider.notifier).initFromMeta([
        _meta('cone', 'Cone'),
        _meta('mw', 'MW'),
      ]);

      final empty = await _readPresentedResults(container, '');
      final presented = await _readPresentedResults(container, 'Buddha');

      expect(empty.exact, isEmpty);
      expect(presented.exact.map((item) => item.dictId), ['cone', 'mw']);
      expect(presented.exact.map((item) => item.dictName), ['Cone', 'MW']);
    });

    test('dictResultsProvider degrades gracefully on query failures', () async {
      final throwingDao = _ThrowingDao(database);
      final container = ProviderContainer(
        overrides: [
          daoProvider.overrideWithValue(throwingDao),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final presented = await _readPresentedResults(container, 'buddha');

      expect(presented.exact, isEmpty);
      expect(presented.fuzzy, isEmpty);
    });

    test(
      'dictResultsProvider reacts to visibility changes for already loaded results',
      () async {
        await database
            .into(database.dictMeta)
            .insert(DictMetaCompanion.insert(dictId: 'cone', name: 'Cone'));
        await database
            .into(database.dictMeta)
            .insert(DictMetaCompanion.insert(dictId: 'mw', name: 'MW'));
        await database
            .into(database.dictEntries)
            .insert(
              DictEntriesCompanion.insert(
                id: const Value(1),
                dictId: 'cone',
                word: 'buddha',
                wordFuzzy: const Value('buddha'),
              ),
            );
        await database
            .into(database.dictEntries)
            .insert(
              DictEntriesCompanion.insert(
                id: const Value(2),
                dictId: 'mw',
                word: 'buddha',
                wordFuzzy: const Value('buddha'),
              ),
            );

        final container = ProviderContainer(
          overrides: [
            daoProvider.overrideWithValue(dao),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );
        addTearDown(container.dispose);

        container.read(dictVisibilityProvider.notifier).initFromMeta([
          _meta('cone', 'Cone'),
          _meta('mw', 'MW'),
        ]);
        expect(
          (await _readPresentedResults(
            container,
            'buddha',
          )).exact.map((item) => item.dictId),
          ['cone', 'mw'],
        );

        await container.read(dictVisibilityProvider.notifier).setOrder([
          'mw',
          'cone',
        ]);
        expect(
          (await _readPresentedResults(
            container,
            'buddha',
          )).exact.map((item) => item.dictId),
          ['mw', 'cone'],
        );

        await container
            .read(dictVisibilityProvider.notifier)
            .toggleDict('mw', false);
        expect(
          (await _readPresentedResults(
            container,
            'buddha',
          )).exact.map((item) => item.dictId),
          ['cone'],
        );
      },
    );
  });

  group('presentDictSearchResults', () {
    test(
      'raw grouping excludes fuzzy rows already present in exact results',
      () {
        final raw = _raw(
          exact: [_entry(id: 1, dictId: 'cone')],
          fuzzy: [
            _entry(id: 1, dictId: 'cone', word: 'buddha'),
            _entry(id: 2, dictId: 'mw', word: 'buddhā'),
          ],
        );

        expect(raw.exact.keys, ['cone']);
        expect(raw.fuzzy.keys, ['mw']);
      },
    );

    test('reorder changes exact and fuzzy section order immediately', () {
      final raw = _raw(
        meta: [_meta('cone', 'Cone'), _meta('mw', 'MW')],
        exact: [
          _entry(id: 1, dictId: 'cone'),
          _entry(id: 2, dictId: 'mw'),
        ],
        fuzzy: [
          _entry(id: 3, dictId: 'cone', word: 'buddho'),
          _entry(id: 4, dictId: 'mw', word: 'buddhaka'),
        ],
      );

      final presented = presentDictSearchResults(
        raw,
        const DictVisibility(order: ['mw', 'cone'], enabled: {'cone', 'mw'}),
      );

      expect(presented.exact.map((result) => result.dictId), ['mw', 'cone']);
      expect(presented.fuzzy.map((result) => result.dictId), ['mw', 'cone']);
    });

    test('toggle off immediately removes current exact results', () {
      final raw = _raw(
        meta: [_meta('cone', 'Cone'), _meta('mw', 'MW')],
        exact: [
          _entry(id: 1, dictId: 'cone'),
          _entry(id: 2, dictId: 'mw'),
        ],
      );

      final presented = presentDictSearchResults(
        raw,
        const DictVisibility(order: ['cone', 'mw'], enabled: {'cone'}),
      );

      expect(presented.exact.map((result) => result.dictId), ['cone']);
    });

    test(
      'toggle on immediately restores current exact results when matches exist',
      () {
        final raw = _raw(
          meta: [_meta('cone', 'Cone'), _meta('mw', 'MW')],
          exact: [
            _entry(id: 1, dictId: 'cone'),
            _entry(id: 2, dictId: 'mw'),
          ],
        );

        final hidden = presentDictSearchResults(
          raw,
          const DictVisibility(order: ['cone', 'mw'], enabled: {'cone'}),
        );
        final restored = presentDictSearchResults(
          raw,
          const DictVisibility(order: ['cone', 'mw'], enabled: {'cone', 'mw'}),
        );

        expect(hidden.exact.map((result) => result.dictId), ['cone']);
        expect(restored.exact.map((result) => result.dictId), ['cone', 'mw']);
      },
    );

    test(
      'toggle and order changes apply to fuzzy results without affecting exact placement',
      () {
        final raw = _raw(
          meta: [_meta('cone', 'Cone'), _meta('mw', 'MW')],
          fuzzy: [
            _entry(id: 3, dictId: 'cone', word: 'buddho'),
            _entry(id: 4, dictId: 'mw', word: 'buddhaka'),
          ],
        );

        final presented = presentDictSearchResults(
          raw,
          const DictVisibility(order: ['mw', 'cone'], enabled: {'mw'}),
        );

        expect(presented.exact, isEmpty);
        expect(presented.fuzzy.map((result) => result.dictId), ['mw']);
      },
    );

    test(
      'disabled dictionaries stay absent from presented results while visibility state still tracks them',
      () {
        const visibility = DictVisibility(
          order: ['cone', 'mw'],
          enabled: {'cone'},
        );
        final raw = _raw(
          meta: [_meta('cone', 'Cone'), _meta('mw', 'MW')],
          exact: [
            _entry(id: 1, dictId: 'cone'),
            _entry(id: 2, dictId: 'mw'),
          ],
        );

        final presented = presentDictSearchResults(raw, visibility);

        expect(presented.exact.map((result) => result.dictId), ['cone']);
        expect(visibility.order, ['cone', 'mw']);
        expect(visibility.enabled, {'cone'});
      },
    );

    test('missing metadata degrades gracefully and falls back to dict ids', () {
      final raw = _raw(
        exact: [
          _entry(id: 1, dictId: 'cone'),
          _entry(id: 2, dictId: 'mw'),
        ],
      );

      final presented = presentDictSearchResults(
        raw,
        const DictVisibility(order: ['mw', 'cone'], enabled: {'cone', 'mw'}),
      );

      expect(presented.exact.map((result) => result.dictId), ['mw', 'cone']);
      expect(presented.exact.map((result) => result.dictName), ['mw', 'cone']);
      expect(presented.fuzzy, isEmpty);
    });
  });
}
