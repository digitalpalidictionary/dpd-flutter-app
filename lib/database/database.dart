import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/native.dart';

import 'tables.dart';
export 'dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    DpdHeadwords,
    Lookup,
    DpdRoots,
    DbInfo,
    InflectionTemplates,
    FamilyRoot,
    FamilyWord,
    FamilyCompound,
    FamilyIdiom,
    FamilySet,
    SuttaInfo,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // DB is replaced wholesale on update; migration is a safety no-op.
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFile = await resolveDbPath();
    return NativeDatabase.createInBackground(dbFile);
  });
}

Future<File> resolveDbPath() async {
  // DB lives in app-specific external storage (no permissions required).
  // Dev: push via `just push-mobile-db`.
  // Production: downloaded on first launch.
  if (Platform.isAndroid) {
    final extDir = await getExternalStorageDirectory();
    return File(p.join(extDir!.path, 'dpd-mobile.db'));
  }
  final docsDir = await getApplicationDocumentsDirectory();
  return File(p.join(docsDir.path, 'dpd-mobile.db'));
}
