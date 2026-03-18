import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_update_provider.dart';
import '../providers/database_update_provider.dart';
import '../providers/settings_provider.dart';
import '../services/database_update_service.dart';
import '../services/intent_service.dart';
import '../theme/dpd_colors.dart';

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final updateState = ref.watch(dbUpdateProvider);
    final appUpdateState = ref.watch(appUpdateProvider);
    final theme = Theme.of(context);

    final isUpdating = appUpdateState.status == AppUpdateStatus.checking ||
        appUpdateState.status == AppUpdateStatus.downloading ||
        updateState.status == DbStatus.downloading ||
        updateState.status == DbStatus.extracting;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            borderRadius: DpdColors.borderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Settings', style: theme.textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: FilledButton.icon(
            onPressed: isUpdating
                ? null
                : () {
                    ref.read(appUpdateProvider.notifier).manualCheck();
                    ref
                        .read(dbUpdateProvider.notifier)
                        .manualCheckForUpdates();
                  },
            icon: isUpdating
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.update),
            label: Text(isUpdating ? 'Updating…' : 'Update Now'),
          ),
        ),
        ListTile(
          title: const Text('Result style'),
          trailing: _CompactSegmented<DisplayMode>(
            segments: const [
              ButtonSegment(value: DisplayMode.classic, label: Text('Classic')),
              ButtonSegment(value: DisplayMode.compact, label: Text('Compact')),
            ],
            selected: settings.displayMode,
            onChanged: notifier.setDisplayMode,
          ),
        ),
        ListTile(
          title: const Text('Theme'),
          trailing: _CompactSegmented<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: settings.themeMode,
            onChanged: notifier.setThemeMode,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Font size'),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: settings.fontSize.toStringAsFixed(0),
                  onChanged: notifier.setFontSize,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('Font'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Sans')),
              ButtonSegment(value: true, label: Text('Serif')),
            ],
            selected: settings.useSerifFont,
            onChanged: notifier.setUseSerifFont,
          ),
        ),
        ListTile(
          title: const Text('Grammar'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Closed')),
              ButtonSegment(value: true, label: Text('Open')),
            ],
            selected: settings.grammarOpen,
            onChanged: notifier.setGrammarOpen,
          ),
        ),
        ListTile(
          title: const Text('Examples'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Closed')),
              ButtonSegment(value: true, label: Text('Open')),
            ],
            selected: settings.examplesOpen,
            onChanged: notifier.setExamplesOpen,
          ),
        ),
        ListTile(
          title: const Text('One section at a time'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Off')),
              ButtonSegment(value: true, label: Text('On')),
            ],
            selected: settings.oneButtonAtATime,
            onChanged: notifier.setOneButtonAtATime,
          ),
        ),
        ListTile(
          title: const Text('Niggahīta'),
          trailing: _CompactSegmented<NiggahitaMode>(
            segments: const [
              ButtonSegment(value: NiggahitaMode.dot, label: Text('ṃ')),
              ButtonSegment(value: NiggahitaMode.circle, label: Text('ṁ')),
            ],
            selected: settings.niggahitaMode,
            onChanged: notifier.setNiggahitaMode,
          ),
        ),
        ListTile(
          title: const Text('Sandhi apostrophes'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Hide')),
              ButtonSegment(value: true, label: Text('Show')),
            ],
            selected: settings.showSandhiApostrophe,
            onChanged: notifier.setShowSandhiApostrophe,
          ),
        ),
        ListTile(
          title: const Text('Summary'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Hide')),
              ButtonSegment(value: true, label: Text('Show')),
            ],
            selected: settings.showSummary,
            onChanged: notifier.setShowSummary,
          ),
        ),
        ListTile(
          title: const Text('Audio gender'),
          trailing: _CompactSegmented<AudioGender>(
            segments: const [
              ButtonSegment(value: AudioGender.male, label: Text('Male')),
              ButtonSegment(value: AudioGender.female, label: Text('Female')),
            ],
            selected: settings.audioGender,
            onChanged: notifier.setAudioGender,
          ),
        ),
        ListTile(
          title: const Text('Updates'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Any')),
              ButtonSegment(value: true, label: Text('WiFi')),
            ],
            selected: settings.wifiOnlyUpdates,
            onChanged: notifier.setWifiOnlyUpdates,
          ),
        ),
        if (Platform.isLinux)
          _HotkeyTile(
            hotkey: settings.lookupHotkey,
            onChanged: notifier.setLookupHotkey,
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: theme.colorScheme.outlineVariant),
        ),
        ListTile(
          dense: true,
          title: Text(
            'App ${ref.watch(appVersionProvider).valueOrNull ?? "…"}  ·  Database ${updateState.localVersion ?? "unknown"}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A compact SegmentedButton suitable for use as a ListTile trailing widget.
class _CompactSegmented<T> extends StatelessWidget {
  const _CompactSegmented({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<ButtonSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: {selected},
      onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
      ),
      showSelectedIcon: false,
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
      title: const Text('Lookup hotkey'),
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
          onPressed:
              _gsettingsValue != null
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
