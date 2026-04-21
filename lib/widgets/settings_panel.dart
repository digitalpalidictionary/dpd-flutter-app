import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_update_provider.dart';
import '../providers/settings_provider.dart';
import '../services/intent_service.dart';
import '../theme/dpd_colors.dart';
import 'compact_segmented.dart';
import 'dict_settings_widget.dart';
import 'settings_help_dialog.dart';

class SettingsContent extends ConsumerStatefulWidget {
  const SettingsContent({super.key});

  @override
  ConsumerState<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<SettingsContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final updateState = ref.watch(dbUpdateProvider);

    Widget buildDivider() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(color: theme.colorScheme.outlineVariant),
      );
    }

    final itemBuilders = <Widget Function()>[
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text('Settings', style: theme.textTheme.titleLarge),
      ),
      () => _buildSettingTile(
        title: 'Result style',
        topic: _resultStyleTopic(),
        trailing: CompactSegmented<DisplayMode>(
          segments: const [
            ButtonSegment(value: DisplayMode.classic, label: Text('Classic')),
            ButtonSegment(value: DisplayMode.compact, label: Text('Compact')),
          ],
          selected: settings.displayMode,
          onChanged: notifier.setDisplayMode,
        ),
      ),
      () => _buildSettingTile(
        title: 'Theme',
        topic: _themeTopic(),
        trailing: CompactSegmented<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: settings.themeMode,
          onChanged: notifier.setThemeMode,
        ),
      ),
      buildDivider,
      () => _buildSettingTile(
        title: 'Font size',
        topic: _fontSizeTopic(theme),
        trailing: Text(
          settings.fontSize.toStringAsFixed(0),
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: Slider(
          value: settings.fontSize,
          min: 12,
          max: 24,
          divisions: 12,
          label: settings.fontSize.toStringAsFixed(0),
          onChanged: notifier.setFontSize,
        ),
      ),
      () => _buildSettingTile(
        title: 'Font',
        topic: _fontTopic(theme),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Sans')),
            ButtonSegment(value: true, label: Text('Serif')),
          ],
          selected: settings.useSerifFont,
          onChanged: notifier.setUseSerifFont,
        ),
      ),
      () => _buildSettingTile(
        title: 'Niggahīta',
        topic: _niggahitaTopic(),
        trailing: CompactSegmented<NiggahitaMode>(
          segments: const [
            ButtonSegment(value: NiggahitaMode.dot, label: Text('ṃ')),
            ButtonSegment(value: NiggahitaMode.circle, label: Text('ṁ')),
          ],
          selected: settings.niggahitaMode,
          onChanged: notifier.setNiggahitaMode,
        ),
      ),
      () => _buildSettingTile(
        title: 'Sandhi apostrophes',
        topic: _sandhiTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Hide')),
            ButtonSegment(value: true, label: Text('Show')),
          ],
          selected: settings.showSandhiApostrophe,
          onChanged: notifier.setShowSandhiApostrophe,
        ),
      ),
      buildDivider,
      () => _buildSettingTile(
        title: 'Construction in summary',
        topic: _constructionTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Hide')),
            ButtonSegment(value: true, label: Text('Show')),
          ],
          selected: settings.showConstructionInSummary,
          onChanged: notifier.setShowConstructionInSummary,
        ),
      ),
      () => _buildSettingTile(
        title: 'Grammar button',
        topic: _grammarButtonTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Closed')),
            ButtonSegment(value: true, label: Text('Open')),
          ],
          selected: settings.grammarOpen,
          onChanged: notifier.setGrammarOpen,
        ),
      ),
      () => _buildSettingTile(
        title: 'Examples button',
        topic: _examplesButtonTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Closed')),
            ButtonSegment(value: true, label: Text('Open')),
          ],
          selected: settings.examplesOpen,
          onChanged: notifier.setExamplesOpen,
        ),
      ),
      () => _buildSettingTile(
        title: 'One button at a time',
        topic: _oneButtonTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Off')),
            ButtonSegment(value: true, label: Text('On')),
          ],
          selected: settings.oneButtonAtATime,
          onChanged: notifier.setOneButtonAtATime,
        ),
      ),
      buildDivider,
      () => _buildSettingTile(
        title: 'Audio gender',
        topic: _audioGenderTopic(),
        trailing: CompactSegmented<AudioGender>(
          segments: const [
            ButtonSegment(value: AudioGender.male, label: Text('Male')),
            ButtonSegment(value: AudioGender.female, label: Text('Female')),
          ],
          selected: settings.audioGender,
          onChanged: notifier.setAudioGender,
        ),
      ),
      () => _buildSettingTile(
        title: 'Word search tap',
        topic: _wordSearchTapTopic(),
        trailing: CompactSegmented<TapMode>(
          segments: const [
            ButtonSegment(value: TapMode.singleTap, label: Text('Single')),
            ButtonSegment(value: TapMode.doubleTap, label: Text('Double')),
          ],
          selected: settings.tapMode,
          onChanged: notifier.setTapMode,
        ),
      ),
      () => _buildSettingTile(
        title: 'Updates',
        topic: _updatesTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Any')),
            ButtonSegment(value: true, label: Text('WiFi')),
          ],
          selected: settings.wifiOnlyUpdates,
          onChanged: notifier.setWifiOnlyUpdates,
        ),
      ),
      if (Platform.isLinux)
        () => _HotkeyTile(
          hotkey: settings.lookupHotkey,
          onChanged: notifier.setLookupHotkey,
        ),
      buildDivider,
      () => _buildSettingTile(
        title: 'Partial results',
        topic: _partialResultsTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Hide')),
            ButtonSegment(value: true, label: Text('Show')),
          ],
          selected: settings.showPartialResults,
          onChanged: notifier.setShowPartialResults,
        ),
      ),
      () => _buildSettingTile(
        title: 'Fuzzy results',
        topic: _fuzzyResultsTopic(),
        trailing: CompactSegmented<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Hide')),
            ButtonSegment(value: true, label: Text('Show')),
          ],
          selected: settings.showFuzzyResults,
          onChanged: notifier.setShowFuzzyResults,
        ),
      ),
      () => const DictSettingsWidget(),
      () => const SizedBox(height: 16),
      buildDivider,
      () => ListTile(
        dense: true,
        title: Text(
          'App ${ref.watch(appVersionProvider).valueOrNull ?? "…"}  ·  Database ${updateState.localVersion ?? "unknown"}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          borderRadius: DpdColors.borderRadius,
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: itemBuilders.length,
          itemBuilder: (context, index) => itemBuilders[index](),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required SettingHelpTopic topic,
    required Widget trailing,
    Widget? subtitle,
  }) {
    return ListTile(
      title: Row(
        children: [
          Flexible(child: Text(title)),
          const SizedBox(width: 4),
          SettingHelpButton(topic: topic),
        ],
      ),
      subtitle: subtitle,
      trailing: trailing,
    );
  }

  SettingHelpTopic _resultStyleTopic() {
    return const SettingHelpTopic(
      title: 'Result style',
      description: 'Changes how search results are laid out on the screen.',
    );
  }

  SettingHelpTopic _themeTopic() {
    return const SettingHelpTopic(
      title: 'Theme',
      description:
          'Chooses whether the app follows your device theme or stays light or dark.',
    );
  }

  SettingHelpTopic _fontSizeTopic(ThemeData theme) {
    return const SettingHelpTopic(
      title: 'Font size',
      description: 'Makes text throughout the app smaller or larger.',
    );
  }

  SettingHelpTopic _fontTopic(ThemeData theme) {
    return const SettingHelpTopic(
      title: 'Font',
      description: 'Changes the reading font used in the app.',
    );
  }

  SettingHelpTopic _niggahitaTopic() {
    return const SettingHelpTopic(
      title: 'Niggahīta',
      description: 'Chooses which niggahīta character style the app displays.',
    );
  }

  SettingHelpTopic _sandhiTopic() {
    return const SettingHelpTopic(
      title: 'Sandhi apostrophes',
      description:
          'Shows or hides apostrophes used to mark sandhi in displayed words.',
    );
  }

  SettingHelpTopic _constructionTopic() {
    return const SettingHelpTopic(
      title: 'Construction in summary',
      description: 'Shows or hides construction notes in the entry summary.',
    );
  }

  SettingHelpTopic _grammarButtonTopic() {
    return const SettingHelpTopic(
      title: 'Grammar button',
      description: 'Sets whether the grammar section starts open or closed.',
    );
  }

  SettingHelpTopic _examplesButtonTopic() {
    return const SettingHelpTopic(
      title: 'Examples button',
      description: 'Sets whether the examples section starts open or closed.',
    );
  }

  SettingHelpTopic _oneButtonTopic() {
    return const SettingHelpTopic(
      title: 'One button at a time',
      description: 'Opening one entry section closes the others automatically.',
    );
  }

  SettingHelpTopic _audioGenderTopic() {
    return const SettingHelpTopic(
      title: 'Audio gender',
      description: 'Chooses which voice is used for available audio.',
    );
  }

  SettingHelpTopic _wordSearchTapTopic() {
    return const SettingHelpTopic(
      title: 'Word search tap',
      description:
          'Chooses whether word lookup inside entries uses a single tap or double tap.',
    );
  }

  SettingHelpTopic _updatesTopic() {
    return const SettingHelpTopic(
      title: 'Updates',
      description:
          'Chooses whether updates can download on any connection or only on WiFi.',
    );
  }

  SettingHelpTopic _partialResultsTopic() {
    return const SettingHelpTopic(
      title: 'Partial results',
      description:
          'Shows or hides search results that partly match what you typed.',
    );
  }

  SettingHelpTopic _fuzzyResultsTopic() {
    return const SettingHelpTopic(
      title: 'Fuzzy results',
      description: 'Shows or hides close spelling matches in search results.',
    );
  }
}

