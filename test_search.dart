import 'package:drift/native.dart';
import 'dart:io';
import 'package:dpd_flutter_app/database/database.dart';

void main() async {
  final file = File('../dpd-db/dpd.db');
  final db = AppDatabase.forTesting(NativeDatabase(file));
  final dao = DpdDao(db);

  await dao.searchRoots("√har");
  await dao.searchRoots("har");
  await dao.searchRoots("√har 1");

  await db.close();
}
