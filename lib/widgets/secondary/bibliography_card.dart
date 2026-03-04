import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/help_data.dart';
import '../../models/help_results.dart';
import 'secondary_card.dart';

class BibliographyCard extends StatelessWidget {
  const BibliographyCard({super.key, required this.result});

  final BibliographyResult result;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    final categoryStyle = bodyStyle?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
      fontSize: (bodyStyle?.fontSize ?? 14) + 2,
    );

    final children = <Widget>[];
    for (final cat in result.categories) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(cat.name, style: categoryStyle),
        ),
      );
      for (final entry in cat.entries) {
        children.add(_BibliographyEntryRow(entry: entry, bodyStyle: bodyStyle));
      }
    }

    return TertiaryCard(
      title: 'Bibliography',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _BibliographyEntryRow extends StatelessWidget {
  const _BibliographyEntryRow({required this.entry, required this.bodyStyle});

  final BibliographyEntry entry;
  final TextStyle? bodyStyle;

  @override
  Widget build(BuildContext context) {
    final boldStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w700);
    final italicStyle = bodyStyle?.copyWith(fontStyle: FontStyle.italic);
    final linkColor = Theme.of(context).colorScheme.primary;

    final spans = <InlineSpan>[const TextSpan(text: '• ')];

    if (entry.surname.isNotEmpty) {
      spans.add(TextSpan(text: entry.surname, style: boldStyle));
      if (entry.firstname.isNotEmpty) {
        spans.add(TextSpan(text: ', ${entry.firstname}'));
      }
    }

    if (entry.year.isNotEmpty) {
      if (spans.length > 1) spans.add(const TextSpan(text: ' '));
      spans.add(TextSpan(text: '(${entry.year})'));
    }

    if (entry.title.isNotEmpty) {
      spans.add(const TextSpan(text: '. '));
      spans.add(TextSpan(text: entry.title, style: italicStyle));
    }

    final pubParts = <String>[
      if (entry.city.isNotEmpty) entry.city,
      if (entry.publisher.isNotEmpty) entry.publisher,
    ];
    if (pubParts.isNotEmpty) {
      spans.add(TextSpan(text: '. ${pubParts.join(': ')}'));
    }

    if (entry.site.isNotEmpty) {
      spans.add(const TextSpan(text: ' '));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () {
              final uri = Uri.tryParse(entry.site);
              if (uri != null) launchUrl(uri, mode: LaunchMode.platformDefault);
            },
            child: Text(
              '[link]',
              style: bodyStyle?.copyWith(
                color: linkColor,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(TextSpan(style: bodyStyle, children: spans)),
    );
  }
}
