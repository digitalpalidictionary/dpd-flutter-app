import 'package:flutter/material.dart';

import '../models/summary_entry.dart';
import '../theme/dpd_colors.dart';

@visibleForTesting
({String lemma, String? suffix}) splitSummaryLemma(String label) {
  final spaceIndex = label.lastIndexOf(' ');
  if (spaceIndex <= 0 || spaceIndex >= label.length - 1) {
    return (lemma: label, suffix: null);
  }

  final suffix = label.substring(spaceIndex + 1);
  if (!RegExp(r'^\d[\d.]*$').hasMatch(suffix)) {
    return (lemma: label, suffix: null);
  }

  return (lemma: label.substring(0, spaceIndex), suffix: suffix);
}

@visibleForTesting
bool shouldShowHeadwordHeading(SummaryEntry entry, SummaryEntry? previous) {
  if (entry.type != SummaryEntryType.headword) return false;

  final current = splitSummaryLemma(entry.label);
  if (current.suffix == null) return true;

  if (previous == null || previous.type != SummaryEntryType.headword) {
    return true;
  }

  final prior = splitSummaryLemma(previous.label);
  return prior.lemma != current.lemma;
}

/// Displays a summary list at the top of search results.
/// Each entry shows label, type, meaning, and a ► tap target.
class SummarySection extends StatelessWidget {
  const SummarySection({super.key, required this.entries, required this.onTap});

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
          for (var i = 0; i < entries.length; i++)
            _SummaryRow(
              entry: entries[i],
              showHeadwordHeading: shouldShowHeadwordHeading(
                entries[i],
                i > 0 ? entries[i - 1] : null,
              ),
              onTap: () => onTap(entries[i].targetId),
            ),
          const SizedBox(height: 12),
          Divider(height: 1, color: DpdColors.primary.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.entry,
    required this.showHeadwordHeading,
    required this.onTap,
  });

  final SummaryEntry entry;
  final bool showHeadwordHeading;
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
    final splitLabel = splitSummaryLemma(entry.label);

    return InkWell(
      onTap: onTap,
      borderRadius: DpdColors.borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: entry.type == SummaryEntryType.headword
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeadwordHeading)
                          Text(splitLabel.lemma, style: labelStyle),
                        if (entry.typeLabel.isNotEmpty ||
                            entry.meaning.isNotEmpty)
                          Text.rich(
                            TextSpan(
                              children: [
                                if (splitLabel.suffix != null)
                                  TextSpan(
                                    text: '${splitLabel.suffix} ',
                                    style: linkStyle,
                                  ),
                                if (entry.typeLabel.isNotEmpty)
                                  TextSpan(
                                    text: entry.typeLabel,
                                    style: baseStyle,
                                  ),
                                if (entry.meaning.isNotEmpty)
                                  TextSpan(
                                    text: entry.typeLabel.isNotEmpty
                                        ? ' ${entry.meaning}'
                                        : entry.meaning,
                                    style: baseStyle,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('►', style: linkStyle),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: entry.label, style: labelStyle),
                          if (entry.typeLabel.isNotEmpty)
                            TextSpan(
                              text: ' ${entry.typeLabel}',
                              style: baseStyle,
                            ),
                          if (entry.meaning.isNotEmpty)
                            TextSpan(
                              text: ' ${entry.meaning}',
                              style: baseStyle,
                            ),
                        ],
                      ),
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
