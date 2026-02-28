import 'package:flutter/material.dart';

import '../models/inflection_table_data.dart';
import '../theme/dpd_colors.dart';

/// Renders a native Flutter inflection/conjugation table matching webapp styling.
///
/// Row height strategy:
///   - Data cells use [TableCellVerticalAlignment.middle] → they determine row height.
///   - Row-label cell uses [TableCellVerticalAlignment.fill] → stretches to row height.
///   - [TableRow.decoration] fills the background across the full row height.
/// Corner strategy:
///   - [TableBorder.all] with [borderRadius] handles rounded corners natively;
///     no [ClipRRect] needed, avoiding the corner-gap artefact.
class InflectionTable extends StatelessWidget {
  const InflectionTable({super.key, required this.data});

  final InflectionTableData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? DpdColors.dark : DpdColors.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildHeading(context),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: _buildTable(context, headerBg),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Heading: `<b>lemma</b> is <b>pattern</b> declension (like <b>like</b>)`
  /// No italics; bold on lemma, pattern, and like word only.
  Widget _buildHeading(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodySmall ?? const TextStyle();
    final bold = base.copyWith(fontWeight: FontWeight.bold);
    final d = data;

    final List<InlineSpan> spans = [
      TextSpan(text: d.headingLemma, style: bold),
      TextSpan(text: ' is ', style: base),
      TextSpan(text: d.headingPattern, style: bold),
      TextSpan(text: ' ${d.headingDeclLabel}', style: base),
    ];

    if (d.headingIsIrregular) {
      spans.add(TextSpan(text: ' (irregular)', style: base));
    } else if (d.headingLike != null) {
      spans.addAll([
        TextSpan(text: ' (like ', style: base),
        TextSpan(text: d.headingLike!, style: bold),
        TextSpan(text: ')', style: base),
      ]);
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildTable(BuildContext context, Color headerBg) {
    final colCount = data.headers.length;
    final columnWidths = <int, TableColumnWidth>{
      0: const IntrinsicColumnWidth(),
      for (int i = 1; i < colCount; i++) i: const IntrinsicColumnWidth(flex: 1.0),
    };

    return Table(
      columnWidths: columnWidths,
      // Data cells are middle (they set the row height).
      // Row-label cells individually override to fill.
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: DpdColors.primary,
        width: 1,
        borderRadius: BorderRadius.circular(DpdColors.borderRadiusValue),
      ),
      children: [
        _buildHeaderRow(context, headerBg),
        for (final row in data.rows) _buildDataRow(context, row, headerBg),
      ],
    );
  }

  TableRow _buildHeaderRow(BuildContext context, Color headerBg) {
    final theme = Theme.of(context);
    return TableRow(
      decoration: BoxDecoration(color: headerBg),
      children: data.headers.map((header) {
        return TableCell(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              header,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DpdColors.primaryText,
              ),
              softWrap: false,
            ),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildDataRow(
    BuildContext context,
    (String, List<InflectionCell>) row,
    Color headerBg,
  ) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final (rowLabel, cells) = row;

    return TableRow(
      // Surface colour fills the full row height for data cells.
      // The row-label cell paints over this with headerBg.
      decoration: BoxDecoration(color: surfaceColor),
      children: [
        // Row label: fill alignment so it stretches to full row height,
        // with headerBg painted over the row's surface background.
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            color: headerBg,
            padding: const EdgeInsets.all(5),
            alignment: Alignment.center,
            child: Text(
              rowLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DpdColors.primaryText,
              ),
              softWrap: false,
            ),
          ),
        ),
        // Data cells: middle alignment (default); they set the row height.
        // Background comes from TableRow.decoration (surfaceColor).
        for (final cell in cells)
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: cell.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: cell.forms
                          .map((form) => _buildFormText(context, form))
                          .toList(),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormText(BuildContext context, InflectionForm form) {
    if (form.ending.isEmpty) return const SizedBox.shrink();

    final base = Theme.of(context).textTheme.bodySmall ?? const TextStyle();

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: base,
        children: [
          if (form.stem.isNotEmpty) TextSpan(text: form.stem),
          TextSpan(
            text: form.ending,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
