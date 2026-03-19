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

final dictCssProvider =
    FutureProvider.family<String?, String>((ref, dictId) async {
      final dao = ref.watch(daoProvider);
      try {
        final meta = await dao.getDictMeta(dictId);
        return meta?.css;
      } catch (_) {
        return null;
      }
    });

final dictResultsProvider = FutureProvider.autoDispose
    .family<List<DictResult>, String>((ref, query) async {
      if (query.isEmpty) return [];

      final dao = ref.watch(daoProvider);
      final visibility = ref.watch(dictVisibilityProvider);
      final allMeta = await ref.watch(dictMetaAllProvider.future);

      List<DictEntry> entries;
      try {
        final fuzzyKey = stripDiacritics(query.toLowerCase());
        final exact = await dao.searchDictExact(query.toLowerCase());
        final fuzzy = await dao.searchDictFuzzy(fuzzyKey);

        final seen = <int>{};
        entries = [];
        for (final e in exact) {
          seen.add(e.id);
          entries.add(e);
        }
        for (final e in fuzzy) {
          if (!seen.contains(e.id)) entries.add(e);
        }
      } catch (_) {
        return [];
      }

      final grouped = <String, List<DictEntry>>{};
      for (final entry in entries) {
        grouped.putIfAbsent(entry.dictId, () => []).add(entry);
      }

      final metaMap = {for (final m in allMeta) m.dictId: m.name};

      final results = <DictResult>[];
      for (final dictId in visibility.order) {
        if (!visibility.enabled.contains(dictId)) continue;
        final group = grouped[dictId];
        if (group == null || group.isEmpty) continue;
        results.add(DictResult(
          dictId: dictId,
          dictName: metaMap[dictId] ?? dictId,
          entries: group,
        ));
      }

      // Include any dict_ids not yet in the order
      for (final dictId in grouped.keys) {
        if (results.any((r) => r.dictId == dictId)) continue;
        results.add(DictResult(
          dictId: dictId,
          dictName: metaMap[dictId] ?? dictId,
          entries: grouped[dictId]!,
        ));
      }

      return results;
    });
