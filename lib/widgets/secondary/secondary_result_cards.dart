import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/lookup_results.dart';
import '../../theme/dpd_colors.dart';
import '../../utils/date_utils.dart';
import '../../utils/pali_sort.dart';
import '../entry_content.dart';
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
      footer: _DeconstructorFooter(encodedHeadword: encodedHeadword),
    );
  }
}

class _DeconstructorFooter extends StatelessWidget {
  const _DeconstructorFooter({required this.encodedHeadword});

  final String encodedHeadword;

  @override
  Widget build(BuildContext context) {
    const baseUrl =
        'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url';
    final docsUrl =
        'https://digitalpalidictionary.github.io/features/deconstructor/';
    final suggestUrl =
        '$baseUrl&entry.438735500=$encodedHeadword&entry.326955045=Deconstructor&entry.1433863141=${dpdAppLabel()}';
    final addWordsUrl =
        'https://docs.google.com/forms/d/e/1FAIpQLSfResxEUiRCyFITWPkzoQ2HhHEvUS5fyg68Rl28hFH6vhHlaA/viewform?entry.1433863141=${dpdAppLabel()}';

    const footerStyle = TextStyle(fontSize: 12.8, color: Colors.grey);
    final linkStyle = TextStyle(
      fontSize: 12.8,
      color: DpdColors.primaryText,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.none,
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
              text:
                  'These word breakups are code-generated. For more information, ',
            ),
            WidgetSpan(
              child: InkWell(
                onTap: () => launchUrl(
                  Uri.parse(docsUrl),
                  mode: LaunchMode.platformDefault,
                ),
                child: Text('read the docs', style: linkStyle),
              ),
            ),
            const TextSpan(text: '. Please '),
            WidgetSpan(
              child: InkWell(
                onTap: () => launchUrl(
                  Uri.parse(suggestUrl),
                  mode: LaunchMode.platformDefault,
                ),
                child: Text('suggest any improvements here', style: linkStyle),
              ),
            ),
            const TextSpan(
              text:
                  '. Mistakes in deconstruction are usually caused by a word missing from the dictionary. You can ',
            ),
            WidgetSpan(
              child: InkWell(
                onTap: () => launchUrl(
                  Uri.parse(addWordsUrl),
                  mode: LaunchMode.platformDefault,
                ),
                child: Text('add missing words here', style: linkStyle),
              ),
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
      footer: DpdFooter(
        messagePrefix: 'For more information, please',
        linkText: 'read the docs',
        customUrlBuilder: () => docsUrl,
      ),
    );
  }
}

class _GrammarDictTable extends StatefulWidget {
  const _GrammarDictTable({required this.entries});

  final List<GrammarDictEntry> entries;

  @override
  State<_GrammarDictTable> createState() => _GrammarDictTableState();
}

class _GrammarDictTableState extends State<_GrammarDictTable> {
  int? _sortColumn;
  bool _ascending = true;

