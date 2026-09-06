import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

/// The recommended citation for the bundled database, written into `db_info`
/// by the dpd-db build so it always names the version actually installed.
final citationProvider = FutureProvider<String?>((ref) async {
  final dao = ref.watch(daoProvider);
  return dao.getDbValue('citation');
});
