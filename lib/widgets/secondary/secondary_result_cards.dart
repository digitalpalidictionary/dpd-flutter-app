import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/lookup_results.dart';
import '../../theme/dpd_colors.dart';
import 'secondary_card.dart';

// ── Shared helpers ────────────────────────────────────────────────────────────

const _lineHeight = 1.5;

Widget _lineBreakText(List<String> lines, TextStyle? baseStyle) {
  if (lines.isEmpty) return const SizedBox.shrink();
  return Text.rich(
    TextSpan(
      style: baseStyle?.copyWith(height: _lineHeight),
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          TextSpan(text: lines[i]),
          if (i < lines.length - 1) const TextSpan(text: '\n'),
        ],
      ],
    ),
  );
}

Widget _dpdLink(String text, String url, {TextStyle? style}) {
  return InkWell(
    onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault),
    child: Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: DpdColors.primaryText,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ── Deconstructor Card ────────────────────────────────────────────────────────

class DeconstructorCard extends StatelessWidget {
  const DeconstructorCard({super.key, required this.result});

  final DeconstructorResult result;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final encodedHeadword = Uri.encodeComponent(result.headword);

    return DpdSecondaryCard(
      title: 'deconstructor: ${result.headword}',
      content: _lineBreakText(result.deconstructions, bodyStyle),
      footer: _DeconstructorFooter(
        encodedHeadword: encodedHeadword,
        bodyStyle: bodyStyle,
      ),
    );
  }
}

class _DeconstructorFooter extends StatelessWidget {
  const _DeconstructorFooter({
    required this.encodedHeadword,
    required this.bodyStyle,
  });

  final String encodedHeadword;
  final TextStyle? bodyStyle;

  @override
  Widget build(BuildContext context) {
    const baseUrl =
        'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url';
    final docsUrl =
        'https://digitalpalidictionary.github.io/features/deconstructor/';
    final suggestUrl =
        '$baseUrl&entry.438735500=$encodedHeadword&entry.326955045=Deconstructor';
    const addWordsUrl =
        'https://docs.google.com/forms/d/e/1FAIpQLSfResxEUiRCyFITWPkzoQ2HhHEvUS5fyg68Rl28hFH6vhHlaA/viewform';

    final footerStyle = bodyStyle?.copyWith(
      fontSize: (bodyStyle?.fontSize ?? 14) * 0.8,
      color: Colors.grey,
      height: _lineHeight,
    );

    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: DpdColors.primary, width: 1)),
      ),
      child: Text.rich(
        TextSpan(
          style: footerStyle,
          children: [
            const TextSpan(
                text: 'These word breakups are code-generated. For more information, '),
            WidgetSpan(
              child: _dpdLink('read the docs', docsUrl, style: footerStyle),
            ),
            const TextSpan(text: '. Please '),
            WidgetSpan(
              child: _dpdLink('suggest any improvements here', suggestUrl,
                  style: footerStyle),
            ),
            const TextSpan(
                text:
                    '. Mistakes in deconstruction are usually caused by a word missing from the dictionary. You can '),
            WidgetSpan(
              child:
                  _dpdLink('add missing words here', addWordsUrl, style: footerStyle),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}

// ── Grammar Dict Card ─────────────────────────────────────────────────────────

class GrammarDictCard extends StatelessWidget {
  const GrammarDictCard({super.key, required this.result});

  final GrammarDictResult result;

  @override
  Widget build(BuildContext context) {
    const docsUrl =
        'https://digitalpalidictionary.github.io/features/grammardict/';

    return DpdSecondaryCard(
      title: 'grammar: ${result.headword}',
      content: _GrammarDictTable(entries: result.entries),
      footer: _SimpleDpdFooter(
        prefix: 'For more information, please ',
        linkText: 'read the docs',
        url: docsUrl,
      ),
    );
  }
}

class _GrammarDictTable extends StatelessWidget {
  const _GrammarDictTable({required this.entries});

  final List<GrammarDictEntry> entries;

  @override
  Widget build(BuildContext context) {
    final bodyStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: _lineHeight);

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header row
        TableRow(
          children: [
            _cell(context, 'pos', style: bodyStyle, bold: false),
            ...List.generate(3, (_) => _cell(context, '', style: bodyStyle)),
            _cell(context, '', style: bodyStyle),
            _cell(context, 'word', style: bodyStyle, bold: false),
          ],
        ),
        for (final entry in entries)
          TableRow(
            children: [
              _cell(context, entry.pos, style: bodyStyle, bold: true),
              ...entry.components.map((comp) => comp.isEmpty
                  ? const SizedBox.shrink()
                  : _cell(context, comp, style: bodyStyle)),
              _cell(context, 'of', style: bodyStyle),
              _cell(context, entry.headword, style: bodyStyle),
            ],
          ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    String text, {
    TextStyle? style,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
      child: Text(
        text,
        style: bold
            ? style?.copyWith(fontWeight: FontWeight.w700)
            : style,
      ),
    );
  }
}

// ── Abbreviation Card ─────────────────────────────────────────────────────────

class AbbreviationCard extends StatelessWidget {
  const AbbreviationCard({super.key, required this.result});

  final AbbreviationResult result;

  @override
  Widget build(BuildContext context) {
    return TertiaryCard(
      title: result.headword,
      content: _HelpStyleTable(rows: [
        ('Abbreviation', result.headword, true),
        ('Meaning', result.meaning, false),
        if (result.pali != null && result.pali!.isNotEmpty)
          ('Pāḷi', result.pali!, false),
        if (result.example != null && result.example!.isNotEmpty)
          ('Example', result.example!, false),
        if (result.explanation != null && result.explanation!.isNotEmpty)
          ('Information', result.explanation!, false),
      ]),
    );
  }
}

// ── Help Card ─────────────────────────────────────────────────────────────────

class HelpCard extends StatelessWidget {
  const HelpCard({super.key, required this.result});

  final HelpResult result;

  @override
  Widget build(BuildContext context) {
    return TertiaryCard(
      title: result.headword,
      content: _HelpStyleTable(rows: [
        ('Help', result.headword, true),
        ('Meaning', result.helpText, false),
      ]),
    );
  }
}

class _HelpStyleTable extends StatelessWidget {
  const _HelpStyleTable({required this.rows});

  /// Each entry: (label, value, bold)
  final List<(String, String, bool)> rows;

  @override
  Widget build(BuildContext context) {
    final bodyStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: _lineHeight);

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: rows.map(((String, String, bool) row) {
        final (label, value, bold) = row;
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              label,
              style: bodyStyle?.copyWith(
                color: DpdColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: bold
                ? bodyStyle?.copyWith(fontWeight: FontWeight.w700)
                : bodyStyle,
          ),
        ]);
      }).toList(),
    );
  }
}

