import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';
import 'package:drift/native.dart';
import 'dart:io';

void main() {
  test('Search roots test', () async {
    final file = File('../dpd-db/dpd.db');
    if (!file.existsSync()) {
      fail('Database file not found at ${file.absolute.path}');
    }
    final db = AppDatabase.forTesting(NativeDatabase(file));
    final dao = DpdDao(db);

    final res = await dao.searchRoots("√har");
    expect(res, isNotEmpty);

    final res2 = await dao.searchRoots("√har 1");
    expect(res2, isNotEmpty);

    await db.close();
  });
}
