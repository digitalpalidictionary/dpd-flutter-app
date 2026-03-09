import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'database_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final exactResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadwordWithRoot>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dao = ref.watch(daoProvider);
  return dao.searchExact(query);
});

final partialResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadwordWithRoot>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dao = ref.watch(daoProvider);
  return dao.searchPartial(query);
});

final rootResultsProvider = FutureProvider.autoDispose
    .family<List<RootWithFamilies>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dao = ref.watch(daoProvider);
  return dao.searchRoots(query);
});

final fuzzyResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadwordWithRoot>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dao = ref.watch(daoProvider);
  return dao.searchFuzzy(query);
});
