import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;

import '../database/database.dart';
import '../theme/dpd_colors.dart';

class DictHtmlCard extends StatelessWidget {
  const DictHtmlCard({
    super.key,
    required this.dictName,
    required this.entries,
  });

  final String dictName;
  final List<DictEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stylesBuilder = _buildStylesBuilder(isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: DpdColors.primary.withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        Text(
          dictName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: DpdColors.primary.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
        for (final entry in entries) ...[
          HtmlWidget(
            entry.definitionHtml ?? '',
            customStylesBuilder: stylesBuilder,
            textStyle: DefaultTextStyle.of(context).style,
          ),
          if (entry != entries.last) const Divider(height: 24),
        ],
      ],
    );
  }
}

Map<String, String>? Function(dom.Element) _buildStylesBuilder(bool isDark) {
  final lemmaColor = _colorToCSS(isDark ? DpdColors.primaryTextDark : DpdColors.primaryText);
  final highlightBg = _colorToCSS(isDark
      ? DpdColors.primaryAlt.withValues(alpha: 0.4)
      : DpdColors.lightShade);
  final highlightText = isDark ? 'white' : 'black';

  return (dom.Element element) {
    final classes = element.classes;
    final tag = element.localName;

    if (tag == 'div' && classes.contains('lemma')) {
      return {
        'font-size': '15pt',
        'line-height': '17pt',
        'font-weight': '600',
        'color': lemmaColor,
      };
    }
    if (classes.contains('lemma') && tag == 'span') {
      return {'color': lemmaColor, 'font-weight': '600'};
    }
    if (classes.contains('lemsuper')) {
      return {'font-size': '10px', 'vertical-align': 'super'};
    }
    if (classes.contains('morph')) {
      return {'font-style': 'italic'};
    }
    if (classes.contains('super') || classes.contains('qsuper')) {
      return {'font-size': '8px', 'vertical-align': 'super'};
    }
    if (classes.contains('subscript')) {
      return {'font-size': '8px', 'vertical-align': 'sub'};
    }
    if (classes.contains('subsense') && classes.contains('highlight')) {
      return {
        'display': 'inline',
        'background-color': highlightBg,
        'color': highlightText,
      };
    }
    if (classes.contains('subsense')) {
      return {'display': 'inline'};
    }
    if (classes.contains('highlight')) {
      return {'background-color': highlightBg, 'color': highlightText};
    }
    if (classes.contains('bold') ||
        classes.contains('sb') ||
        classes.contains('attestedform') ||
        classes.contains('cref')) {
      return {'font-weight': 'bold'};
    }
    if (classes.contains('italic') ||
        classes.contains('s') ||
        classes.contains('cognate')) {
      return {'font-style': 'italic'};
    }
    if (classes.contains('smallcaps') ||
        classes.contains('scaps') ||
        classes.contains('txtabbrev') ||
        classes.contains('easian')) {
      return {'font-variant': 'small-caps'};
    }
    if (classes.contains('blue')) {
      return {'color': 'rgb(0, 115, 177)'};
    }
    if (classes.contains('orange')) {
      return {'color': '#ba4200'};
    }
    if (classes.contains('green')) {
      return {'color': 'green'};
    }
    if (classes.contains('red')) {
      return {'color': 'red'};
    }
    if (classes.contains('purple')) {
      return {'color': 'purple'};
    }
    if (classes.contains('dim')) {
      return {'color': '#648cc8'};
    }
    if (classes.contains('kharHide')) {
      return {'display': 'none'};
    }
    if (classes.contains('id')) {
      return {'font-size': '10px'};
    }
    if (classes.contains('more')) {
      return {'color': 'gray', 'font-style': 'italic', 'font-size': '12px'};
    }
    return null;
  };
}

String _colorToCSS(Color c) {
  return 'rgb(${(c.r * 255).round()}, ${(c.g * 255).round()}, ${(c.b * 255).round()})';
}
