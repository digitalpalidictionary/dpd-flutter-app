import 'package:flutter/material.dart';

import '../models/summary_entry.dart';
import '../theme/dpd_colors.dart';

/// Displays a summary list at the top of search results.
/// Each entry shows label, type, meaning, and a ► tap target.
class SummarySection extends StatelessWidget {
  const SummarySection({
    super.key,
    required this.entries,
    required this.onTap,
  });

  final List<SummaryEntry> entries;
  final void Function(String targetId) onTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          ...entries.map(
            (e) => _SummaryRow(entry: e, onTap: () => onTap(e.targetId)),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: DpdColors.primary.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.entry, required this.onTap});

  final SummaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium;
    final labelStyle = baseStyle?.copyWith(fontWeight: FontWeight.w700);
    final typeStyle = baseStyle?.copyWith(
      color: DpdColors.primaryText,
      fontStyle: FontStyle.italic,
    );
    final meaningStyle = baseStyle?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final linkStyle = baseStyle?.copyWith(
      color: DpdColors.primaryText,
      fontWeight: FontWeight.w700,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: DpdColors.borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 4,
                children: [
                  Text(entry.label, style: labelStyle),
                  if (entry.typeLabel.isNotEmpty)
                    Text(entry.typeLabel, style: typeStyle),
                  if (entry.meaning.isNotEmpty)
                    Text(entry.meaning, style: meaningStyle),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('►', style: linkStyle),
          ],
        ),
      ),
    );
  }
}
