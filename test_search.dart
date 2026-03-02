import 'package:drift/native.dart';
import 'dart:io';
import 'package:dpd_flutter_app/database/database.dart';

void main() async {
  final file = File('../dpd-db/dpd.db');
  final db = AppDatabase.forTesting(NativeDatabase(file));
  final dao = DpdDao(db);

  final res = await dao.searchRoots("√har");
  print("Found roots for √har:");
  for (final r in res) {
    print("${r.root.root} (families: ${r.families.length})");
  }

  final res2 = await dao.searchRoots("har");
  print("\nFound roots for har:");
  for (final r in res2) {
    print("${r.root.root} (families: ${r.families.length})");
  }

  final res3 = await dao.searchRoots("√har 1");
  print("\nFound roots for √har 1:");
  for (final r in res3) {
    print("${r.root.root} (families: ${r.families.length})");
  }

  await db.close();
}
