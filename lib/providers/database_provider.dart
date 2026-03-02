import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../widgets/root_matrix_builder.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final daoProvider = Provider<DpdDao>((ref) {
  return DpdDao(ref.watch(databaseProvider));
});

final compoundFamilyKeysProvider = FutureProvider<Set<String>>((ref) async {
  return ref.watch(daoProvider).getAllCompoundFamilyKeys();
});

final idiomKeysProvider = FutureProvider<Set<String>>((ref) async {
  return ref.watch(daoProvider).getAllIdiomKeys();
});

final basesForRootProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, rootKey) {
      return ref.watch(daoProvider).getBasesForRoot(rootKey);
    });

final rootMatrixProvider = FutureProvider.autoDispose
    .family<RootMatrixData, String>((ref, rootKey) async {
      final headwords = await ref
          .watch(daoProvider)
          .getHeadwordsForRootMatrix(rootKey);
      return buildRootMatrix(headwords);
    });
