import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_provider.dart';
import '../providers/search_provider.dart';
import '../theme/dpd_colors.dart';

class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key});

  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  bool _collapsed = true;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    if (history.entries.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: DpdColors.grayTransparent, width: 2),
        borderRadius: DpdColors.borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'History',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!_collapsed) ...[
                const SizedBox(width: 8),
                _ClearButton(
                  onPressed: () =>
                      ref.read(historyProvider.notifier).clear(),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _collapsed = !_collapsed),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _collapsed
                        ? Icons.expand_more
                        : Icons.expand_less,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (!_collapsed)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < history.entries.length; i++) ...[
                    if (i > 0)
                      Text(
                        ', ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        final term = history.entries[i];
                        ref.read(historyProvider.notifier).add(term);
                        ref.read(searchQueryProvider.notifier).state = term;
                      },
                      child: Text(
                        history.entries[i],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: DpdColors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Material(
        color: DpdColors.primary,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
