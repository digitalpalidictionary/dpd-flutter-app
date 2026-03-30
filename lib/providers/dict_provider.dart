import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../utils/diacritics.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

class DictResult {
  final String dictId;
  final String dictName;
  final List<DictEntry> entries;

  DictResult({
    required this.dictId,
    required this.dictName,
    required this.entries,
  });
}

class DictVisibility {
  final List<String> order;
  final Set<String> enabled;

  const DictVisibility({required this.order, required this.enabled});

  DictVisibility copyWith({List<String>? order, Set<String>? enabled}) {
    return DictVisibility(
      order: order ?? this.order,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'order': order,
    'enabled': enabled.toList(),
  };

  factory DictVisibility.fromJson(Map<String, dynamic> json) {
    return DictVisibility(
      order: (json['order'] as List).cast<String>(),
      enabled: (json['enabled'] as List).cast<String>().toSet(),
    );
  }
}

const _prefsKey = 'dict_visibility';

final dictVisibilityProvider =
    StateNotifierProvider<DictVisibilityNotifier, DictVisibility>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return DictVisibilityNotifier(prefs);
    });

class DictVisibilityNotifier extends StateNotifier<DictVisibility> {
  DictVisibilityNotifier(this._prefs)
    : super(const DictVisibility(order: [], enabled: {})) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final json = _prefs.getString(_prefsKey);
    if (json != null) {
      try {
        state = DictVisibility.fromJson(jsonDecode(json));
      } catch (_) {
        // Corrupted prefs — keep defaults
      }
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  void initFromMeta(List<DictMetaData> allMeta) {
    if (state.order.isNotEmpty) {
      final known = allMeta.map((m) => m.dictId).toSet();
      final newIds = known.difference(state.order.toSet());
      if (newIds.isNotEmpty) {
        state = state.copyWith(
          order: [...state.order, ...newIds],
          enabled: {...state.enabled, ...newIds},
        );
        _save();
      }
      return;
    }
    final ids = allMeta.map((m) => m.dictId).toList();
    state = DictVisibility(order: ids, enabled: ids.toSet());
    _save();
  }

  Future<void> setOrder(List<String> order) async {
    state = state.copyWith(order: order);
    await _save();
  }

  Future<void> toggleDict(String dictId, bool enabled) async {
    final newEnabled = Set<String>.from(state.enabled);
    if (enabled) {
      newEnabled.add(dictId);
    } else {
      newEnabled.remove(dictId);
    }
    state = state.copyWith(enabled: newEnabled);
    await _save();
  }
}

final dictMetaAllProvider = FutureProvider<List<DictMetaData>>((ref) async {
  final dao = ref.watch(daoProvider);
  try {
    return await dao.getAllDictMeta();
  } catch (_) {
    return [];
  }
});

final dictCssProvider = FutureProvider.family<String?, String>((
  ref,
  dictId,
) async {
  final dao = ref.watch(daoProvider);
  try {
    final meta = await dao.getDictMeta(dictId);
    return meta?.css;
  } catch (_) {
    return null;
  }
});

class DictSearchResults {
  final List<DictResult> exact;
  final List<DictResult> fuzzy;

  const DictSearchResults({this.exact = const [], this.fuzzy = const []});
}

class DictRawSearchResults {
  final Map<String, String> metaNames;
  final Map<String, List<DictEntry>> exact;
  final Map<String, List<DictEntry>> fuzzy;

  const DictRawSearchResults({
    this.metaNames = const {},
    this.exact = const {},
    this.fuzzy = const {},
  });

  factory DictRawSearchResults.fromRows({
    List<DictMetaData> meta = const [],
    List<DictEntry> exactRows = const [],
    List<DictEntry> fuzzyRows = const [],
  }) {
    final exactIds = exactRows.map((entry) => entry.id).toSet();
    final fuzzyGrouped = <String, List<DictEntry>>{};
    for (final entry in fuzzyRows) {
      if (exactIds.contains(entry.id)) continue;
      fuzzyGrouped.putIfAbsent(entry.dictId, () => []).add(entry);
    }

    return DictRawSearchResults(
      metaNames: {for (final item in meta) item.dictId: item.name},
      exact: _groupDictEntries(exactRows),
      fuzzy: fuzzyGrouped,
    );
  }
}

Map<String, List<DictEntry>> _groupDictEntries(List<DictEntry> rows) {
  final grouped = <String, List<DictEntry>>{};
  for (final entry in rows) {
    grouped.putIfAbsent(entry.dictId, () => []).add(entry);
  }
  return grouped;
}

DictSearchResults presentDictSearchResults(
  DictRawSearchResults raw,
  DictVisibility visibility,
) {
  List<DictResult> present(Map<String, List<DictEntry>> grouped) {
    final results = <DictResult>[];
    final seen = <String>{};

    void maybeAdd(String dictId) {
      if (!visibility.enabled.contains(dictId) || seen.contains(dictId)) return;
      final entries = grouped[dictId];
      if (entries == null || entries.isEmpty) return;
      seen.add(dictId);
      results.add(
        DictResult(
          dictId: dictId,
          dictName: raw.metaNames[dictId] ?? dictId,
          entries: entries,
        ),
      );
    }

    for (final dictId in visibility.order) {
      maybeAdd(dictId);
    }
    for (final dictId in grouped.keys) {
      maybeAdd(dictId);
    }

    return results;
  }

  return DictSearchResults(
    exact: present(raw.exact),
    fuzzy: present(raw.fuzzy),
  );
}

final _dictRawResultsProvider = FutureProvider.autoDispose
    .family<DictRawSearchResults, String>((ref, query) async {
      if (query.isEmpty) return const DictRawSearchResults();

      final dao = ref.watch(daoProvider);
      final allMeta = await ref.watch(dictMetaAllProvider.future);

      List<DictEntry> exactRows;
      try {
        exactRows = await dao.searchDictExact(query.toLowerCase());
      } catch (_) {
        exactRows = const [];
      }

      List<DictEntry> fuzzyRows;
      try {
        final fuzzyKey = stripDiacritics(query.toLowerCase());
        fuzzyRows = await dao.searchDictFuzzy(fuzzyKey);
      } catch (_) {
        fuzzyRows = const [];
      }

      return DictRawSearchResults.fromRows(
        meta: allMeta,
        exactRows: exactRows,
        fuzzyRows: fuzzyRows,
      );
    });

final dictResultsProvider = Provider.autoDispose
    .family<AsyncValue<DictSearchResults>, String>((ref, query) {
      final visibility = ref.watch(dictVisibilityProvider);
      final rawAsync = ref.watch(_dictRawResultsProvider(query));

      return rawAsync.whenData(
        (raw) => presentDictSearchResults(raw, visibility),
      );
    });
