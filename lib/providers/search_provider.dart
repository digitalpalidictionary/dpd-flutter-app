import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'database_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadword>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dao = ref.watch(daoProvider);
  return dao.search(query);
});
