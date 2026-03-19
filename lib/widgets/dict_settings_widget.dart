import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dict_provider.dart';
import '../theme/dpd_colors.dart';

class DictSettingsWidget extends ConsumerWidget {
  const DictSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaAsync = ref.watch(dictMetaAllProvider);
    final visibility = ref.watch(dictVisibilityProvider);
    final theme = Theme.of(context);

    final allMeta = metaAsync.valueOrNull ?? [];
    if (allMeta.isEmpty) return const SizedBox.shrink();

    final metaMap = {for (final m in allMeta) m.dictId: m};

    final orderedIds = visibility.order.isNotEmpty
        ? visibility.order
        : allMeta.map((m) => m.dictId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: theme.colorScheme.outlineVariant),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('Dictionaries', style: theme.textTheme.titleMedium),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: orderedIds.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            final newOrder = List<String>.from(orderedIds);
            final item = newOrder.removeAt(oldIndex);
            newOrder.insert(newIndex, item);
            ref.read(dictVisibilityProvider.notifier).setOrder(newOrder);
          },
          itemBuilder: (context, index) {
            final dictId = orderedIds[index];
            final meta = metaMap[dictId];
            final name = meta?.name ?? dictId;
            final count = meta?.entryCount;
            final enabled = visibility.enabled.contains(dictId);

            return ListTile(
              key: ValueKey(dictId),
              leading: ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(name),
              subtitle: count != null
                  ? Text(
                      '$count entries',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              trailing: Switch(
                value: enabled,
                activeThumbColor: DpdColors.primary,
                onChanged: (value) {
                  ref
                      .read(dictVisibilityProvider.notifier)
                      .toggleDict(dictId, value);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
