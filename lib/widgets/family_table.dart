import 'package:flutter/material.dart';

import '../models/family_data.dart';
import '../theme/dpd_colors.dart';
import 'entry_content.dart';

/// Config for a family section footer feedback link.
class FamilyFooterConfig {
  const FamilyFooterConfig({
    required this.messagePrefix,
    required this.linkText,
    required this.urlBuilder,
  });

  final String messagePrefix;
  final String linkText;
  final String Function() urlBuilder;
}

/// Reusable widget for rendering any family type table section.
///
/// Renders inside a [DpdSectionContainer] with:
/// - A header styled as "heading underlined" (bold text + bottom border)
/// - A native Flutter Table with columns: lemma, pos, meaning, completion
/// - A [DpdFooter] at the bottom
class FamilyTableWidget extends StatelessWidget {
  const FamilyTableWidget({
    super.key,
    required this.header,
    required this.entries,
    required this.footerConfig,
  });

  final Widget header;
  final List<FamilyEntry> entries;
  final FamilyFooterConfig footerConfig;

  @override
  Widget build(BuildContext context) {
    return DpdSectionContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeadingUnderlined(child: header),
            const SizedBox(height: 8),
            if (entries.isNotEmpty) _FamilyTable(entries: entries),
            const SizedBox(height: 4),
            DpdFooter(
              messagePrefix: footerConfig.messagePrefix,
              linkText: footerConfig.linkText,
              urlBuilder: footerConfig.urlBuilder,
            ),
          ],
        ),
      ),
    );
  }
}

/// "heading underlined" style — bold text with a bottom border.
class _HeadingUnderlined extends StatelessWidget {
  const _HeadingUnderlined({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DpdColors.primary, width: 1),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: FontWeight.bold),
        child: child,
      ),
    );
  }
}

class _FamilyTable extends StatelessWidget {
  const _FamilyTable({required this.entries});

  final List<FamilyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final regularStyle = theme.textTheme.bodyMedium;

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      children: entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: Text(entry.lemma, style: boldStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: Text(entry.pos, style: boldStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: Text(entry.meaning, style: regularStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                entry.completion,
                style: regularStyle?.copyWith(color: DpdColors.gray),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
