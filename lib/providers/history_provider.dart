import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_provider.dart';

const _maxEntries = 50;
const _prefsKey = 'dpd_history';
const _navPrefsKey = 'dpd_nav';

class HistoryEntry {
  const HistoryEntry({required this.query, required this.timestamp});

  final String query;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'q': query,
        't': timestamp.millisecondsSinceEpoch,
      };

  static HistoryEntry fromJson(dynamic json) {
    if (json is String) {
      return HistoryEntry(query: json, timestamp: DateTime.now());
    }
    return HistoryEntry(
      query: json['q'] as String,
      timestamp: json['t'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['t'] as int)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HistoryEntry && other.query == query;

  @override
  int get hashCode => query.hashCode;
}

class HistoryState {
  const HistoryState({
    this.recentEntries = const [],
    this.navigationEntries = const [],
    this.currentNavigationIndex = -1,
  });

  final List<HistoryEntry> recentEntries;
  final List<String> navigationEntries;
  final int currentNavigationIndex;

  HistoryState copyWith({
    List<HistoryEntry>? recentEntries,
    List<String>? navigationEntries,
    int? currentNavigationIndex,
  }) {
    return HistoryState(
      recentEntries: recentEntries ?? this.recentEntries,
      navigationEntries: navigationEntries ?? this.navigationEntries,
      currentNavigationIndex:
          currentNavigationIndex ?? this.currentNavigationIndex,
    );
  }

  List<HistoryEntry> get entries => recentEntries;
  int get currentIndex => currentNavigationIndex;

  HistoryEntry? get currentEntry =>
      currentQuery == null
          ? null
          : recentEntries.cast<HistoryEntry?>().firstWhere(
                (entry) => entry?.query == currentQuery,
                orElse: () => HistoryEntry(
                  query: currentQuery!,
                  timestamp: DateTime.now(),
                ),
              );

  String? get currentQuery =>
      currentNavigationIndex >= 0 &&
              currentNavigationIndex < navigationEntries.length
          ? navigationEntries[currentNavigationIndex]
          : null;

  String? get backQuery => canGoBack
      ? navigationEntries[
          currentNavigationIndex.clamp(1, navigationEntries.length) - 1
        ]
      : null;

  String? get forwardQuery => canGoForward
      ? navigationEntries[currentNavigationIndex + 1]
      : null;

  bool get canGoBack => currentNavigationIndex > 0;
  bool get canGoForward =>
      currentNavigationIndex >= 0 &&
      currentNavigationIndex < navigationEntries.length - 1;
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._prefs) : super(const HistoryState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    var recent = state.recentEntries;
    final json = _prefs.getString(_prefsKey);
    if (json != null) {
      recent = (jsonDecode(json) as List).map(HistoryEntry.fromJson).toList();
    }

    var nav = state.navigationEntries;
    final navJson = _prefs.getString(_navPrefsKey);
    if (navJson != null) {
      try {
        nav = (jsonDecode(navJson) as List).cast<String>();
      } catch (_) {
        nav = const [];
      }
    }

    state = HistoryState(
      recentEntries: recent,
      navigationEntries: nav,
      currentNavigationIndex: nav.isEmpty ? -1 : nav.length,
    );
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _prefsKey,
      jsonEncode(state.recentEntries.map((e) => e.toJson()).toList()),
    );
    await _prefs.setString(
      _navPrefsKey,
      jsonEncode(state.navigationEntries),
    );
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.recentEntries.length) return;
    final entries = List<HistoryEntry>.from(state.recentEntries);
    entries.removeAt(index);
    state = state.copyWith(recentEntries: entries);
    _persist();
  }

  void navigateTo(String term) {
    if (term.isEmpty) return;
    final entry = HistoryEntry(query: term, timestamp: DateTime.now());
    final entries = List<HistoryEntry>.from(state.recentEntries);
    entries.removeWhere((e) => e == entry);
    entries.insert(0, entry);
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }

    final navigationEntries = List<String>.from(state.navigationEntries);
    final currentQuery = state.currentQuery;
    if (currentQuery != term) {
      if (state.currentNavigationIndex >= 0 &&
          state.currentNavigationIndex < navigationEntries.length - 1) {
        navigationEntries.removeRange(
          state.currentNavigationIndex + 1,
          navigationEntries.length,
        );
      }
      navigationEntries.add(term);
      if (navigationEntries.length > _maxEntries) {
        navigationEntries.removeAt(0);
      }
    }

    state = HistoryState(
      recentEntries: entries,
      navigationEntries: navigationEntries,
      currentNavigationIndex:
          navigationEntries.isEmpty ? -1 : navigationEntries.length - 1,
    );
    _persist();
  }

  void add(String term) => navigateTo(term);

  void resetPosition() {
    state = state.copyWith(
      currentNavigationIndex: state.navigationEntries.isEmpty
          ? -1
          : state.navigationEntries.length,
    );
    _persist();
  }

  void goBack() {
    if (!state.canGoBack) return;
    state = state.copyWith(
      currentNavigationIndex: state.currentNavigationIndex - 1,
    );
    _persist();
  }

  void goForward() {
    if (!state.canGoForward) return;
    state = state.copyWith(
      currentNavigationIndex: state.currentNavigationIndex + 1,
    );
    _persist();
  }

  void clear() {
    state = state.copyWith(recentEntries: const []);
    _persist();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HistoryNotifier(prefs);
});

final canGoBackProvider = Provider<bool>((ref) {
  return ref.watch(historyProvider).canGoBack;
});

final canGoForwardProvider = Provider<bool>((ref) {
  return ref.watch(historyProvider).canGoForward;
});
