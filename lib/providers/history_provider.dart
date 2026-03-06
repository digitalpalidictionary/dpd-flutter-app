import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_provider.dart';

const _maxEntries = 50;
const _prefsKey = 'dpd_history';

class HistoryState {
  const HistoryState({
    this.entries = const [],
    this.currentIndex = -1,
  });

  final List<String> entries;
  final int currentIndex;

  HistoryState copyWith({
    List<String>? entries,
    int? currentIndex,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  String? get currentEntry =>
      currentIndex >= 0 && currentIndex < entries.length
          ? entries[currentIndex]
          : null;

  bool get canGoBack => currentIndex < entries.length - 1;
  bool get canGoForward => currentIndex > 0;
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._prefs) : super(const HistoryState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final json = _prefs.getString(_prefsKey);
    if (json != null) {
      final list = (jsonDecode(json) as List).cast<String>();
      state = HistoryState(entries: list, currentIndex: -1);
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(_prefsKey, jsonEncode(state.entries));
  }

  void add(String term) {
    if (term.isEmpty) return;
    final entries = List<String>.from(state.entries);
    entries.remove(term);
    entries.insert(0, term);
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }
    state = HistoryState(entries: entries, currentIndex: 0);
    _persist();
  }

  void resetPosition() {
    state = state.copyWith(currentIndex: -1);
  }

  void goBack() {
    if (!state.canGoBack) return;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void goForward() {
    if (!state.canGoForward) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void clear() {
    state = const HistoryState();
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
