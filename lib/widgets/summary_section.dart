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
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          ...entries.map(
            (e) => _SummaryRow(entry: e, onTap: () => onTap(e.targetId)),
          ),
          const SizedBox(height: 12),
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
    final isDark = theme.brightness == Brightness.dark;
    final labelStyle = baseStyle?.copyWith(
      color: isDark ? DpdColors.primaryTextDark : DpdColors.primaryText,
      fontWeight: FontWeight.w700,
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
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: entry.label, style: labelStyle),
                    if (entry.typeLabel.isNotEmpty)
                      TextSpan(text: ' ${entry.typeLabel}', style: baseStyle),
                    if (entry.meaning.isNotEmpty)
                      TextSpan(text: ' ${entry.meaning}', style: baseStyle),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
