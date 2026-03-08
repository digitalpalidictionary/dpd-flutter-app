import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_update_provider.dart';
import '../providers/settings_provider.dart';
import '../services/database_update_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final updateState = ref.watch(dbUpdateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Display'),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
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
            title: const Text('Font style'),
            subtitle: Text(settings.useSerifFont ? 'Serif' : 'Sans-serif'),
            value: settings.useSerifFont,
            onChanged: notifier.setUseSerifFont,
          ),
          SwitchListTile(
            title: const Text('Grammar'),
            subtitle: Text(settings.grammarOpen ? 'Open by default' : 'Closed by default'),
            value: settings.grammarOpen,
            onChanged: notifier.setGrammarOpen,
          ),
          SwitchListTile(
            title: const Text('Examples'),
            subtitle: Text(settings.examplesOpen ? 'Open by default' : 'Closed by default'),
            value: settings.examplesOpen,
            onChanged: notifier.setExamplesOpen,
          ),
          ListTile(
            title: const Text('Result style'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<DisplayMode>(
                segments: const [
                  ButtonSegment(value: DisplayMode.classic, label: Text('Classic')),
                  ButtonSegment(value: DisplayMode.compact, label: Text('Compact')),
                ],
                selected: {settings.displayMode},
                onSelectionChanged: (s) => notifier.setDisplayMode(s.first),
              ),
            ),
          ),
          const _SectionHeader('Database'),
          ListTile(
            title: const Text('Database version'),
            trailing: Text(updateState.localVersion ?? 'unknown'),
          ),
          ListTile(
            title: const Text('Check for updates'),
            trailing: updateState.status == DbStatus.downloading ||
                    updateState.status == DbStatus.extracting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onTap: updateState.status == DbStatus.downloading ||
                    updateState.status == DbStatus.extracting
                ? null
                : () => ref
                    .read(dbUpdateProvider.notifier)
                    .manualCheckForUpdates(),
          ),
          SwitchListTile(
            title: const Text('WiFi-only updates'),
            subtitle: const Text('Only download updates over WiFi'),
            value: settings.wifiOnlyUpdates,
            onChanged: (v) => notifier.setWifiOnlyUpdates(v),
          ),
          const _SectionHeader('About'),
          ListTile(
            title: const Text('App version'),
            trailing: Text(ref.watch(appVersionProvider).valueOrNull ?? '…'),
          ),
          ListTile(
            title: const Text('dpdict.net'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {},
          ),
        ],
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