  void _onHeaderTap(int column) {
    setState(() {
      if (_sortColumn == column) {
        if (_ascending) {
          _ascending = false;
        } else {
          _sortColumn = null;
          _ascending = true;
        }
      } else {
        _sortColumn = column;
        _ascending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: _lineHeight);
    final boldStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w700);

    int maxComps = 0;
    for (final entry in widget.entries) {
      for (int i = entry.components.length - 1; i >= 0; i--) {
        if (entry.components[i].isNotEmpty) {
          if (i + 1 > maxComps) maxComps = i + 1;
          break;
        }
      }
    }

    final totalCols = 1 + maxComps + 1 + 1; // pos + comps + "of" + word
    final posCol = 0;
    final wordCol = totalCols - 1;

    final sorted = List<GrammarDictEntry>.of(widget.entries);
    if (_sortColumn != null) {
      final col = _sortColumn!;
      final usePali = col == posCol || col == wordCol;
      sorted.sort((a, b) {
        String aVal, bVal;
        if (col == posCol) {
          aVal = a.pos;
          bVal = b.pos;
        } else if (col == wordCol) {
          aVal = a.headword;
          bVal = b.headword;
        } else {
          final compIdx = col - 1;
          aVal = compIdx < a.components.length ? a.components[compIdx] : '';
          bVal = compIdx < b.components.length ? b.components[compIdx] : '';
        }
        final cmp = usePali
            ? paliSortKey(aVal).compareTo(paliSortKey(bVal))
            : aVal.compareTo(bVal);
        return _ascending ? cmp : -cmp;
      });
    }

    String arrow(int col) {
      if (_sortColumn != col) return ' ⇅';
      return _ascending ? ' ▲' : ' ▼';
    }

    Widget sortableHeader(String label, int col, {TextStyle? style}) {
      return GestureDetector(
        onTap: () => _onHeaderTap(col),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
          child: Text('$label${arrow(col)}', style: style),
        ),
      );
    }

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            sortableHeader('pos', posCol, style: boldStyle),
            ...List.generate(
              maxComps,
              (i) => sortableHeader('', 1 + i, style: bodyStyle),
            ),
            _cell('', style: bodyStyle),
            sortableHeader('word', wordCol, style: boldStyle),
          ],
        ),
        for (final entry in sorted)
          TableRow(
            children: [
              _cell(entry.pos, style: boldStyle),
              ...List.generate(
                maxComps,
                (i) => _cell(
                  i < entry.components.length ? entry.components[i] : '',
                  style: bodyStyle,
                ),
              ),
              _cell('of', style: bodyStyle),
              _cell(entry.headword, style: bodyStyle),
            ],
          ),
      ],
    );
  }

  Widget _cell(String text, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
      child: Text(text, style: style),
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
      content: _HelpStyleTable(
        rows: [
          ('Abbreviation', result.headword, true),
          ('Meaning', result.meaning, false),
          if (result.pali != null && result.pali!.isNotEmpty)
            ('Pāḷi', result.pali!, false),
          if (result.example != null && result.example!.isNotEmpty)
            ('Example', result.example!, false),
          if (result.explanation != null && result.explanation!.isNotEmpty)
            ('Information', result.explanation!, false),
        ],
      ),
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
      content: _HelpStyleTable(
        rows: [
          ('Help', result.headword, true),
          ('Meaning', result.helpText, false),
        ],
      ),
    );
  }
}

class _HelpStyleTable extends StatelessWidget {
  const _HelpStyleTable({required this.rows});

  /// Each entry: (label, value, bold)
  final List<(String, String, bool)> rows;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: _lineHeight);

    return Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: rows.map(((String, String, bool) row) {
        final (label, value, bold) = row;
        return TableRow(
          children: [
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
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                value,
                style: bold
                    ? bodyStyle?.copyWith(fontWeight: FontWeight.w700)
                    : bodyStyle,
              ),
            ),
          ],
        );
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
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: _lineHeight);

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
    const docsUrl =
        'https://digitalpalidictionary.github.io/features/variants/';

    return DpdSecondaryCard(
      title: 'variants: ${result.headword}',
      content: _VariantTable(variants: result.variants),
      footer: DpdFooter(
        messagePrefix: 'For details on how to use this, please',
        linkText: 'read the docs',
        customUrlBuilder: () => docsUrl,
      ),
    );
  }
}

class _VariantTable extends StatelessWidget {
  const _VariantTable({required this.variants});

  final Map<String, Map<String, List<List<String>>>> variants;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: _lineHeight);
    final headerStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w700);

    final corpusList = variants.keys.toList();
    final rows = <TableRow>[];

    // Header row
    rows.add(
      TableRow(
        children: [
          for (final h in ['source', 'filename', 'context', 'variant'])
            _cell(h, style: headerStyle),
        ],
      ),
    );

    for (int ci = 0; ci < corpusList.length; ci++) {
      final corpus = corpusList[ci];

      // Separator row between corpus groups (1px height so decoration renders)
      if (ci > 0) {
        rows.add(
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: DpdColors.grayTransparent, width: 1),
              ),
            ),
            children: List.generate(4, (_) => const SizedBox(height: 1)),
          ),
        );
      }

      for (final book in variants[corpus]!.keys) {
        for (final entry in variants[corpus]![book]!) {
          rows.add(
            TableRow(
              children: [
                _cell(corpus, style: bodyStyle, noWrap: true),
                _cell(book, style: bodyStyle, noWrap: true),
                _cell(entry[0], style: bodyStyle),
                _cell(entry[1], style: bodyStyle),
              ],
            ),
          );
        }
      }
    }

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: rows,
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
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: _lineHeight);
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
              if (i < result.spellings.length - 1) const TextSpan(text: '\n'),
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
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: _lineHeight);
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
