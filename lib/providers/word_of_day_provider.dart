import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/dao.dart';
import 'database_provider.dart';

final randomWordProvider = FutureProvider.autoDispose<DpdHeadwordWithRoot?>((ref) async {
  final dao = ref.watch(daoProvider);
  return dao.fetchRandomWord();
});
