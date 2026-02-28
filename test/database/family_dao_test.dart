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

  // ── FamilyRoot ─────────────────────────────────────────────────────────────

  group('getRootFamily', () {
    test('returns row matching rootKey and familyRoot', () async {
      await dao.into(dao.familyRoot).insert(
        FamilyRootData(
          rootFamilyKey: 'kara_kara',
          rootKey: 'kara',
          rootFamily: 'kara',
          rootMeaning: 'to do',
          data: '[["karoti","pr","to do","√"]]',
          count: 5,
        ),
      );

      final result = await dao.getRootFamily('kara', 'kara');

      expect(result, isNotNull);
      expect(result!.rootFamilyKey, 'kara_kara');
      expect(result.rootMeaning, 'to do');
      expect(result.count, 5);
    });

    test('returns null when no match', () async {
      final result = await dao.getRootFamily('nonexistent', 'family');
      expect(result, isNull);
    });
  });

  // ── FamilyWord ─────────────────────────────────────────────────────────────

  group('getWordFamily', () {
    test('returns row matching wordFamily', () async {
      await dao.into(dao.familyWord).insert(
        FamilyWordData(
          wordFamily: 'dhamma',
          data: '[["dhamma","masc","truth","✓"]]',
          count: 12,
        ),
      );

      final result = await dao.getWordFamily('dhamma');

      expect(result, isNotNull);
      expect(result!.wordFamily, 'dhamma');
      expect(result.count, 12);
    });

    test('returns null when no match', () async {
      final result = await dao.getWordFamily('nonexistent');
      expect(result, isNull);
    });
  });

  // ── FamilyCompound ─────────────────────────────────────────────────────────

  group('getCompoundFamilies', () {
    setUp(() async {
      await dao.into(dao.familyCompound).insert(
        FamilyCompoundData(
          compoundFamily: 'dhamma',
          data: '[["saddhammo","masc","good dhamma","✓"]]',
          count: 3,
        ),
      );
      await dao.into(dao.familyCompound).insert(
        FamilyCompoundData(
          compoundFamily: 'kāya',
          data: '[["kāyaduccarita","nt","bodily misconduct","✓"]]',
          count: 2,
        ),
      );
    });

    test('returns single matching row', () async {
      final results = await dao.getCompoundFamilies(['dhamma']);
      expect(results.length, 1);
      expect(results.first.compoundFamily, 'dhamma');
    });

    test('returns multiple matching rows', () async {
      final results = await dao.getCompoundFamilies(['dhamma', 'kāya']);
      expect(results.length, 2);
      final keys = results.map((r) => r.compoundFamily).toSet();
      expect(keys, containsAll(['dhamma', 'kāya']));
    });

    test('returns empty list for empty input', () async {
      final results = await dao.getCompoundFamilies([]);
      expect(results, isEmpty);
    });

    test('returns empty list for unknown keys', () async {
      final results = await dao.getCompoundFamilies(['nonexistent']);
      expect(results, isEmpty);
    });
  });

  // ── FamilyIdiom ────────────────────────────────────────────────────────────

  group('getIdioms', () {
    setUp(() async {
      await dao.into(dao.familyIdiom).insert(
        FamilyIdiomData(
          idiom: 'citta',
          data: '[["cittaṃ karoti","idiom","to pay attention","✓"]]',
          count: 2,
        ),
      );
      await dao.into(dao.familyIdiom).insert(
        FamilyIdiomData(
          idiom: 'kāra',
          data: '[["sakkāra","masc","hospitality","✓"]]',
          count: 1,
        ),
      );
    });

    test('returns single matching idiom', () async {
      final results = await dao.getIdioms(['citta']);
      expect(results.length, 1);
      expect(results.first.idiom, 'citta');
    });

    test('returns multiple matching idioms', () async {
      final results = await dao.getIdioms(['citta', 'kāra']);
      expect(results.length, 2);
    });

    test('returns empty list for empty input', () async {
      final results = await dao.getIdioms([]);
      expect(results, isEmpty);
    });

    test('returns empty list for unknown keys', () async {
      final results = await dao.getIdioms(['nonexistent']);
      expect(results, isEmpty);
    });
  });

  // ── FamilySet ──────────────────────────────────────────────────────────────

  group('getSets', () {
    setUp(() async {
      await dao.into(dao.familySet).insert(
        FamilySetData(
          set_: 'dhammas',
          data: '[["dhamma","masc","truth","✓"]]',
          count: 8,
        ),
      );
      await dao.into(dao.familySet).insert(
        FamilySetData(
          set_: 'khandhas',
          data: '[["rūpa","masc","form","✓"]]',
          count: 5,
        ),
      );
    });

    test('returns single matching set', () async {
      final results = await dao.getSets(['dhammas']);
      expect(results.length, 1);
      expect(results.first.set_, 'dhammas');
    });

    test('returns multiple matching sets', () async {
      final results = await dao.getSets(['dhammas', 'khandhas']);
      expect(results.length, 2);
    });

    test('returns empty list for empty input', () async {
      final results = await dao.getSets([]);
      expect(results, isEmpty);
    });

    test('returns empty list for unknown keys', () async {
      final results = await dao.getSets(['nonexistent']);
      expect(results, isEmpty);
    });
  });
}
