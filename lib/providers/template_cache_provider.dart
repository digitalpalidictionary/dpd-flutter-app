import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'database_provider.dart';

/// Loads all inflection templates into memory keyed by pattern for O(1) lookup.
final templateCacheProvider =
    FutureProvider<Map<String, InflectionTemplate>>((ref) async {
      final dao = ref.watch(daoProvider);
      final templates = await dao.getAllInflectionTemplates();
      return {for (final t in templates) t.pattern: t};
    });
