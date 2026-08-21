import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';
import 'package:drift/native.dart';
import 'dart:io';

void main() {
  final file = File('../dpd-db/exporter/share/dpd-mobile.db');
  final dbAvailable = file.existsSync();

  group('searchFuzzyExactKeyMatches', () {
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

    test(
      'kammam returns kammaṃ and kāmaṃ, with kammaṃ at or before kāmaṃ',
      () async {
        final results = await dao.searchFuzzyExactKeyMatches('kammam');

        expect(results, contains('kammaṃ'));
        expect(results, contains('kāmaṃ'));
        expect(
          results.indexOf('kammaṃ'),
          lessThanOrEqualTo(results.indexOf('kāmaṃ')),
        );
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'dhammam returns dhammaṃ',
      () async {
        final results = await dao.searchFuzzyExactKeyMatches('dhammam');
        expect(results, contains('dhammaṃ'));
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'a nonsense query returns an empty list',
      () async {
        final results = await dao.searchFuzzyExactKeyMatches('xyzzyq');
        expect(results, isEmpty);
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );

    test(
      'an empty query returns an empty list',
      () async {
        final results = await dao.searchFuzzyExactKeyMatches('');
        expect(results, isEmpty);
      },
      skip: dbAvailable ? null : 'requires ../dpd-db/exporter/share/dpd-mobile.db',
    );
  });
}
