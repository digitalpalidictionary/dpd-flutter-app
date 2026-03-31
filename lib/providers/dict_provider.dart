import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../utils/diacritics.dart';
import '../utils/pali_sort.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

// ── DPD source metadata (code-defined, not in DB) ───────────────────────────

class DpdSourceMeta {
  final String id;
  final String label;
  const DpdSourceMeta(this.id, this.label);
}

const kDpdSources = [
  DpdSourceMeta('dpd_summary', 'DPD Summary'),
  DpdSourceMeta('dpd_headwords', 'DPD Headwords'),
  DpdSourceMeta('dpd_roots', 'DPD Roots'),
  DpdSourceMeta('dpd_abbreviations', 'DPD Abbreviations'),
  DpdSourceMeta('dpd_deconstructor', 'DPD Deconstructor'),
  DpdSourceMeta('dpd_grammar', 'DPD Grammar'),
  DpdSourceMeta('dpd_help', 'DPD Help'),
  DpdSourceMeta('dpd_epd', 'DPD EPD'),
  DpdSourceMeta('dpd_variants', 'DPD Variants'),
  DpdSourceMeta('dpd_spelling', 'DPD Spelling'),
  DpdSourceMeta('dpd_see', 'DPD See'),
];

final kDpdSourceNames = {
  for (final s in kDpdSources) s.id: s.label,
};

// ── DictResult ───────────────────────────────────────────────────────────────

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
    // Seed DPD sources immediately so they are always present before any
    // provider reads from state — even before the DB dict meta resolves.
    initFromMeta([]);
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

  void initFromMeta(List<DictMetaData> dictMeta) {
    final dpdIds = kDpdSources.map((s) => s.id).toList();
    final dictIds = dictMeta.map((m) => m.dictId).toList();
    final allIds = [...dpdIds, ...dictIds];

    if (state.order.isNotEmpty) {
      final existing = state.order.toSet();
      final newDpdIds = dpdIds.where((id) => !existing.contains(id)).toList();
      final newDictIds = dictIds.where((id) => !existing.contains(id)).toList();
      if (newDpdIds.isNotEmpty || newDictIds.isNotEmpty) {
        // Prepend new DPD sources before the existing order; append new dict sources at end
        state = state.copyWith(
          order: [...newDpdIds, ...state.order, ...newDictIds],
          enabled: {...state.enabled, ...newDpdIds, ...newDictIds},
        );
        _save();
      }
      return;
    }

    // Fresh install: DPD sources first, then dict sources
    state = DictVisibility(order: allIds, enabled: allIds.toSet());
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
  final List<DictResult> partial;
  final List<DictResult> fuzzy;

  const DictSearchResults({
    this.exact = const [],
    this.partial = const [],
    this.fuzzy = const [],
  });
}

class DictRawSearchResults {
  final Map<String, String> metaNames;
  final Map<String, List<DictEntry>> exact;
  final Map<String, List<DictEntry>> partial;
  final Map<String, List<DictEntry>> fuzzy;

  const DictRawSearchResults({
    this.metaNames = const {},
    this.exact = const {},
    this.partial = const {},
    this.fuzzy = const {},
  });

  factory DictRawSearchResults.fromRows({
    List<DictMetaData> meta = const [],
    List<DictEntry> exactRows = const [],
    List<DictEntry> partialRows = const [],
    List<DictEntry> fuzzyRows = const [],
  }) {
    final exactIds = exactRows.map((entry) => entry.id).toSet();
    final partialIds = partialRows.map((entry) => entry.id).toSet();
    final excludedFromFuzzy = exactIds.union(partialIds);

    final fuzzySorted = [...fuzzyRows]..sort(
      (a, b) => paliSortKey(a.word).compareTo(paliSortKey(b.word)),
    );
    final fuzzyGrouped = <String, List<DictEntry>>{};
    for (final entry in fuzzySorted) {
      if (excludedFromFuzzy.contains(entry.id)) continue;
      fuzzyGrouped.putIfAbsent(entry.dictId, () => []).add(entry);
    }

    return DictRawSearchResults(
      metaNames: {for (final item in meta) item.dictId: item.name},
      exact: _groupDictEntries(exactRows),
      partial: _groupDictEntries(partialRows),
      fuzzy: fuzzyGrouped,
    );
  }
}

Map<String, List<DictEntry>> _groupDictEntries(List<DictEntry> rows) {
  final sorted = [...rows]..sort(
    (a, b) => paliSortKey(a.word).compareTo(paliSortKey(b.word)),
  );
  final grouped = <String, List<DictEntry>>{};
  for (final entry in sorted) {
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
    partial: present(raw.partial),
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

      List<DictEntry> partialRows;
      try {
        partialRows = await dao.searchDictPartial(query.toLowerCase());
      } catch (_) {
        partialRows = const [];
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
        partialRows: partialRows,
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