class _HotkeyTile extends StatelessWidget {
  const _HotkeyTile({required this.hotkey, required this.onChanged});

  final String hotkey;
  final Future<void> Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = hotkey.isEmpty ? 'Not set' : _gsettingsToDisplay(hotkey);

    return ListTile(
      title: Row(
        children: [
          const Flexible(child: Text('Lookup hotkey')),
          const SizedBox(width: 4),
          SettingHelpButton(topic: _lookupHotkeyTopic()),
        ],
      ),
      subtitle: Text(
        'Highlight text in any app, press hotkey to search in DPD.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => _recordHotkey(context),
            child: Text(display),
          ),
          if (hotkey.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                onChanged('');
                IntentService.unbindHotkey();
              },
              tooltip: 'Clear hotkey',
            ),
        ],
      ),
    );
  }

  SettingHelpTopic _lookupHotkeyTopic() {
    return const SettingHelpTopic(
      title: 'Lookup hotkey',
      description:
          'Lets you set a keyboard shortcut to send highlighted text from another app into DPD.',
    );
  }

  Future<void> _recordHotkey(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _HotkeyRecorderDialog(),
    );
    if (result != null) {
      onChanged(result);
      IntentService.bindHotkey(result);
    }
  }

  static String _gsettingsToDisplay(String gs) {
    var s = gs;
    final parts = <String>[];
    if (s.contains('<Control>') || s.contains('<Primary>')) {
      parts.add('Ctrl');
      s = s.replaceAll('<Control>', '').replaceAll('<Primary>', '');
    }
    if (s.contains('<Alt>')) {
      parts.add('Alt');
      s = s.replaceAll('<Alt>', '');
    }
    if (s.contains('<Super>')) {
      parts.add('Super');
      s = s.replaceAll('<Super>', '');
    }
    if (s.contains('<Shift>')) {
      parts.add('Shift');
      s = s.replaceAll('<Shift>', '');
    }
    if (s.isNotEmpty) {
      parts.add(s.toUpperCase());
    }
    return parts.join(' + ');
  }
}

