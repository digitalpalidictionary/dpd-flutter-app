import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database.dart';
import '../theme/dpd_colors.dart';

List<(String, String)> buildFamilyRows(DpdHeadwordWithRoot h) => [
  if (h.familyRoot != null && h.familyRoot!.isNotEmpty)
    ('Root family', h.familyRoot!),
  if (h.familyWord != null && h.familyWord!.isNotEmpty)
    ('Word family', h.familyWord!),
  if (h.familyCompound != null && h.familyCompound!.isNotEmpty)
    ('Compound members', h.familyCompound!),
  if (h.familyIdioms != null && h.familyIdioms!.isNotEmpty)
    ('Idioms', h.familyIdioms!),
  if (h.familySet != null && h.familySet!.isNotEmpty)
    ('Thematic sets', h.familySet!),
  if (h.antonym != null && h.antonym!.isNotEmpty) ('Antonyms', h.antonym!),
  if (h.synonym != null && h.synonym!.isNotEmpty) ('Synonyms', h.synonym!),
  if (h.variant != null && h.variant!.isNotEmpty) ('Variants', h.variant!),
];

String posGrammarLine(DpdHeadwordWithRoot h) {
  final parts = [
    h.pos,
    h.grammar,
  ].whereType<String>().where((s) => s.isNotEmpty);
  return parts.join(' · ');
}

class EntryLabelValue extends StatelessWidget {
  const EntryLabelValue({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: DpdColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              softWrap: false,
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class EntryExampleBlock extends StatelessWidget {
  const EntryExampleBlock({
    super.key,
    required this.example,
    this.sutta,
    this.source,
  });

  final String example;
  final String? sutta;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(
          data: example,
          style: {
            'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            'p': Style(margin: Margins.zero),
          },
        ),
        if (sutta != null || source != null) ...[
          Html(
            data:
                '<p class="sutta">${[source, sutta].whereType<String>().join(' ')}</p>',
            style: {
              'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              'p.sutta': Style(
                color: DpdColors.primaryText,
                fontStyle: FontStyle.italic,
                fontSize: FontSize(
                  theme.textTheme.bodySmall?.fontSize ?? 12.0,
                ),
                margin: Margins.zero,
                padding: HtmlPaddings.only(bottom: 3),
              ),
              'a.sutta_link': Style(
                color: DpdColors.primaryText,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                textDecoration: TextDecoration.none,
              ),
            },
            onLinkTap: (url, attributes, element) async {
              if (url != null) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class EntrySummaryBox extends StatelessWidget {
  const EntrySummaryBox({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        borderRadius: DpdColors.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          children: [
            if (headword.pos != null && headword.pos!.isNotEmpty)
              TextSpan(text: '${headword.pos}. '),
            if (headword.plusCase != null && headword.plusCase!.isNotEmpty)
              TextSpan(text: '(${headword.plusCase}) '),
            if (headword.meaning1 != null && headword.meaning1!.isNotEmpty)
              TextSpan(text: '${headword.meaning1} '),
            if (headword.meaningLit != null && headword.meaningLit!.isNotEmpty)
              TextSpan(
                text: 'lit. ${headword.meaningLit} ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A bordered container for entry section content, matching .dpd.content CSS.
class DpdSectionContainer extends StatelessWidget {
  const DpdSectionContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        borderRadius: DpdColors.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: child,
    );
  }
}

/// Webapp-style section toggle button matching .dpd-button CSS class.
/// Inactive: cyan fill, dark text. Active: primary-alt fill, light text.
class DpdSectionButton extends StatelessWidget {
  const DpdSectionButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isActive
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    final fg = isActive
        ? theme.colorScheme.onSecondary
        : theme.colorScheme.onPrimary;
    final shadow = isActive ? DpdColors.shadowHover : DpdColors.shadowDefault;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 1, 2),
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: bg, width: 1),
          borderRadius: DpdColors.borderRadius,
          boxShadow: shadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 14.0 * 0.8,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
