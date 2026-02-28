import 'package:flutter/material.dart';

import '../models/inflection_table_data.dart';
import '../theme/dpd_colors.dart';

/// Renders a native Flutter inflection/conjugation table matching webapp styling.
///
/// Layout mirrors the webapp CSS:
/// - `border-collapse: separate` → each cell has its own BoxDecoration border + radius
/// - `th`: primary border, header background, bold text
/// - `td`: gray border, centered text
/// - Table fills available width; scrolls horizontally when wider than parent
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
            // Fill available width; scroll horizontally when wider
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

  /// Renders the heading with bold lemma, pattern, and "like" word — no italics.
  /// Matches: `<b>lemma</b> is <b>pattern</b> declension (like <b>like</b>)`
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
    // Row-label column: fixed intrinsic width; data columns: grow to fill
    final columnWidths = <int, TableColumnWidth>{
      0: const IntrinsicColumnWidth(),
      for (int i = 1; i < colCount; i++) i: const IntrinsicColumnWidth(flex: 1.0),
    };

    return Table(
      columnWidths: columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildHeaderRow(context, headerBg),
        for (final row in data.rows) _buildDataRow(context, row, headerBg),
      ],
    );
  }

  TableRow _buildHeaderRow(BuildContext context, Color headerBg) {
    final theme = Theme.of(context);
    return TableRow(
      children: data.headers.map((header) {
        return _thCell(
          headerBg: headerBg,
          child: Text(
            header,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: DpdColors.primaryText,
            ),
            softWrap: false,
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
    final (rowLabel, cells) = row;

    return TableRow(
      children: [
        // Row label: th-styled (header background + primary border)
        _thCell(
          headerBg: headerBg,
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
        // Data cells: td-styled (gray border)
        for (final cell in cells)
          _tdCell(
            child: cell.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: cell.forms
                        .map((form) => _buildFormText(context, form))
                        .toList(),
                  ),
          ),
      ],
    );
  }

  /// Header cell: primary border, header background, centered content.
  /// Matches CSS `table.inflection th`.
  Widget _thCell({required Color headerBg, required Widget child}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            color: headerBg,
            border: Border.all(color: DpdColors.primary, width: 1),
            borderRadius: BorderRadius.circular(7),
          ),
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  /// Data cell: gray border, centered content.
  /// Matches CSS `table.inflection td`.
  Widget _tdCell({required Widget child}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: DpdColors.gray, width: 1),
            borderRadius: BorderRadius.circular(7),
          ),
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          child: child,
        ),
      ),
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
