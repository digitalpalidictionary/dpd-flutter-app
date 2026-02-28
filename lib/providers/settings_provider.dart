import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DisplayMode { inline, accordion, bottomSheet }

class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.fontSize = 16.0,
    this.useSerifFont = false,
    this.grammarOpen = false,
    this.examplesOpen = false,
    this.displayMode = DisplayMode.accordion,
  });

  final ThemeMode themeMode;
  final double fontSize;
  final bool useSerifFont;
  final bool grammarOpen;
  final bool examplesOpen;
  final DisplayMode displayMode;

  Settings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    bool? useSerifFont,
    bool? grammarOpen,
    bool? examplesOpen,
    DisplayMode? displayMode,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      useSerifFont: useSerifFont ?? this.useSerifFont,
      grammarOpen: grammarOpen ?? this.grammarOpen,
      examplesOpen: examplesOpen ?? this.examplesOpen,
      displayMode: displayMode ?? this.displayMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier(this._prefs) : super(const Settings()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final themeName = _prefs.getString('theme_mode') ?? 'system';
    final themeMode = switch (themeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final fontSize = _prefs.getDouble('font_size') ?? 16.0;
    final useSerifFont = _prefs.getBool('use_serif_font') ?? false;
    final grammarOpen = _prefs.getBool('grammar_open') ?? false;
    final examplesOpen = _prefs.getBool('examples_open') ?? false;
    final modeName = _prefs.getString('display_mode') ?? 'accordion';
    final displayMode = DisplayMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => DisplayMode.accordion,
    );
    state = Settings(
      themeMode: themeMode,
      fontSize: fontSize,
      useSerifFont: useSerifFont,
      grammarOpen: grammarOpen,
      examplesOpen: examplesOpen,
      displayMode: displayMode,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString('theme_mode', mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setFontSize(double size) async {
    await _prefs.setDouble('font_size', size);
    state = state.copyWith(fontSize: size);
  }

  Future<void> setUseSerifFont(bool value) async {
    await _prefs.setBool('use_serif_font', value);
    state = state.copyWith(useSerifFont: value);
  }

  Future<void> setGrammarOpen(bool value) async {
    await _prefs.setBool('grammar_open', value);
    state = state.copyWith(grammarOpen: value);
  }

  Future<void> setExamplesOpen(bool value) async {
    await _prefs.setBool('examples_open', value);
    state = state.copyWith(examplesOpen: value);
  }

  Future<void> setDisplayMode(DisplayMode mode) async {
    await _prefs.setString('display_mode', mode.name);
    state = state.copyWith(displayMode: mode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
