import 'package:flutter/material.dart';

import '../models/inflection_table_data.dart';
import '../theme/dpd_colors.dart';
import 'double_tap_search_wrapper.dart';

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
  const InflectionTable({super.key, required this.data, this.lookupKey});

  final InflectionTableData data;

  /// When non-null and non-empty, any form whose [InflectionForm.word] exactly
  /// matches [lookupKey] is rendered with a yellow highlight — matching the
  /// webapp's `.inflection-highlight` style.
  final String? lookupKey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? DpdColors.dark : DpdColors.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeading(context),
            const SizedBox(height: 8),
            // Use SelectionContainer.disabled on the scrollable to prevent the root
            // SelectionArea from crashing on nested scrollables.
            // Then wrap the internal content in another DoubleTapSearchWrapper to
            // keep the table searchable.
            SelectionContainer.disabled(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DoubleTapSearchWrapper(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: _buildTable(context, headerBg, constraints.maxWidth),
                  ),
                ),
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
    final base = theme.textTheme.bodyMedium ?? const TextStyle();
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

  Widget _buildTable(
    BuildContext context,
    Color headerBg,
    double availableWidth,
  ) {
    // Minimum widths
    const double minLabelWidth = 80.0;
    const double minDataWidth = 100.0;

    final int colCount = data.headers.length;
    // total min width = label + (data columns)
    final double minTotalWidth =
        minLabelWidth + ((colCount - 1) * minDataWidth);

    // If available width is greater, scale up proportionally
    final double scale =
        availableWidth > minTotalWidth ? availableWidth / minTotalWidth : 1.0;

    final double labelWidth = minLabelWidth * scale;
    final double dataWidth = minDataWidth * scale;
    final double totalWidth = labelWidth + ((colCount - 1) * dataWidth);

    return SizedBox(
      width: totalWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context, headerBg, labelWidth, dataWidth),
          for (final row in data.rows)
            _buildDataRow(
              context,
              row,
              headerBg,
              lookupKey,
              labelWidth,
              dataWidth,
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context, 
    Color headerBg, 
    double labelWidth, 
    double dataWidth,
  ) {
    final theme = Theme.of(context);
    final headers = data.headers;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row Label Column Header (usually empty or "Case")
          _buildCellContainer(
            context,
            width: labelWidth,
            color: headerBg,
            borderColor: DpdColors.primary,
            child: Text(
              headers.isNotEmpty ? headers[0] : '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DpdColors.primaryText,
              ),
            ),
          ),
          // Data Column Headers
          for (int i = 1; i < headers.length; i++)
            _buildCellContainer(
              context,
              width: dataWidth,
              color: headerBg,
              borderColor: DpdColors.primary,
              child: Text(
                headers[i],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DpdColors.primaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    (String, List<InflectionCell>) row,
    Color headerBg,
    String? lookupKey,
    double labelWidth,
    double dataWidth,
  ) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final (rowLabel, cells) = row;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row Label
          _buildCellContainer(
            context,
            width: labelWidth,
            color: headerBg,
            borderColor: DpdColors.primary,
            child: Text(
              rowLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DpdColors.primaryText,
              ),
            ),
          ),
          // Data Cells
          for (final cell in cells)
            _buildCellContainer(
              context,
              width: dataWidth,
              color: surfaceColor,
              borderColor: DpdColors.grayTransparent,
              child: cell.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: cell.forms
                          .map((form) =>
                              _buildFormText(context, form, lookupKey))
                          .toList(),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildCellContainer(
    BuildContext context, {
    required double width,
    required Color color,
    required Color borderColor,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: DpdColors.borderRadius,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget _buildFormText(BuildContext context, InflectionForm form, String? lookupKey) {
    if (form.ending.isEmpty) return const SizedBox.shrink();

    final base = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    final isMatch =
        lookupKey != null && lookupKey.isNotEmpty && form.word == lookupKey.trim();

    final richText = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        // Highlighted forms use onPrimary text on primary blue; normal forms use default.
        style: isMatch
            ? base.copyWith(color: Theme.of(context).colorScheme.onPrimary)
            : base,
        children: [
          if (form.stem.isNotEmpty) TextSpan(text: form.stem),
          TextSpan(
            text: form.ending,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (!isMatch) return richText;

    return Container(
      decoration: BoxDecoration(
        color: DpdColors.primary,
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: richText,
    );
  }
}
