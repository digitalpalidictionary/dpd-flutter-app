import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: const Text('Result style'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<DisplayMode>(
              segments: const [
                ButtonSegment(value: DisplayMode.classic, label: Text('Classic')),
                ButtonSegment(value: DisplayMode.compact, label: Text('Compact')),
                ButtonSegment(value: DisplayMode.bottomDrawer, label: Text('Bottom')),
              ],
              selected: {settings.displayMode},
              onSelectionChanged: (s) => notifier.setDisplayMode(s.first),
            ),
          ),
        ),
        ListTile(
          title: const Text('Theme'),
          trailing: DropdownButton<ThemeMode>(
            value: settings.themeMode,
            underline: const SizedBox.shrink(),
            onChanged: (mode) {
              if (mode != null) notifier.setThemeMode(mode);
            },
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
          ),
        ),
        ListTile(
          title: const Text('Font size'),
          subtitle: Slider(
            value: settings.fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: settings.fontSize.toStringAsFixed(0),
            onChanged: notifier.setFontSize,
          ),
        ),
        _ToggleRow(
          title: 'Serif font',
          value: settings.useSerifFont,
          onChanged: notifier.setUseSerifFont,
        ),
        _ToggleRow(
          title: 'Grammar open by default',
          value: settings.grammarOpen,
          onChanged: notifier.setGrammarOpen,
        ),
        _ToggleRow(
          title: 'Examples open by default',
          value: settings.examplesOpen,
          onChanged: notifier.setExamplesOpen,
        ),
        _ToggleRow(
          title: 'One section at a time',
          value: settings.oneButtonAtATime,
          onChanged: notifier.setOneButtonAtATime,
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
        _ToggleRow(
          title: 'Show sandhi apostrophes',
          value: settings.showSandhiApostrophe,
          onChanged: notifier.setShowSandhiApostrophe,
        ),
        _ToggleRow(
          title: 'Show summary box',
          value: settings.showSummary,
          onChanged: notifier.setShowSummary,
        ),
        ListTile(
          enabled: false,
          title: const Text('Audio gender'),
          trailing: _CompactSegmented<AudioGender>(
            segments: const [
              ButtonSegment(value: AudioGender.male, label: Text('Male')),
              ButtonSegment(value: AudioGender.female, label: Text('Female')),
            ],
            selected: settings.audioGender,
            onChanged: notifier.setAudioGender,
            enabled: false,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: theme.colorScheme.outlineVariant),
        ),
        ListTile(
          dense: true,
          title: Text(
            'Version 0.1.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple switch row with no checkmark icon — just a coloured Switch.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled ? () => onChanged(!value) : null,
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

/// Shows the settings bottom sheet. Tapping outside dismisses it.
Future<void> showSettingsOverlay(BuildContext context) {
  final theme = Theme.of(context);
  final screenHeight = MediaQuery.of(context).size.height;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DpdColors.borderRadiusValue),
      ),
    ),
    builder: (context) {
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
