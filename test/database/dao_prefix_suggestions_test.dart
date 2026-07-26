import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';

void main() {
  late AppDatabase db;
  late DpdDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DpdDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertLookup(String key, {String headwords = ''}) async {
    await db
        .into(db.lookup)
        .insert(LookupData(lookupKey: key, headwords: headwords));
  }

  Future<void> insertDictEntry({
    required int id,
    required String dictId,
    required String word,
  }) async {
    await db
        .into(db.dictEntries)
        .insert(DictEntriesCompanion.insert(id: Value(id), dictId: dictId, word: word));
  }

  group('searchLookupKeysPrefix', () {
    test('returns an inflected form the headword index lacks', () async {
      await insertLookup('akakkasacittassa', headwords: '[1]');

      final results = await dao.searchLookupKeysPrefix('akakkasacitt');

      expect(results, contains('akakkasacittassa'));
    });

    test('returns an EPD English key', () async {
      await insertLookup('generosity');

      final results = await dao.searchLookupKeysPrefix('generos');

      expect(results, contains('generosity'));
    });

    test('does not fold diacritics: kamma does not return kammā', () async {
      await insertLookup('kammā');

      final results = await dao.searchLookupKeysPrefix('kamma');

      expect(results, isNot(contains('kammā')));
    });

    test('does not collapse double consonants: kama does not return kamma', () async {
      await insertLookup('kamma');

      final results = await dao.searchLookupKeysPrefix('kama');

      expect(results, isNot(contains('kamma')));
    });

    test('includes the exact query itself', () async {
      await insertLookup('kamma');

      final results = await dao.searchLookupKeysPrefix('kamma');

      expect(results, contains('kamma'));
    });

    test('returns empty for a nonsense prefix', () async {
      await insertLookup('kamma');

      final results = await dao.searchLookupKeysPrefix('zzzqq');

      expect(results, isEmpty);
    });

    test('a lowercased sutta code query finds the uppercase key', () async {
      await insertLookup('DN1.1');

      final results = await dao.searchLookupKeysPrefix('dn1.1');

      expect(results, contains('DN1.1'));
    });

    test('a query with no digit does not widen to an uppercase range', () async {
      await insertLookup('AN');
      await insertLookup('an');

      final results = await dao.searchLookupKeysPrefix('an');

      expect(results, contains('an'));
      expect(results, isNot(contains('AN')));
    });

    test('respects the limit parameter', () async {
      for (var i = 0; i < 20; i++) {
        await insertLookup('buddha${i.toString().padLeft(2, '0')}');
      }

      final results = await dao.searchLookupKeysPrefix('buddha', limit: 5);

      expect(results.length, 5);
    });
  });

  group('searchDictWordsPrefix', () {
    test('returns words from a named dictionary', () async {
      await insertDictEntry(id: 1, dictId: 'mw', word: 'karma');

      final results = await dao.searchDictWordsPrefix(['mw'], 'karm');

      expect(results, contains('karma'));
    });

    test('a dictionary not passed in contributes nothing', () async {
      await insertDictEntry(id: 1, dictId: 'mw', word: 'karma');

      final results = await dao.searchDictWordsPrefix(['cone'], 'karm');

      expect(results, isEmpty);
    });

    test('duplicate rows for one word collapse to a single suggestion', () async {
      await insertDictEntry(id: 1, dictId: 'mw', word: 'karma');
      await insertDictEntry(id: 2, dictId: 'mw', word: 'karma');

      final results = await dao.searchDictWordsPrefix(['mw'], 'karm');

      expect(results.where((w) => w == 'karma').length, 1);
    });

    test('the same word in two dictionaries collapses to a single suggestion', () async {
      await insertDictEntry(id: 1, dictId: 'mw', word: 'karma');
      await insertDictEntry(id: 2, dictId: 'cone', word: 'karma');

      final results = await dao.searchDictWordsPrefix(['mw', 'cone'], 'karm');

      expect(results.where((w) => w == 'karma').length, 1);
    });

    test('exact prefix only, same as searchLookupKeysPrefix', () async {
      await insertDictEntry(id: 1, dictId: 'mw', word: 'kammā');

      final results = await dao.searchDictWordsPrefix(['mw'], 'kamma');

      expect(results, isNot(contains('kammā')));
    });
  });
}
