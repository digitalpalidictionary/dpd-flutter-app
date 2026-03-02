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

    final res2 = await dao.searchRoots("√har 1");
    expect(res2, isNotEmpty);

    final res3 = await dao.searchRoots("√har 3");
    expect(res3, isNotEmpty);

    await db.close();
  });
}
