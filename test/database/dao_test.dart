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

  test('search joins DpdRoots and returns DpdHeadwordWithRoot', () async {
    // Insert a root
    await dao
        .into(dao.dpdRoots)
        .insert(
          DpdRoot(
            root: 'kam',
            rootHasVerb: 'has_verb',
            rootInComps: '',
            rootGroup: 1,
            rootSign: '',
            rootMeaning: 'to love',
            sanskritRoot: '',
            sanskritRootMeaning: '',
            sanskritRootClass: '',
            rootExample: '',
            dhatupathaNum: '',
            dhatupathaRoot: '',
            dhatupathaPali: '',
            dhatupathaEnglish: '',
            dhatumanjusaNum: '',
            dhatumanjusaRoot: '',
            dhatumanjusaPali: '',
            dhatumanjusaEnglish: '',
            dhatumalaRoot: '',
            dhatumalaPali: '',
            dhatumalaEnglish: '',
            paniniRoot: '',
            paniniSanskrit: '',
            paniniEnglish: '',
            note: '',
          ),
        );

    // Insert a headword linking to the root
    await dao
        .into(dao.dpdHeadwords)
        .insert(DpdHeadword(id: 1, lemma1: 'kāma', rootKey: 'kam'));

    // Insert lookup
    await dao
        .into(dao.lookup)
        .insert(LookupData(lookupKey: 'kāma', headwords: '[1]'));

    // Perform search
    final results = await dao.searchExact('kāma');

    expect(results.length, 1);
    final result = results.first;

    // Check it has both headword and root
    expect(result.headword.lemma1, 'kāma');
    expect(result.root, isNotNull);
    expect(result.root!.rootMeaning, 'to love');
  });

  test('checkWordsInLookup returns only words that exist in lookup', () async {
    await dao.into(dao.lookup).insert(LookupData(lookupKey: 'dhammo', headwords: '[1]'));
    await dao.into(dao.lookup).insert(LookupData(lookupKey: 'dhammā', headwords: '[1]'));

    final result = await dao.checkWordsInLookup({'dhammo', 'dhammā', 'dhammañ'});

    expect(result, {'dhammo', 'dhammā'});
    expect(result.contains('dhammañ'), isFalse);
  });

  test('checkWordsInLookup returns empty set for empty input', () async {
    final result = await dao.checkWordsInLookup({});
    expect(result, isEmpty);
  });

  test('getAllLookupKeys returns a Set of all lookup_key values', () async {
    await dao.into(dao.lookup).insert(
      LookupData(lookupKey: 'dhammo', headwords: '[1]'),
    );
    await dao.into(dao.lookup).insert(
      LookupData(lookupKey: 'dhammā', headwords: '[1]'),
    );
    await dao.into(dao.lookup).insert(
      LookupData(lookupKey: 'kāma', headwords: '[2]'),
    );

    final keys = await dao.getAllLookupKeys();

    expect(keys, isA<Set<String>>());
    expect(keys.length, 3);
    expect(keys, containsAll(['dhammo', 'dhammā', 'kāma']));
  });

  test('getAllLookupKeys returns empty set when lookup table is empty', () async {
    final keys = await dao.getAllLookupKeys();
    expect(keys, isEmpty);
  });

  group('searchDictPartial', () {
    Future<void> insertDictEntry(
      AppDatabase db, {
      required int id,
      required String dictId,
      required String word,
    }) async {
      await db.into(db.dictEntries).insert(
        DictEntriesCompanion.insert(
          id: Value(id),
          dictId: dictId,
          word: word,
        ),
      );
    }

    test('returns entries whose word starts with the query, excluding exact', () async {
      await insertDictEntry(db, id: 1, dictId: 'cone', word: 'buddha');
      await insertDictEntry(db, id: 2, dictId: 'cone', word: 'buddhakāya');
      await insertDictEntry(db, id: 3, dictId: 'cone', word: 'buddhassa');
      await insertDictEntry(db, id: 4, dictId: 'cone', word: 'dhamma');

      final results = await dao.searchDictPartial('buddha');

      final ids = results.map((e) => e.id).toSet();
      expect(ids, {2, 3});
      expect(ids, isNot(contains(1)));
    });

    test('excludes exact match at DB level, not in-memory', () async {
      await insertDictEntry(db, id: 1, dictId: 'cone', word: 'buddha');
      await insertDictEntry(db, id: 2, dictId: 'cone', word: 'buddhas');

      final results = await dao.searchDictPartial('buddha');

      expect(results.map((e) => e.word), isNot(contains('buddha')));
      expect(results.map((e) => e.word), contains('buddhas'));
    });

    test('returns empty when no prefix matches exist', () async {
      await insertDictEntry(db, id: 1, dictId: 'cone', word: 'dhamma');

      final results = await dao.searchDictPartial('buddha');

      expect(results, isEmpty);
    });

    test('respects the limit parameter', () async {
      for (var i = 1; i <= 60; i++) {
        await insertDictEntry(db, id: i, dictId: 'cone', word: 'buddha$i');
      }

      final results = await dao.searchDictPartial('buddha', limit: 10);

      expect(results.length, 10);
    });

    test('fuzzy results are semantically separate from partial results', () async {
      await insertDictEntry(db, id: 1, dictId: 'cone', word: 'dharma');

      final partial = await dao.searchDictPartial('buddha');
      final exact = await dao.searchDictExact('buddha');

      expect(partial, isEmpty);
      expect(exact, isEmpty);
    });
  });

  test('getById joins DpdRoots and returns DpdHeadwordWithRoot', () async {
    // Insert a root
    await dao
        .into(dao.dpdRoots)
        .insert(
          DpdRoot(
            root: 'gam',
            rootHasVerb: 'has_verb',
            rootInComps: '',
            rootGroup: 1,
            rootSign: '',
            rootMeaning: 'to go',
            sanskritRoot: '',
            sanskritRootMeaning: '',
            sanskritRootClass: '',
            rootExample: '',
            dhatupathaNum: '',
            dhatupathaRoot: '',
            dhatupathaPali: '',
            dhatupathaEnglish: '',
            dhatumanjusaNum: '',
            dhatumanjusaRoot: '',
            dhatumanjusaPali: '',
            dhatumanjusaEnglish: '',
            dhatumalaRoot: '',
            dhatumalaPali: '',
            dhatumalaEnglish: '',
            paniniRoot: '',
            paniniSanskrit: '',
            paniniEnglish: '',
            note: '',
          ),
        );

    // Insert a headword linking to the root
    await dao
        .into(dao.dpdHeadwords)
        .insert(DpdHeadword(id: 2, lemma1: 'gacchati', rootKey: 'gam'));

    // Perform getById
    final result = await dao.getById(2);

    expect(result, isNotNull);
    expect(result!.headword.lemma1, 'gacchati');
    expect(result.root, isNotNull);
    expect(result.root!.rootMeaning, 'to go');
  });
}
