import 'package:flutter/material.dart';

import '../theme/dpd_colors.dart';
import '../utils/date_utils.dart';
import 'entry_content.dart';
import 'root_matrix_builder.dart';

class RootMatrixTable extends StatelessWidget {
  const RootMatrixTable({super.key, required this.root, required this.data});

  final String root;
  final RootMatrixData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    final labelStyle = textStyle?.copyWith(
      color: DpdColors.primaryText,
      fontWeight: FontWeight.w700,
    );
    final headerStyle = textStyle?.copyWith(
      color: DpdColors.primaryText,
      fontWeight: FontWeight.w700,
    );

    // Measure the widest label across all non-empty subcategories so every
    // label cell uses the same fixed width — matching table column behaviour.
    final labelWidth = _measureMaxLabelWidth(context, labelStyle);
    final encodedRoot = Uri.encodeComponent(root);

    final children = <Widget>[];

    for (final categoryEntry in data.entries) {
      final subcats = categoryEntry.value;
      final nonEmpty = subcats.entries
          .where((e) => e.value.isNotEmpty)
          .toList();
      if (nonEmpty.isEmpty) continue;

      // Category header — full-width, primary border
      children.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(color: DpdColors.primary, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(5),
          child: Text(
            categoryEntry.key,
            textAlign: TextAlign.center,
            style: headerStyle,
          ),
        ),
      );

      // Subcategory rows — fixed-width label cell + expanding value cell.
      // IntrinsicHeight + CrossAxisAlignment.stretch make both cells equal height.
      for (final sub in nonEmpty) {
        children.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: _Cell(
                    margin: const EdgeInsets.only(bottom: 2, right: 2),
                    child: Text(sub.key, style: labelStyle),
                  ),
                ),
                Expanded(
                  child: _Cell(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Text(sub.value.join(', '), style: textStyle),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (children.isEmpty) {
      return DpdSectionContainer(
        child: Padding(
          padding: DpdColors.sectionPadding,
          child: Text(
            'No matrix data',
            style: textStyle?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    children.add(
      DpdFooter(
        messagePrefix: 'Something out of place?',
        linkText: 'Report it here',
        urlBuilder: () =>
            'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500=$encodedRoot&entry.326955045=Root+Matrix&entry.1433863141=${dpdAppLabel()}',
      ),
    );

    return DpdSectionContainer(
      child: Padding(
        padding: DpdColors.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  /// Returns the width to use for every label cell: the widest label text
  /// plus padding (5px each side) and border (1px each side).
  double _measureMaxLabelWidth(BuildContext context, TextStyle? style) {
    double maxTextWidth = 0;
    final painter = TextPainter(textDirection: TextDirection.ltr);

    for (final cat in data.values) {
      for (final entry in cat.entries) {
        if (entry.value.isEmpty) continue;
        painter.text = TextSpan(text: entry.key, style: style);
        painter.layout();
        if (painter.width > maxTextWidth) maxTextWidth = painter.width;
      }
    }

    painter.dispose();
    // padding: 5px left + 5px right = 10px; border: 1px left + 1px right = 2px
    return maxTextWidth + 10 + 2;
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.margin, required this.child});

  final EdgeInsets margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        border: Border.all(color: DpdColors.grayTransparent, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(5),
      child: child,
    );
  }
}
