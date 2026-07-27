import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/utils/diacritics.dart';

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

  test('getSuttaInfo matches aliases in dpdSuttaVar', () async {
    await dao.into(dao.suttaInfo).insert(
      SuttaInfoCompanion.insert(
        dpdSutta: 'mūlapaṇṇāsapāḷi',
        dpdSuttaVar: const Value('mūlapaṇṇāsaka 1; mūlapaṇṇāsaka'),
      ),
    );

    final exactAlias = await dao.getSuttaInfo('mūlapaṇṇāsaka 1');
    final trailingAlias = await dao.getSuttaInfo('mūlapaṇṇāsaka');

    expect(exactAlias?.dpdSutta, 'mūlapaṇṇāsapāḷi');
    expect(trailingAlias?.dpdSutta, 'mūlapaṇṇāsapāḷi');
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
          wordFuzzy: Value(stripDiacritics(word.toLowerCase())),
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
      final exact = await dao.searchDictExact(['cone'], 'buddha');

      expect(partial, isEmpty);
      expect(exact, isEmpty);
    });
  });

  group('searchDictExact', () {
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
          wordFuzzy: Value(stripDiacritics(word.toLowerCase())),
        ),
      );
    }

    test('matches a capitalised headword from a lowercase query', () async {
      await insertDictEntry(db, id: 1, dictId: 'dppn', word: 'Anāthapiṇḍika');

      final results = await dao.searchDictExact(['dppn'], 'anāthapiṇḍika');

      expect(results.map((e) => e.word), ['Anāthapiṇḍika']);
    });

    test('matches an accented capital, which SQLite lower() cannot fold', () async {
      await insertDictEntry(db, id: 1, dictId: 'dppn', word: 'Ānanda');
      await insertDictEntry(db, id: 2, dictId: 'dppn', word: 'Ñāṇamoli');

      final ananda = await dao.searchDictExact(['dppn'], 'ānanda');
      final nanamoli = await dao.searchDictExact(['dppn'], 'ñāṇamoli');

      expect(ananda.map((e) => e.word), ['Ānanda']);
      expect(nanamoli.map((e) => e.word), ['Ñāṇamoli']);
    });

    test('matches regardless of how the query itself is capitalised', () async {
      await insertDictEntry(db, id: 1, dictId: 'dppn', word: 'Akatti');

      for (final query in ['akatti', 'Akatti', 'AKATTI', 'aKaTTi']) {
        final results = await dao.searchDictExact(['dppn'], query);
        expect(results.map((e) => e.word), ['Akatti'], reason: query);
      }
    });

    test('returns every entry sharing the headword', () async {
      await insertDictEntry(db, id: 1, dictId: 'dppn', word: 'Tissa');
      await insertDictEntry(db, id: 2, dictId: 'dppn', word: 'Tissa');
      await insertDictEntry(db, id: 3, dictId: 'cpd', word: 'tissa');

      final results = await dao.searchDictExact(['dppn', 'cpd'], 'tissa');

      expect(results.map((e) => e.id).toSet(), {1, 2, 3});
    });

    test('does not match a merely similar word sharing a fuzzy key', () async {
      // stripDiacritics folds diacritics and doubled consonants, so these
      // three collapse to the same fuzzy key but are not the same word.
      await insertDictEntry(db, id: 1, dictId: 'dppn', word: 'Kassapa');
      await insertDictEntry(db, id: 2, dictId: 'dppn', word: 'Kasapa');
      await insertDictEntry(db, id: 3, dictId: 'dppn', word: 'Kāsapā');

      final results = await dao.searchDictExact(['dppn'], 'kassapa');

      expect(results.map((e) => e.word), ['Kassapa']);
    });

    test('only searches the dictionaries it is given', () async {
      await insertDictEntry(db, id: 1, dictId: 'dppn', word: 'Tissa');
      await insertDictEntry(db, id: 2, dictId: 'cone', word: 'tissa');

      final results = await dao.searchDictExact(['cone'], 'tissa');

      expect(results.map((e) => e.id), [2]);
    });

    test('returns empty for no dictionaries or an empty query', () async {
      await insertDictEntry(db, id: 1, dictId: 'dppn', word: 'Tissa');

      expect(await dao.searchDictExact([], 'tissa'), isEmpty);
      expect(await dao.searchDictExact(['dppn'], ''), isEmpty);
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
