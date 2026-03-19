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
    DictMeta,
    DictEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Bump when the Drift schema changes and a matching DB export is required.
  /// The exported DB must set `db_schema_version` in the `db_info` table to
  /// the same value. When the on-device DB has a lower value, the app forces
  /// a blocking re-download before any queries run.
  static const requiredDbSchemaVersion = 3;

  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // DB is replaced wholesale on update; migration is a safety no-op.
    },
    beforeOpen: (details) async {
      // A newer DB (from a background update) may have a higher user_version
      // than the current app expects. Reset it so Drift doesn't choke on a
      // "downgrade" next time the DB is opened.
      if (details.versionNow != schemaVersion) {
        await customStatement('PRAGMA user_version = $schemaVersion');
      }
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
