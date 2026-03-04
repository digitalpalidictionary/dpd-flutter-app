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
        _SectionHeader('Display'),
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
        SwitchListTile(
          title: const Text('Serif font'),
          subtitle: Text(settings.useSerifFont ? 'Serif' : 'Sans-serif'),
          value: settings.useSerifFont,
          onChanged: notifier.setUseSerifFont,
        ),
        ListTile(
          title: const Text('Result style'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<DisplayMode>(
              segments: const [
                ButtonSegment(value: DisplayMode.inline, label: Text('Webapp')),
                ButtonSegment(
                  value: DisplayMode.accordion,
                  label: Text('Accordion'),
                ),
                ButtonSegment(
                  value: DisplayMode.bottomSheet,
                  label: Text('Sheet'),
                ),
              ],
              selected: {settings.displayMode},
              onSelectionChanged: (s) => notifier.setDisplayMode(s.first),
            ),
          ),
        ),
        _SectionHeader('Sections'),
        SwitchListTile(
          title: const Text('Grammar open by default'),
          value: settings.grammarOpen,
          onChanged: notifier.setGrammarOpen,
        ),
        SwitchListTile(
          title: const Text('Examples open by default'),
          value: settings.examplesOpen,
          onChanged: notifier.setExamplesOpen,
        ),
        SwitchListTile(
          title: const Text('One section at a time'),
          subtitle: const Text('Opening one section closes others'),
          value: settings.oneButtonAtATime,
          onChanged: notifier.setOneButtonAtATime,
        ),
        _SectionHeader('Pāḷi Text'),
        ListTile(
          title: const Text('Niggahīta'),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<NiggahitaMode>(
              segments: const [
                ButtonSegment(value: NiggahitaMode.dot, label: Text('ṃ')),
                ButtonSegment(value: NiggahitaMode.circle, label: Text('ṁ')),
              ],
              selected: {settings.niggahitaMode},
              onSelectionChanged: (s) => notifier.setNiggahitaMode(s.first),
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Show sandhi apostrophes'),
          subtitle: Text(
            settings.showSandhiApostrophe ? "Show apostrophes (e.g. mahā'pi)" : "Hide apostrophes (e.g. mahāpi)",
          ),
          value: settings.showSandhiApostrophe,
          onChanged: notifier.setShowSandhiApostrophe,
        ),
        _SectionHeader('Entry Display'),
        SwitchListTile(
          title: const Text('Show summary box'),
          subtitle: const Text('Integration coming in a future update'),
          value: settings.showSummary,
          onChanged: notifier.setShowSummary,
        ),
        _SectionHeader('Audio'),
        ListTile(
          title: const Text('Audio gender'),
          subtitle: const Text('Integration coming in a future update'),
          trailing: SegmentedButton<AudioGender>(
            segments: const [
              ButtonSegment(value: AudioGender.male, label: Text('Male')),
              ButtonSegment(value: AudioGender.female, label: Text('Female')),
            ],
            selected: {settings.audioGender},
            onSelectionChanged: (s) => notifier.setAudioGender(s.first),
          ),
        ),
        _SectionHeader('Dev'),
        ListTile(
          title: const Text('Settings style [dev]'),
          subtitle: const Text('Temporary — will be removed after user testing'),
          trailing: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Sheet')),
              ButtonSegment(value: false, label: Text('Drawer')),
            ],
            selected: {settings.useBottomSheetSettings},
            onSelectionChanged: (s) =>
                notifier.setUseBottomSheetSettings(s.first),
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
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
