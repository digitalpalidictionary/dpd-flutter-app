import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/help_data.dart';
import '../data/changelog_data.dart';
import '../models/help_results.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import '../widgets/secondary/bibliography_card.dart';
import '../widgets/secondary/thanks_card.dart';

enum InfoContent { changelog, bibliography, thanks }

// ── Info popup ────────────────────────────────────────────────────────────────

class InfoPopup extends ConsumerWidget {
  const InfoPopup({
    super.key,
    required this.onSelect,
    required this.onExternalLink,
    this.dbVersion,
  });

  final void Function(InfoContent) onSelect;
  final void Function(String url) onExternalLink;
  final String? dbVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider).valueOrNull;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final divider = Divider(
      height: 1,
      color: DpdColors.primary.withValues(alpha: 0.3),
    );

    return Material(
      elevation: 4,
      borderRadius: DpdColors.borderRadius,
      color: isDark ? DpdColors.darkShade : DpdColors.light,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: DpdColors.primary, width: 1.5),
          borderRadius: DpdColors.borderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'App v${appVersion ?? "…"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            divider,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storage_outlined,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Database ${dbVersion ?? "unknown"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            divider,
            InfoMenuItem(
              label: 'Change Log',
              icon: Icons.history,
              onTap: () => onSelect(InfoContent.changelog),
            ),
            divider,
            InfoMenuItem(
              label: 'Bibliography',
              icon: Icons.menu_book_outlined,
              onTap: () => onSelect(InfoContent.bibliography),
            ),
            divider,
            InfoMenuItem(
              label: 'Thanks',
              icon: Icons.volunteer_activism_outlined,
              onTap: () => onSelect(InfoContent.thanks),
            ),
            divider,
            InfoMenuItem(
              label: 'DPD Website',
              icon: Icons.language,
              onTap: () => onExternalLink('https://dpdict.net'),
            ),
            divider,
            InfoMenuItem(
              label: 'Documentation',
              icon: Icons.description_outlined,
              onTap: () => onExternalLink('https://docs.dpdict.net'),
            ),
            divider,
            InfoMenuItem(
              label: 'Mailing List',
              icon: Icons.mail_outline,
              onTap: () =>
                  onExternalLink('https://forms.gle/gJ7ouhJriYREPm1s8'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoMenuItem extends StatelessWidget {
  const InfoMenuItem({
    super.key,
    required this.label,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return InkWell(
      borderRadius: DpdColors.borderRadius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: style?.color),
            const SizedBox(width: 8),
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}

// ── Info content view ─────────────────────────────────────────────────────────

class InfoContentView extends StatefulWidget {
  const InfoContentView({super.key, required this.content});

  final InfoContent content;

  @override
  State<InfoContentView> createState() => _InfoContentViewState();
}

class _InfoContentViewState extends State<InfoContentView> {
  late Future<Widget> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(InfoContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      setState(() => _future = _load());
    }
  }

  Future<Widget> _load() async {
    switch (widget.content) {
      case InfoContent.changelog:
        final changelog = await loadChangelog();
        return ChangelogCard(changelog: changelog);
      case InfoContent.bibliography:
        final cats = await loadBibliography();
        return BibliographyCard(result: BibliographyResult(categories: cats));
      case InfoContent.thanks:
        final cats = await loadThanks();
        return ThanksCard(result: ThanksResult(categories: cats));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: snapshot.data!,
        );
      },
    );
  }
}

class ChangelogCard extends StatelessWidget {
  const ChangelogCard({super.key, required this.changelog});

  final ChangelogData changelog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (changelog.sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No change log is available yet.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in changelog.sections)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: DpdColors.primary, width: 1.5),
              borderRadius: DpdColors.borderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final item in section.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: theme.textTheme.bodyMedium),
                        Expanded(
                          child: Text(item, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
