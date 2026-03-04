import 'package:flutter/material.dart';

import '../../data/help_data.dart';
import '../../models/help_results.dart';
import 'secondary_card.dart';

String _stripHtml(String html) => html.replaceAll(RegExp(r'<[^>]*>'), '');

class ThanksCard extends StatelessWidget {
  const ThanksCard({super.key, required this.result});

  final ThanksResult result;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    final categoryStyle = bodyStyle?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
      fontSize: (bodyStyle?.fontSize ?? 14) + 2,
    );
    final descStyle = bodyStyle?.copyWith(fontStyle: FontStyle.italic);

    final children = <Widget>[];
    for (final cat in result.categories) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(cat.name, style: categoryStyle),
        ),
      );
      if (cat.description.isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_stripHtml(cat.description), style: descStyle),
          ),
        );
      }
      for (final entry in cat.entries) {
        children.add(_ThanksEntryRow(entry: entry, bodyStyle: bodyStyle));
      }
    }

    return TertiaryCard(
      title: 'Thanks',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ThanksEntryRow extends StatelessWidget {
  const _ThanksEntryRow({required this.entry, required this.bodyStyle});

  final ThanksEntry entry;
  final TextStyle? bodyStyle;

  @override
  Widget build(BuildContext context) {
    final boldStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w700);

    final spans = <InlineSpan>[
      const TextSpan(text: '• '),
      TextSpan(text: entry.who, style: boldStyle),
    ];

    if (entry.where.isNotEmpty) {
      spans.add(TextSpan(text: ' ${entry.where}'));
    }
    if (entry.what.isNotEmpty) {
      spans.add(TextSpan(text: ' — ${_stripHtml(entry.what)}'));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Text.rich(TextSpan(style: bodyStyle, children: spans)),
    );
  }
}