// ── EPD Card ──────────────────────────────────────────────────────────────────

class EpdCard extends StatelessWidget {
  const EpdCard({super.key, required this.result});

  final EpdResult result;

  @override
  Widget build(BuildContext context) {
    final bodyStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: _lineHeight);

    return DpdSecondaryCard(
      title: 'English: ${result.headword}',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: result.entries.map((entry) {
          return Text.rich(
            TextSpan(
              style: bodyStyle,
              children: [
                TextSpan(
                  text: entry.headword,
                  style: TextStyle(
                    color: DpdColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (entry.posInfo.isNotEmpty)
                  TextSpan(text: ' ${entry.posInfo}.'),
                TextSpan(text: ' ${entry.meaning}.'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Variant Card ──────────────────────────────────────────────────────────────

class VariantCard extends StatelessWidget {
  const VariantCard({super.key, required this.result});

  final VariantResult result;

  @override
  Widget build(BuildContext context) {
    const docsUrl = 'https://digitalpalidictionary.github.io/features/variants/';

    return DpdSecondaryCard(
      title: 'variants: ${result.headword}',
      content: _VariantTable(variants: result.variants),
      footer: _SimpleDpdFooter(
        prefix: 'For details on how to use this, please ',
        linkText: 'read the docs',
        url: docsUrl,
      ),
    );
  }
}

class _VariantTable extends StatelessWidget {
  const _VariantTable({required this.variants});

  final Map<String, Map<String, List<List<String>>>> variants;

  @override
  Widget build(BuildContext context) {
    final bodyStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: _lineHeight);
    final headerStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w700);

    final corpusList = variants.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row (shared across all corpus groups)
        Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              for (final h in ['source', 'filename', 'context', 'variant'])
                _cell(h, style: headerStyle),
            ]),
          ],
        ),
        for (int ci = 0; ci < corpusList.length; ci++) ...[
          if (ci > 0)
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 2),
              color: DpdColors.grayTransparent,
            ),
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (final book in variants[corpusList[ci]]!.keys)
                for (final entry in variants[corpusList[ci]]![book]!)
                  TableRow(children: [
                    _cell(corpusList[ci], style: bodyStyle, noWrap: true),
                    _cell(book, style: bodyStyle, noWrap: true),
                    _cell(entry[0], style: bodyStyle),
                    _cell(entry[1], style: bodyStyle),
                  ]),
            ],
          ),
        ],
      ],
    );
  }

  Widget _cell(String text, {TextStyle? style, bool noWrap = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
      child: noWrap
          ? Text(text, style: style, softWrap: false)
          : Text(text, style: style),
    );
  }
}

// ── Spelling Card ─────────────────────────────────────────────────────────────

class SpellingCard extends StatelessWidget {
  const SpellingCard({super.key, required this.result});

  final SpellingResult result;

  @override
  Widget build(BuildContext context) {
    final bodyStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: _lineHeight);
    return DpdSecondaryCard(
      title: 'spelling: ${result.headword}',
      content: Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            for (int i = 0; i < result.spellings.length; i++) ...[
              const TextSpan(text: 'incorrect spelling of '),
              TextSpan(
                text: result.spellings[i],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (i < result.spellings.length - 1)
                const TextSpan(text: '\n'),
            ],
          ],
        ),
      ),
    );
  }
}

// ── See Card ──────────────────────────────────────────────────────────────────

class SeeCard extends StatelessWidget {
  const SeeCard({super.key, required this.result});

  final SeeResult result;

  @override
  Widget build(BuildContext context) {
    final bodyStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: _lineHeight);
    return DpdSecondaryCard(
      title: 'see: ${result.headword}',
      content: Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            for (int i = 0; i < result.seeHeadwords.length; i++) ...[
              const TextSpan(text: 'see '),
              TextSpan(
                text: result.seeHeadwords[i],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (i < result.seeHeadwords.length - 1)
                const TextSpan(text: '\n'),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared footer ─────────────────────────────────────────────────────────────

class _SimpleDpdFooter extends StatelessWidget {
  const _SimpleDpdFooter({
    required this.prefix,
    required this.linkText,
    required this.url,
  });

  final String prefix;
  final String linkText;
  final String url;

  @override
  Widget build(BuildContext context) {
    final footerStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) *
              0.8,
          color: Colors.grey,
          height: _lineHeight,
        );

    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: DpdColors.primary, width: 1)),
      ),
      child: Text.rich(
        TextSpan(
          style: footerStyle,
          children: [
            TextSpan(text: prefix),
            WidgetSpan(
              child: _dpdLink(linkText, url, style: footerStyle),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
