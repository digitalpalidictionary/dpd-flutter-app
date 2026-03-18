import 'package:dpd_flutter_app/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Settings copyWith', () {
    test('returns same values when no overrides provided', () {
      const settings = Settings(
        oneButtonAtATime: true,
        niggahitaMode: NiggahitaMode.dot,
        showSummary: true,
        showSandhiApostrophe: true,
        audioGender: AudioGender.male,
      );
      final copy = settings.copyWith();
      expect(copy.themeMode, ThemeMode.system);
      expect(copy.fontSize, 16.0);
      expect(copy.useSerifFont, false);
      expect(copy.grammarOpen, false);
      expect(copy.examplesOpen, false);
      expect(copy.displayMode, DisplayMode.compact);
      expect(copy.oneButtonAtATime, true);
      expect(copy.niggahitaMode, NiggahitaMode.dot);
      expect(copy.showSummary, true);
      expect(copy.showSandhiApostrophe, true);
      expect(copy.audioGender, AudioGender.male);
    });

    test('copyWith overrides oneButtonAtATime', () {
      const settings = Settings();
      final copy = settings.copyWith(oneButtonAtATime: false);
      expect(copy.oneButtonAtATime, false);
      expect(copy.niggahitaMode, NiggahitaMode.dot);
    });

    test('copyWith overrides niggahitaMode', () {
      const settings = Settings();
      final copy = settings.copyWith(niggahitaMode: NiggahitaMode.circle);
      expect(copy.niggahitaMode, NiggahitaMode.circle);
      expect(copy.oneButtonAtATime, true);
    });

    test('copyWith overrides showSummary', () {
      const settings = Settings();
      final copy = settings.copyWith(showSummary: false);
      expect(copy.showSummary, false);
    });

    test('copyWith overrides showSandhiApostrophe', () {
      const settings = Settings();
      final copy = settings.copyWith(showSandhiApostrophe: false);
      expect(copy.showSandhiApostrophe, false);
    });

    test('copyWith overrides audioGender', () {
      const settings = Settings();
      final copy = settings.copyWith(audioGender: AudioGender.female);
      expect(copy.audioGender, AudioGender.female);
    });

    test('copyWith preserves other fields when overriding one', () {
      const settings = Settings(
        fontSize: 20.0,
        useSerifFont: true,
        grammarOpen: true,
        examplesOpen: true,
        displayMode: DisplayMode.classic,
        oneButtonAtATime: false,
        niggahitaMode: NiggahitaMode.circle,
        showSummary: false,
        showSandhiApostrophe: false,
        audioGender: AudioGender.female,
      );
      final copy = settings.copyWith(fontSize: 18.0);
      expect(copy.fontSize, 18.0);
      expect(copy.useSerifFont, true);
      expect(copy.grammarOpen, true);
      expect(copy.examplesOpen, true);
      expect(copy.displayMode, DisplayMode.classic);
      expect(copy.oneButtonAtATime, false);
      expect(copy.niggahitaMode, NiggahitaMode.circle);
      expect(copy.showSummary, false);
      expect(copy.showSandhiApostrophe, false);
      expect(copy.audioGender, AudioGender.female);
    });
  });

  group('Settings equality', () {
    test('two default Settings are equal', () {
      const a = Settings();
      const b = Settings();
      expect(a, equals(b));
    });

    test('Settings with same non-default values are equal', () {
      const a = Settings(
        oneButtonAtATime: false,
        niggahitaMode: NiggahitaMode.circle,
        showSummary: false,
        showSandhiApostrophe: false,
        audioGender: AudioGender.female,
      );
      const b = Settings(
        oneButtonAtATime: false,
        niggahitaMode: NiggahitaMode.circle,
        showSummary: false,
        showSandhiApostrophe: false,
        audioGender: AudioGender.female,
      );
      expect(a, equals(b));
    });

    test('Settings with different oneButtonAtATime are not equal', () {
      const a = Settings(oneButtonAtATime: true);
      const b = Settings(oneButtonAtATime: false);
      expect(a, isNot(equals(b)));
    });

    test('Settings with different niggahitaMode are not equal', () {
      const a = Settings(niggahitaMode: NiggahitaMode.dot);
      const b = Settings(niggahitaMode: NiggahitaMode.circle);
      expect(a, isNot(equals(b)));
    });

    test('Settings with different showSummary are not equal', () {
      const a = Settings(showSummary: true);
      const b = Settings(showSummary: false);
      expect(a, isNot(equals(b)));
    });

    test('Settings with different showSandhiApostrophe are not equal', () {
      const a = Settings(showSandhiApostrophe: true);
      const b = Settings(showSandhiApostrophe: false);
      expect(a, isNot(equals(b)));
    });

    test('Settings with different audioGender are not equal', () {
      const a = Settings(audioGender: AudioGender.male);
      const b = Settings(audioGender: AudioGender.female);
      expect(a, isNot(equals(b)));
    });
  });

  group('Settings defaults', () {
    test('default oneButtonAtATime is true', () {
      expect(const Settings().oneButtonAtATime, true);
    });

    test('default niggahitaMode is dot (ṃ)', () {
      expect(const Settings().niggahitaMode, NiggahitaMode.dot);
    });

    test('default showSummary is true', () {
      expect(const Settings().showSummary, true);
    });

    test('default showSandhiApostrophe is true', () {
      expect(const Settings().showSandhiApostrophe, true);
    });

    test('default audioGender is male', () {
      expect(const Settings().audioGender, AudioGender.male);
    });

    test('default lookupHotkey is empty', () {
      expect(const Settings().lookupHotkey, '');
    });
  });
}
