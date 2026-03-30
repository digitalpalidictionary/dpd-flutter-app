import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dict_provider.dart';
import 'compact_segmented.dart';

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
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final t = Curves.easeOut.transform(animation.value);
                return Transform.scale(
                  scale: 1 + (0.02 * t),
                  child: Material(
                    elevation: 2 + (10 * t),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: Theme.of(context).colorScheme.shadow,
                    child: child,
                  ),
                );
              },
            );
          },
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
              leading: _ReorderHandle(index: index),
              title: Text(name),
              subtitle: count != null
                  ? Text(
                      '$count entries',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              trailing: CompactSegmented<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Off')),
                  ButtonSegment(value: true, label: Text('On')),
                ],
                selected: enabled,
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

class _ReorderHandle extends StatelessWidget {
  const _ReorderHandle({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ReorderableDragStartListener(
      index: index,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.drag_handle,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
