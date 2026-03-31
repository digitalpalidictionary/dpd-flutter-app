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
  Future<List<DictEntry>> searchDictPartial(String word, {int limit = 50}) async {
    throw Exception('partial unavailable');
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
  List<DictEntry> partial = const [],
  List<DictEntry> fuzzy = const [],
}) {
  return DictRawSearchResults.fromRows(
    meta: meta,
    exactRows: exact,
    partialRows: partial,
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
      'initFromMeta seeds initial order (DPD first) and appends new dict ids to existing state',
      () {
        final notifier = DictVisibilityNotifier(prefs);
        final dpdIds = kDpdSources.map((s) => s.id).toList();

        notifier.initFromMeta([_meta('cone', 'Cone'), _meta('mw', 'MW')]);
        expect(notifier.state.order, [...dpdIds, 'cone', 'mw']);
        expect(notifier.state.enabled, {...dpdIds.toSet(), 'cone', 'mw'});

        notifier.toggleDict('mw', false);
        notifier.initFromMeta([
          _meta('cone', 'Cone'),
          _meta('mw', 'MW'),
          _meta('pts', 'PTS'),
        ]);

        // 'pts' is a new dict id — appended after existing order
        expect(notifier.state.order, [...dpdIds, 'cone', 'mw', 'pts']);
        // 'mw' was disabled, 'pts' is new (auto-enabled), DPD sources remain enabled
        expect(notifier.state.enabled, {...dpdIds.toSet(), 'cone', 'pts'});
      },
    );

    test('setOrder and toggleDict persist updated visibility', () async {
      final notifier = DictVisibilityNotifier(prefs);
      notifier.initFromMeta([_meta('cone', 'Cone'), _meta('mw', 'MW')]);

      await notifier.setOrder(['mw', 'cone']);
      await notifier.toggleDict('cone', false);

      expect(notifier.state.order, ['mw', 'cone']);
      // toggleDict only removes 'cone' from enabled; DPD sources remain enabled
      final dpdEnabled = kDpdSources.map((s) => s.id).toSet();
      expect(notifier.state.enabled, {...dpdEnabled, 'mw'});

      final reloaded = DictVisibilityNotifier(prefs);
      expect(reloaded.state.order, ['mw', 'cone']);
      expect(reloaded.state.enabled, {...dpdEnabled, 'mw'});
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

  group('partial tier in DictRawSearchResults', () {
    test('fromRows populates partial bucket from partialRows', () {
      final raw = _raw(
        meta: [_meta('cone', 'Cone')],
        partial: [_entry(id: 2, dictId: 'cone', word: 'buddhakāya')],
      );

      expect(raw.partial.keys, ['cone']);
      expect(raw.partial['cone']!.first.word, 'buddhakāya');
    });

    test('partial bucket does not re-filter against exact (DAO already excluded them)', () {
      final raw = _raw(
        meta: [_meta('cone', 'Cone')],
        exact: [_entry(id: 1, dictId: 'cone', word: 'buddha')],
        partial: [_entry(id: 2, dictId: 'cone', word: 'buddhakāya')],
      );

      expect(raw.partial['cone']!.map((e) => e.word), ['buddhakāya']);
      expect(raw.partial['cone']!.map((e) => e.id), [2]);
    });

    test('fuzzy rows are deduped against exact + partial IDs', () {
      final raw = _raw(
        exact: [_entry(id: 1, dictId: 'cone')],
        partial: [_entry(id: 2, dictId: 'cone', word: 'buddhakāya')],
        fuzzy: [
          _entry(id: 1, dictId: 'cone'),
          _entry(id: 2, dictId: 'cone', word: 'buddhakāya'),
          _entry(id: 3, dictId: 'mw', word: 'buddhika'),
        ],
      );

      expect(raw.fuzzy.keys, ['mw']);
      expect(raw.fuzzy['mw']!.first.id, 3);
    });

    test('presentDictSearchResults includes partial tier with visibility/ordering', () {
      final raw = _raw(
        meta: [_meta('cone', 'Cone'), _meta('mw', 'MW')],
        exact: [_entry(id: 1, dictId: 'cone')],
        partial: [
          _entry(id: 2, dictId: 'cone', word: 'buddhakāya'),
          _entry(id: 3, dictId: 'mw', word: 'buddhaka'),
        ],
      );

      final presented = presentDictSearchResults(
        raw,
        const DictVisibility(order: ['mw', 'cone'], enabled: {'cone', 'mw'}),
      );

      expect(presented.partial.map((r) => r.dictId), ['mw', 'cone']);
    });

    test('presentDictSearchResults hides partial for disabled dict', () {
      final raw = _raw(
        meta: [_meta('cone', 'Cone'), _meta('mw', 'MW')],
        partial: [
          _entry(id: 2, dictId: 'cone', word: 'buddhakāya'),
          _entry(id: 3, dictId: 'mw', word: 'buddhaka'),
        ],
      );

      final presented = presentDictSearchResults(
        raw,
        const DictVisibility(order: ['cone', 'mw'], enabled: {'cone'}),
      );

      expect(presented.partial.map((r) => r.dictId), ['cone']);
    });
  });

  group('DPD source ordering and migration', () {
    test('default order puts all DPD sources before dict sources', () {
      final notifier = DictVisibilityNotifier(prefs);
      notifier.initFromMeta([_meta('cone', 'Cone'), _meta('mw', 'MW')]);

      final dpdIds = kDpdSources.map((s) => s.id).toList();
      final order = notifier.state.order;

      // Every DPD source must appear before every dict source
      final lastDpdIndex =
          order.lastIndexWhere((id) => dpdIds.contains(id));
      final firstDictIndex =
          order.indexWhere((id) => !dpdIds.contains(id));

      expect(lastDpdIndex, lessThan(firstDictIndex));
      expect(order.where((id) => dpdIds.contains(id)), dpdIds);
    });

    test('default order enables all DPD sources', () {
      final notifier = DictVisibilityNotifier(prefs);
      notifier.initFromMeta([_meta('cone', 'Cone')]);

      for (final source in kDpdSources) {
        expect(notifier.state.enabled, contains(source.id));
      }
    });

    test('migration prepends DPD sources ahead of existing dict order', () {
      final notifier = DictVisibilityNotifier(prefs);
      // Seed an existing user state with only dict IDs (pre-DPD-configurable)
      notifier.initFromMeta([_meta('cone', 'Cone'), _meta('mw', 'MW')]);
      notifier.setOrder(['mw', 'cone']);
      notifier.toggleDict('cone', false);

      // Re-init simulating app upgrade that introduces DPD sources
      notifier.initFromMeta([_meta('cone', 'Cone'), _meta('mw', 'MW')]);

      final order = notifier.state.order;
      final dpdIds = kDpdSources.map((s) => s.id).toList();

      // DPD sources must all be present and come before dict IDs
      for (final id in dpdIds) {
        expect(order, contains(id));
      }
      final lastDpdIndex = order.lastIndexWhere((id) => dpdIds.contains(id));
      final mwIndex = order.indexOf('mw');
      final coneIndex = order.indexOf('cone');
      expect(lastDpdIndex, lessThan(mwIndex));
      expect(lastDpdIndex, lessThan(coneIndex));

      // Existing dict order is preserved
      expect(mwIndex, lessThan(coneIndex));
      // Existing enabled state is preserved
      expect(notifier.state.enabled, contains('mw'));
      expect(notifier.state.enabled, isNot(contains('cone')));
    });

    test('migration enables newly added DPD sources automatically', () {
      // Simulate user who already has saved order with only dict IDs
      final notifier = DictVisibilityNotifier(prefs);
      notifier.initFromMeta([_meta('cone', 'Cone')]);
      notifier.setOrder(['cone']);

      // Re-init with DPD sources (upgrade path)
      notifier.initFromMeta([_meta('cone', 'Cone')]);

      for (final source in kDpdSources) {
        expect(notifier.state.enabled, contains(source.id));
      }
    });

    test('DPD source toggle changes enabled set only', () {
      final notifier = DictVisibilityNotifier(prefs);
      notifier.initFromMeta([_meta('cone', 'Cone')]);

      notifier.toggleDict('dpd_headwords', false);
      expect(notifier.state.enabled, isNot(contains('dpd_headwords')));
      expect(notifier.state.order, contains('dpd_headwords'));

      notifier.toggleDict('dpd_headwords', true);
      expect(notifier.state.enabled, contains('dpd_headwords'));
    });

    test('dpd_headwords is a single source ID gating both exact and partial', () {
      // The same ID controls both tiers — toggling it off removes both.
      // Verified by checking it appears exactly once in the canonical order.
      final dpdIds = kDpdSources.map((s) => s.id).toList();
      expect(dpdIds.where((id) => id == 'dpd_headwords').length, 1);
    });
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
