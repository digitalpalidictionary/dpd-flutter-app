import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';
export 'dao.dart';

part 'database.g.dart';

@DriftDatabase(tables: [DpdHeadwords, Lookup, DpdRoots, DbInfo, InflectionTemplates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {},
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFile = await _resolveDbPath();
    return NativeDatabase.createInBackground(dbFile);
  });
}

Future<File> _resolveDbPath() async {
  // DB lives in app documents directory.
  // Dev: populated by ADB (see README).
  // Production: downloaded on first launch.
  final docsDir = await getApplicationDocumentsDirectory();
  return File(p.join(docsDir.path, 'dpd.db'));
}
