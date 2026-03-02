import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';
import 'package:drift/native.dart';
import 'dart:io';

void main() {
  test('Search roots test 2', () async {
    final file = File('../dpd-db/dpd.db');
    if (!file.existsSync()) {
      fail('Database file not found at ${file.absolute.path}');
    }
    final db = AppDatabase.forTesting(NativeDatabase(file));
    final dao = DpdDao(db);

    try {
      final res2 = await dao.searchRoots("√har 1");
      expect(res2, isNotEmpty);
      print("\nFound roots for √har 1:");
      for (final r in res2) {
        print("${r.root.root} (families: ${r.families.length})");
      }
    } catch (e) {
      print("Error in √har 1: $e");
    }

    try {
      final res3 = await dao.searchRoots("√har 3");
      print("\nFound roots for √har 3:");
      for (final r in res3) {
        print("${r.root.root} (families: ${r.families.length})");
      }
    } catch (e) {
      print("Error in √har 3: $e");
    }

    await db.close();
  });
}
