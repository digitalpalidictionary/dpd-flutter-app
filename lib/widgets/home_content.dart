import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/word_of_day_provider.dart';
import 'accordion_card.dart';
import 'inline_entry_card.dart';

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key, required this.onSearch});

  final void Function(String query) onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(historyProvider).recentEntries;
    final recent = history.take(20).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WordOfDaySection(theme: theme, onSearch: onSearch),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 20),
            _RecentSearchesSection(
              theme: theme,
              recent: recent,
              onSearch: onSearch,
            ),
          ],
        ],
      ),
    );
  }
}

class _WordOfDaySection extends ConsumerWidget {
  const _WordOfDaySection({required this.theme, required this.onSearch});

  final ThemeData theme;
  final void Function(String query) onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(randomWordProvider);
    final displayMode =
        ref.watch(settingsProvider.select((s) => s.displayMode));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: Row(
            children: [
              Text(
                'Random Word',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                visualDensity: VisualDensity.compact,
                tooltip: 'Another random word',
                onPressed: () => ref.invalidate(randomWordProvider),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
          wordAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => const SizedBox.shrink(),
            data: (hw) {
              if (hw == null) return const SizedBox.shrink();
              return switch (displayMode) {
                DisplayMode.classic => InlineEntryCard(headword: hw),
                DisplayMode.compact => AccordionCard(headword: hw),
              };
            },
          ),
        ],
      );
  }
}

class _RecentSearchesSection extends StatelessWidget {
  const _RecentSearchesSection({
    required this.theme,
    required this.recent,
    required this.onSearch,
  });

  final ThemeData theme;
  final List<HistoryEntry> recent;
  final void Function(String query) onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            'Recent Searches',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final entry in recent)
                ActionChip(
                  label: Text(entry.query),
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                  onPressed: () => onSearch(entry.query),
                ),
            ],
          ),
        ),
        ],
      );
  }
}
