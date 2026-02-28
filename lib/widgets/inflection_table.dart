import 'package:flutter/material.dart';

import '../models/inflection_table_data.dart';
import '../theme/dpd_colors.dart';

/// Renders a native Flutter inflection/conjugation table matching webapp styling.
class InflectionTable extends StatelessWidget {
  const InflectionTable({super.key, required this.data});

  final InflectionTableData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = DpdColors.primary;
    final headerBg = isDark ? DpdColors.dark : DpdColors.light;

    // All columns use IntrinsicColumnWidth so the table sizes to content,
    // which also works correctly inside a horizontal SingleChildScrollView.
    final colCount = data.headers.length;
    final columnWidths = <int, TableColumnWidth>{
      for (int i = 0; i < colCount; i++) i: const IntrinsicColumnWidth(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            data.headingText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Table: SingleChildScrollView with IntrinsicColumnWidth works correctly
        // because IntrinsicColumnWidth does not need a bounded parent width.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius: DpdColors.borderRadius,
            child: Table(
              columnWidths: columnWidths,
              border: TableBorder.all(color: borderColor, width: 1),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _buildHeaderRow(context, headerBg),
                for (final row in data.rows)
                  _buildDataRow(context, row, headerBg),
              ],
            ),
          ),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              header,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DpdColors.primaryText,
              ),
              softWrap: false,
              overflow: TextOverflow.visible,
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
    final (rowLabel, cells) = row;

    return TableRow(
      children: [
        // Row label cell (bold, header background)
        TableCell(
          child: Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              rowLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DpdColors.primaryText,
              ),
              softWrap: false,
            ),
          ),
        ),
        // Data cells
        for (final cell in cells)
          TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: cell.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: cell.forms.map((form) {
                        return _buildFormText(context, form);
                      }).toList(),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormText(BuildContext context, InflectionForm form) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall ?? const TextStyle();

    if (form.ending.isEmpty) return const SizedBox.shrink();

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
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
