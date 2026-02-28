import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../theme/dpd_colors.dart';

class DpdHtmlTable extends StatelessWidget {
  const DpdHtmlTable({
    super.key,
    required this.data,
    this.isBorderless = false,
  });

  final String data;
  final bool isBorderless;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: DpdColors.borderRadius,
        border: isBorderless
            ? null
            : Border.all(
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
              border: isBorderless
                  ? Border.all(width: 0, color: Colors.transparent)
                  : null,
            ),
            "th": Style(
              padding: HtmlPaddings.all(5),
              border: isBorderless
                  ? Border.all(width: 0, color: Colors.transparent)
                  : Border.all(color: theme.colorScheme.primary, width: 1),
              color: DpdColors.primaryText,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
              backgroundColor: isBorderless
                  ? Colors.transparent
                  : theme.colorScheme.primary.withValues(alpha: 0.05),
              whiteSpace: isBorderless ? WhiteSpace.pre : null,
            ),
            "td": Style(
              padding: HtmlPaddings.all(5),
              border: isBorderless
                  ? Border.all(width: 0, color: Colors.transparent)
                  : Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
              textAlign: isBorderless ? TextAlign.left : TextAlign.center,
              fontSize: FontSize(0.8, Unit.em),
            ),
            // Frequency Heatmap Classes
            ".gr1": Style(
              backgroundColor: DpdColors.freq[0],
              color: DpdColors.dark,
            ),
            ".gr2": Style(
              backgroundColor: DpdColors.freq[1],
              color: DpdColors.dark,
            ),
            ".gr3": Style(
              backgroundColor: DpdColors.freq[2],
              color: DpdColors.dark,
            ),
            ".gr4": Style(
              backgroundColor: DpdColors.freq[3],
              color: DpdColors.dark,
            ),
            ".gr5": Style(
              backgroundColor: DpdColors.freq[4],
              color: DpdColors.dark,
            ),
            ".gr6": Style(
              backgroundColor: DpdColors.freq[5],
              color: DpdColors.light,
            ),
            ".gr7": Style(
              backgroundColor: DpdColors.freq[6],
              color: DpdColors.light,
            ),
            ".gr8": Style(
              backgroundColor: DpdColors.freq[7],
              color: DpdColors.light,
            ),
            ".gr9": Style(
              backgroundColor: DpdColors.freq[8],
              color: DpdColors.light,
            ),
            ".gr10": Style(
              backgroundColor: DpdColors.freq[9],
              color: DpdColors.light,
            ),
          },
        ),
      ),
    );
  }
}
