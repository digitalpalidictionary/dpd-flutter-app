import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../theme/dpd_colors.dart';

class DpdHtmlTable extends StatelessWidget {
  const DpdHtmlTable({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: DpdColors.borderRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: DpdColors.borderRadius,
        child: Html(
          data: data,
          style: {
            "table": Style(
              width: Width(100, Unit.percent),
              margin: Margins.zero,
            ),
            "th": Style(
              padding: HtmlPaddings.all(5),
              border: Border.all(color: theme.colorScheme.primary, width: 1),
              color: DpdColors.primaryText,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.05,
              ),
            ),
            "td": Style(
              padding: HtmlPaddings.all(5),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
              textAlign: TextAlign.center,
            ),
          },
        ),
      ),
    );
  }
}
