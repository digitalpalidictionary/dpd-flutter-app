import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_provider.dart';
import '../providers/search_provider.dart';
import '../theme/dpd_colors.dart';

Future<void> showHistoryOverlay(BuildContext context) {
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
            const Expanded(child: HistoryContent()),
          ],
        ),
      );
    },
  );
}

class HistoryContent extends ConsumerWidget {
  const HistoryContent({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              Text('Search History', style: theme.textTheme.titleLarge),
              const Spacer(),
              if (history.entries.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClear(context, ref),
                  child: const Text('Clear All'),
                ),
            ],
          ),
        ),
        Expanded(
          child: history.entries.isEmpty
              ? Center(
                  child: Text(
                    'No search history',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : _buildGroupedList(context, ref, history.entries, theme, onClose),
        ),
      ],
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    WidgetRef ref,
    List<HistoryEntry> entries,
    ThemeData theme,
    VoidCallback? onClose,
  ) {
    final groups = <String, List<MapEntry<int, HistoryEntry>>>{};
    for (var i = 0; i < entries.length; i++) {
      final group = _dateGroup(entries[i].timestamp);
      groups.putIfAbsent(group, () => []).add(MapEntry(i, entries[i]));
    }

    final orderedGroups = ['Today', 'Yesterday', 'Earlier'];

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: orderedGroups.fold<int>(0, (sum, g) {
        final items = groups[g];
        if (items == null || items.isEmpty) return sum;
        return sum + 1 + items.length;
      }),
      itemBuilder: (context, index) {
        var offset = 0;
        for (final groupName in orderedGroups) {
          final items = groups[groupName];
          if (items == null || items.isEmpty) continue;

          if (index == offset) {
            return _SectionHeader(title: groupName);
          }

          if (index <= offset + items.length) {
            final itemIndex = index - offset - 1;
            final pair = items[itemIndex];
            return _HistoryTile(
              entry: pair.value,
              absoluteIndex: pair.key,
              onClose: onClose,
            );
          }

          offset += 1 + items.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all search history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({
    required this.entry,
    required this.absoluteIndex,
    this.onClose,
  });

  final HistoryEntry entry;
  final int absoluteIndex;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey('${entry.query}_${entry.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) {
        ref.read(historyProvider.notifier).removeAt(absoluteIndex);
      },
      child: ListTile(
        dense: true,
        title: Text(
          entry.query,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge,
        ),
        trailing: Text(
          _relativeTime(entry.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () {
          ref.read(historyProvider.notifier).add(entry.query);
          ref.read(searchQueryProvider.notifier).state = entry.query;
          if (onClose != null) {
            onClose!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

String _dateGroup(DateTime timestamp) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final entryDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
  if (entryDay == today) return 'Today';
  if (entryDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return 'Earlier';
}

String _relativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
}
