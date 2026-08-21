import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';
import 'package:drift/native.dart';
import 'dart:io';

void main() {
  final file = File('../dpd-db/exporter/share/dpd-mobile.db');
  final dbAvailable = file.existsSync();

  group('fuzzy result ranking', () {
    late AppDatabase db;
    late DpdDao dao;

    setUp(() {
      if (!dbAvailable) return;
      db = AppDatabase.forTesting(NativeDatabase(file));
      dao = DpdDao(db);
    });

    tearDown(() async {
      if (!dbAvailable) return;
      await db.close();
    });

    int firstIndexWhere(List<String> lemmas, bool Function(String) test) =>
        lemmas.indexWhere(test);

    test(
      'rupaṁ: every rūpa* lemma precedes every ruppa* lemma',
      () async {
        final results = await dao.searchFuzzy('rupaṁ');
        final lemmas = results.map((r) => r.headword.lemma1).toList();

        final lastRupa = lemmas.lastIndexWhere((l) => l.startsWith('rūpa'));
        final firstRuppa = firstIndexWhere(
          lemmas,
          (l) => l.startsWith('ruppa'),
        );

        expect(lastRupa, greaterThanOrEqualTo(0));
        expect(firstRuppa, greaterThanOrEqualTo(0));
        expect(lastRupa, lessThan(firstRuppa));
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'kammam: kamma 1 precedes kama 1',
      () async {
        final results = await dao.searchFuzzy('kammam');
        final lemmas = results.map((r) => r.headword.lemma1).toList();

        expect(lemmas.indexOf('kamma 1'), lessThan(lemmas.indexOf('kama 1')));
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'dhammam: dhamma 1.01 precedes dama',
      () async {
        final results = await dao.searchFuzzy('dhammam');
        final lemmas = results.map((r) => r.headword.lemma1).toList();

        expect(
          lemmas.indexOf('dhamma 1.01'),
          lessThan(lemmas.indexOf('dama')),
        );
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'exact and partial tiers are unaffected by the fuzzy ranking change',
      () async {
        final exact = await dao.searchExact('rūpaṃ');
        final exactLemmas = exact.map((r) => r.headword.lemma1).toList();
        expect(exactLemmas, [
          'rūpa 1',
          'rūpa 2',
          'rūpa 3',
          'rūpa 4',
          'rūpa 5',
          'rūpa 6',
          'rūpa 7',
          'rūpa 8',
        ]);

        final partial = await dao.searchPartial('rūpaṃ');
        final partialLemmas = partial.map((r) => r.headword.lemma1).toList();
        expect(partialLemmas, exactLemmas);
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'searchFuzzyExact: kammam resolves to kamma headwords',
      () async {
        final results = await dao.searchFuzzyExact('kammam');
        final lemmas = results.map((r) => r.headword.lemma1).toList();
        expect(lemmas, contains('kamma 1'));
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'searchFuzzyExact: dhammam resolves to dhamma headwords',
      () async {
        final results = await dao.searchFuzzyExact('dhammam');
        final lemmas = results.map((r) => r.headword.lemma1).toList();
        expect(lemmas, contains('dhamma 1.01'));
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'searchFuzzyExact: a nonsense query returns an empty list',
      () async {
        final results = await dao.searchFuzzyExact('xyzzyq');
        expect(results, isEmpty);
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );
  });
}
