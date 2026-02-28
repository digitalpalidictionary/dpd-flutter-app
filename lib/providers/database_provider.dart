import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/dao.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final daoProvider = Provider<DpdDao>((ref) {
  return DpdDao(ref.watch(databaseProvider));
});