class _HotkeyRecorderDialog extends StatefulWidget {
  const _HotkeyRecorderDialog();

  @override
  State<_HotkeyRecorderDialog> createState() => _HotkeyRecorderDialogState();
}

class _HotkeyRecorderDialogState extends State<_HotkeyRecorderDialog> {
  String _display = 'Press your desired key combination…';
  String? _gsettingsValue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Hotkey'),
      content: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: _onKey,
        child: SizedBox(
          width: 300,
          height: 60,
          child: Center(
            child: Text(
              _display,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _gsettingsValue != null
              ? () => Navigator.of(context).pop(_gsettingsValue)
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    // Ignore bare modifier keys
    if (_isModifier(key)) return;

    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final alt = HardwareKeyboard.instance.isAltPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final supe = HardwareKeyboard.instance.isMetaPressed;

    if (!ctrl && !alt && !supe) return;

    final displayParts = <String>[];
    final gsParts = StringBuffer();
    if (ctrl) {
      displayParts.add('Ctrl');
      gsParts.write('<Control>');
    }
    if (alt) {
      displayParts.add('Alt');
      gsParts.write('<Alt>');
    }
    if (supe) {
      displayParts.add('Super');
      gsParts.write('<Super>');
    }
    if (shift) {
      displayParts.add('Shift');
      gsParts.write('<Shift>');
    }

    final keyLabel = key.keyLabel;
    displayParts.add(keyLabel.toUpperCase());
    gsParts.write(keyLabel.toLowerCase());

    setState(() {
      _display = displayParts.join(' + ');
      _gsettingsValue = gsParts.toString();
    });
  }

  bool _isModifier(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight;
  }
}

/// Shows the settings bottom sheet. Tapping outside dismisses it.
Future<void> showSettingsOverlay(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DpdColors.borderRadiusValue),
      ),
    ),
    builder: (context) {
      final theme = Theme.of(context);
      return SizedBox(
        height: screenHeight * 0.55,
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Expanded(child: SettingsContent()),
          ],
        ),
      );
    },
  );
}
