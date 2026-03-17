import 'package:flutter/material.dart';

import '../models/family_data.dart';
import '../theme/dpd_colors.dart';
import 'entry_content.dart';
import 'feedback_type.dart';

/// Config for a family section footer feedback link.
class FamilyFooterConfig {
  const FamilyFooterConfig({
    required this.messagePrefix,
    required this.linkText,
    required this.feedbackType,
    required this.word,
    this.headwordId,
  });

  final String messagePrefix;
  final String linkText;
  final FeedbackType feedbackType;
  final String word;
  final int? headwordId;
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
        padding: DpdColors.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadingUnderlined(child: header),
            const SizedBox(height: 8),
            if (entries.isNotEmpty) FamilyEntryTable(entries: entries),
            DpdFooter(
              messagePrefix: footerConfig.messagePrefix,
              linkText: footerConfig.linkText,
              feedbackType: footerConfig.feedbackType,
              word: footerConfig.word,
              headwordId: footerConfig.headwordId,
            ),
          ],
        ),
      ),
    );
  }
}

/// "heading underlined" style — bold text with a bottom border.
class HeadingUnderlined extends StatelessWidget {
  const HeadingUnderlined({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DpdColors.primary, width: 1)),
      ),
      child: child,
    );
  }
}

final _paliDigraph = RegExp(r'[kgcjṭḍtdpb]h', caseSensitive: false);

String _addBreakPoints(String text) {
  final buf = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0) {
      final digraph = '${text[i - 1]}${text[i]}';
      if (!_paliDigraph.hasMatch(digraph)) {
        buf.write('\u200B');
      }
    }
    buf.write(text[i]);
  }
  return buf.toString();
}

/// Shared table widget for family entries (lemma / pos / meaning / completion).
///
/// Used by both [FamilyTableWidget] and [MultiFamilySection].
class FamilyEntryTable extends StatelessWidget {
  const FamilyEntryTable({super.key, required this.entries});

  final List<FamilyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lemmaStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: DpdColors.primaryText,
    );
    final boldStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final regularStyle = theme.textTheme.bodyMedium;

    return Table(
      columnWidths: const {
        0: MinColumnWidth(IntrinsicColumnWidth(), FractionColumnWidth(0.45)),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 7, bottom: 2),
              child: Text(
                _addBreakPoints(entry.lemma),
                style: lemmaStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 7, bottom: 2),
              child: Text(entry.pos, style: boldStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 7, bottom: 2),
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
