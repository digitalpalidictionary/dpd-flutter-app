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
            rootInfo: '',
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
            rootInfo: '',
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
