import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';

/// Shared settings content widget used by both the bottom sheet and side
/// drawer variants.
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
        // Result style — top position
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
            divisions: 6,
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
          title: const Text('Settings panel [dev]'),
          trailing: _CompactSegmented<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Sheet')),
              ButtonSegment(value: false, label: Text('Drawer')),
            ],
            selected: settings.useBottomSheetSettings,
            onChanged: notifier.setUseBottomSheetSettings,
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

/// Bottom sheet settings overlay.
class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DpdColors.borderRadiusValue),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Flexible(child: SettingsContent()),
        ],
      ),
    );
  }
}

/// Side drawer settings overlay (slides in from the right).
class SettingsSideDrawer extends StatelessWidget {
  const SettingsSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
        width: screenWidth * 0.85,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(DpdColors.borderRadiusValue),
          ),
          boxShadow: DpdColors.shadowHover,
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Text(
                      'Settings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            const Expanded(child: SettingsContent()),
          ],
        ),
        ),
      ),
    );
  }
}

/// A simple switch row with no checkmark icon — just a coloured Switch.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}

/// A compact SegmentedButton suitable for use as a ListTile trailing widget.
class _CompactSegmented<T> extends StatelessWidget {
  const _CompactSegmented({
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<ButtonSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
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

/// Shows the settings overlay (bottom sheet or side drawer) based on the
/// current [Settings.useBottomSheetSettings] preference.
Future<void> showSettingsOverlay(BuildContext context, bool useBottomSheet) {
  if (useBottomSheet) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, controller) => const SettingsBottomSheet(),
      ),
    );
  } else {
    return showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => const SettingsSideDrawer(),
    );
  }
}
