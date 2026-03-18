import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DisplayMode { classic, compact }

enum NiggahitaMode { dot, circle }

enum AudioGender { male, female }

class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.fontSize = 16.0,
    this.useSerifFont = false,
    this.grammarOpen = false,
    this.examplesOpen = false,
    this.displayMode = DisplayMode.classic,
    this.oneButtonAtATime = true,
    this.niggahitaMode = NiggahitaMode.dot,
    this.showSummary = true,
    this.showSandhiApostrophe = true,
    this.audioGender = AudioGender.male,
    this.wifiOnlyUpdates = false,
    this.lookupHotkey = '',
  });

  final ThemeMode themeMode;
  final double fontSize;
  final bool useSerifFont;
  final bool grammarOpen;
  final bool examplesOpen;
  final DisplayMode displayMode;
  final bool oneButtonAtATime;
  final NiggahitaMode niggahitaMode;
  final bool showSummary;
  final bool showSandhiApostrophe;
  final AudioGender audioGender;
  final bool wifiOnlyUpdates;
  final String lookupHotkey;

  Settings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    bool? useSerifFont,
    bool? grammarOpen,
    bool? examplesOpen,
    DisplayMode? displayMode,
    bool? oneButtonAtATime,
    NiggahitaMode? niggahitaMode,
    bool? showSummary,
    bool? showSandhiApostrophe,
    AudioGender? audioGender,
    bool? wifiOnlyUpdates,
    String? lookupHotkey,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      useSerifFont: useSerifFont ?? this.useSerifFont,
      grammarOpen: grammarOpen ?? this.grammarOpen,
      examplesOpen: examplesOpen ?? this.examplesOpen,
      displayMode: displayMode ?? this.displayMode,
      oneButtonAtATime: oneButtonAtATime ?? this.oneButtonAtATime,
      niggahitaMode: niggahitaMode ?? this.niggahitaMode,
      showSummary: showSummary ?? this.showSummary,
      showSandhiApostrophe: showSandhiApostrophe ?? this.showSandhiApostrophe,
      audioGender: audioGender ?? this.audioGender,
      wifiOnlyUpdates: wifiOnlyUpdates ?? this.wifiOnlyUpdates,
      lookupHotkey: lookupHotkey ?? this.lookupHotkey,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.themeMode == themeMode &&
        other.fontSize == fontSize &&
        other.useSerifFont == useSerifFont &&
        other.grammarOpen == grammarOpen &&
        other.examplesOpen == examplesOpen &&
        other.displayMode == displayMode &&
        other.oneButtonAtATime == oneButtonAtATime &&
        other.niggahitaMode == niggahitaMode &&
        other.showSummary == showSummary &&
        other.showSandhiApostrophe == showSandhiApostrophe &&
        other.audioGender == audioGender &&
        other.wifiOnlyUpdates == wifiOnlyUpdates &&
        other.lookupHotkey == lookupHotkey;
  }

  @override
  int get hashCode => Object.hash(
    themeMode,
    fontSize,
    useSerifFont,
    grammarOpen,
    examplesOpen,
    displayMode,
    oneButtonAtATime,
    niggahitaMode,
    showSummary,
    showSandhiApostrophe,
    audioGender,
    wifiOnlyUpdates,
    lookupHotkey,
  );
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
    final modeName = _prefs.getString('display_mode') ?? 'classic';
    final displayMode = DisplayMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => DisplayMode.compact,
    );
    final oneButtonAtATime = _prefs.getBool('one_button_at_a_time') ?? true;
    final niggahitaName = _prefs.getString('niggahita_mode') ?? 'dot';
    final niggahitaMode = NiggahitaMode.values.firstWhere(
      (m) => m.name == niggahitaName,
      orElse: () => NiggahitaMode.dot,
    );
    final showSummary = _prefs.getBool('show_summary') ?? true;
    final showSandhiApostrophe =
        _prefs.getBool('show_sandhi_apostrophe') ?? true;
    final audioGenderName = _prefs.getString('audio_gender') ?? 'male';
    final audioGender = AudioGender.values.firstWhere(
      (g) => g.name == audioGenderName,
      orElse: () => AudioGender.male,
    );
    final wifiOnlyUpdates = _prefs.getBool('wifi_only_updates') ?? false;
    final lookupHotkey = _prefs.getString('lookup_hotkey') ?? '';
    state = Settings(
      themeMode: themeMode,
      fontSize: fontSize,
      useSerifFont: useSerifFont,
      grammarOpen: grammarOpen,
      examplesOpen: examplesOpen,
      displayMode: displayMode,
      oneButtonAtATime: oneButtonAtATime,
      niggahitaMode: niggahitaMode,
      showSummary: showSummary,
      showSandhiApostrophe: showSandhiApostrophe,
      audioGender: audioGender,
      wifiOnlyUpdates: wifiOnlyUpdates,
      lookupHotkey: lookupHotkey,
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

  Future<void> setOneButtonAtATime(bool value) async {
    await _prefs.setBool('one_button_at_a_time', value);
    state = state.copyWith(oneButtonAtATime: value);
  }

  Future<void> setNiggahitaMode(NiggahitaMode mode) async {
    await _prefs.setString('niggahita_mode', mode.name);
    state = state.copyWith(niggahitaMode: mode);
  }

  Future<void> setShowSummary(bool value) async {
    await _prefs.setBool('show_summary', value);
    state = state.copyWith(showSummary: value);
  }

  Future<void> setShowSandhiApostrophe(bool value) async {
    await _prefs.setBool('show_sandhi_apostrophe', value);
    state = state.copyWith(showSandhiApostrophe: value);
  }

  Future<void> setAudioGender(AudioGender gender) async {
    await _prefs.setString('audio_gender', gender.name);
    state = state.copyWith(audioGender: gender);
  }

  Future<void> setWifiOnlyUpdates(bool value) async {
    await _prefs.setBool('wifi_only_updates', value);
    state = state.copyWith(wifiOnlyUpdates: value);
  }

  Future<void> setLookupHotkey(String value) async {
    await _prefs.setString('lookup_hotkey', value);
    state = state.copyWith(lookupHotkey: value);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});
