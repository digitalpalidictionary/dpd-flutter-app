import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:url_launcher/url_launcher.dart';

import '../database/database.dart';
import '../theme/dpd_colors.dart';

final _hTagRe = RegExp(r'<strong>\((?:H\d[A-Z]?|C\d)\)</strong>\s*');
final _docWrapRe = RegExp(
  r'<!DOCTYPE[^>]*>.*?<body>|</body>.*?</html>',
  dotAll: true,
  caseSensitive: false,
);

final _tooltipSpanRe = RegExp(
  r'''<span([^>]*?\bclass="[^"]*\bls\b[^"]*"[^>]*?)\btitle=["']([^"']+)["']([^>]*)>(.*?)</span>''',
  dotAll: true,
);

final _cpdH2OpenRe = RegExp(r'<h2\b[^>]*>', caseSensitive: false);
final _cpdH2CloseRe = RegExp(r'</h2>', caseSensitive: false);

String _prepareConeHtml(String html) {
  final doc = parse(html);
  doc.querySelector('div.lemma')?.remove();
  final highlights = doc.querySelectorAll('.subsense.highlight');
  if (highlights.isNotEmpty) {
    final buffer = StringBuffer();
    for (final el in highlights) {
      el.classes.remove('highlight');
      buffer.write(el.outerHtml);
    }
    return buffer.toString();
  }
  return doc.body?.innerHtml ?? html;
}

String _cleanMwHtml(String html) {
  html = html.replaceAll(_docWrapRe, '');
  html = html.replaceAll(_hTagRe, '');
  html = html.replaceAllMapped(_tooltipSpanRe, (m) {
    final before = m[1]!;
    final title = m[2]!;
    final after = m[3]!;
    final content = m[4]!;
    final encoded = Uri.encodeComponent(title);
    return '<a href="tooltip:$encoded"><span$before$after>$content</span></a>';
  });
  return html;
}

String prepareDictHtml(String dictId, String html) {
  if (dictId == 'cone') return _prepareConeHtml(html);
  if (dictId == 'mw') return _cleanMwHtml(html);
  if (dictId == 'cpd') {
    html = html.replaceAll(_cpdH2OpenRe, '<strong>');
    html = html.replaceAll(_cpdH2CloseRe, '</strong>');
  }
  return html;
}

class DictHtmlCard extends StatelessWidget {
  const DictHtmlCard({
    super.key,
    required this.dictName,
    required this.dictId,
    required this.entries,
  });

  final String dictName;
  final String dictId;
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
          ..._buildEntryWidgets(context, entry, stylesBuilder),
          if (entry != entries.last) const SizedBox(height: 16),
        ],
      ],
    );
  }

  List<Widget> _buildEntryWidgets(
    BuildContext context,
    DictEntry entry,
    Map<String, String>? Function(dom.Element) stylesBuilder,
  ) {
    final raw = entry.definitionHtml ?? '';
    final html = prepareDictHtml(dictId, raw);

    return [
      Text(
        entry.word,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      HtmlWidget(
        html,
        customStylesBuilder: stylesBuilder,
        onTapUrl: (url) {
          if (url.startsWith('tooltip:')) {
            final text = Uri.decodeComponent(url.substring(8));
            _showTooltip(context, text);
            return true;
          }
          final uri = Uri.tryParse(url);
          if (uri != null && uri.hasScheme) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
            return true;
          }
          return false;
        },
        textStyle: DefaultTextStyle.of(context).style,
      ),
    ];
  }
}

Map<String, String>? Function(dom.Element) _buildStylesBuilder(bool isDark) {
  final lemmaColor = _colorToCSS(
    isDark ? DpdColors.primaryTextDark : DpdColors.primaryText,
  );
  final highlightBg = _colorToCSS(
    isDark
        ? DpdColors.primaryAlt.withValues(alpha: 0.4)
        : DpdColors.primaryAlt.withValues(alpha: 0.4),
  );
  final highlightText = isDark ? 'black' : 'white';

  final blueColor = _colorToCSS(
    isDark ? DpdColors.primaryTextDark : DpdColors.primaryText,
  );
  final redColor = _colorToCSS(
    isDark ? DpdColors.accentRedDark : DpdColors.accentRed,
  );
  final greenColor = _colorToCSS(
    isDark ? DpdColors.accentGreenDark : DpdColors.accentGreen,
  );
  final orangeColor = _colorToCSS(
    isDark ? DpdColors.accentOrangeDark : DpdColors.accentOrange,
  );
  final purpleColor = _colorToCSS(
    isDark ? DpdColors.accentPurpleDark : DpdColors.accentPurple,
  );
  final brownColor = _colorToCSS(
    isDark ? DpdColors.accentBrownDark : DpdColors.accentBrown,
  );
  final grayColor = _colorToCSS(isDark ? DpdColors.grayLight : DpdColors.gray);

  return (dom.Element element) {
    final classes = element.classes;
    final tag = element.localName;

    if (tag == 'a') {
      final href = element.attributes['href'] ?? '';
      if (href.startsWith('tooltip:')) {
        return {'text-decoration': 'none', 'color': 'inherit'};
      }
    }

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
      return {'color': blueColor};
    }
    if (classes.contains('orange')) {
      return {'color': orangeColor};
    }
    if (classes.contains('green')) {
      return {'color': greenColor};
    }
    if (classes.contains('red')) {
      return {'color': redColor};
    }
    if (classes.contains('purple')) {
      return {'color': purpleColor};
    }
    if (classes.contains('dim')) {
      return {'color': blueColor};
    }
    if (classes.contains('kharHide')) {
      return {'display': 'none'};
    }
    if (classes.contains('id')) {
      return {'font-size': '10px'};
    }
    if (classes.contains('more')) {
      return {'color': grayColor, 'font-style': 'italic', 'font-size': '12px'};
    }

    // MW (Monier-Williams) — themed from mw.css
    if (classes.contains('sdata')) {
      return {'color': blueColor, 'font-style': 'italic'};
    }
    if (classes.contains('hom')) {
      return {'color': redColor};
    }
    if (classes.contains('ls')) {
      return {'color': blueColor, 'font-size': '10pt'};
    }
    if (classes.contains('gram') ||
        classes.contains('divm') ||
        classes.contains('fn-label')) {
      return {'font-weight': 'bold'};
    }
    if (classes.contains('greek')) {
      return {'font-style': 'italic'};
    }
    if (classes.contains('dotunder')) {
      return null;
    }
    if (classes.contains('lnum')) {
      return {
        'font-size': 'smaller',
        'background-color': _colorToCSS(
          isDark ? DpdColors.darkShade : DpdColors.lightShade,
        ),
      };
    }
    if (classes.contains('g') || classes.contains('lang')) {
      return {'font-size': 'smaller', 'font-style': 'italic'};
    }
    if (classes.contains('pb') ||
        classes.contains('footnote') ||
        classes.contains('alt-hw')) {
      return {'font-size': 'smaller'};
    }
    if (classes.contains('foreign')) {
      return {'color': brownColor};
    }
    if (classes.contains('div-sep')) {
      return {'margin-top': '0.6em'};
    }
    if (classes.contains('pcol-ref')) {
      return {'color': grayColor, 'font-size': 'smaller'};
    }
    if (classes.contains('record-id')) {
      return {'color': grayColor};
    }

    return null;
  };
}

void _showTooltip(BuildContext context, String text) {
  final overlay = Overlay.of(context);
  final renderBox = context.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      return GestureDetector(
        onTap: () => entry.remove(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              top: 200,
              child: Center(
                child: Material(
                  elevation: 4,
                  borderRadius: DpdColors.borderRadius,
                  color: DpdColors.primaryAlt,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      text,
                      style: TextStyle(color: DpdColors.light, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}

String _colorToCSS(Color c) {
  return 'rgb(${(c.r * 255).round()}, ${(c.g * 255).round()}, ${(c.b * 255).round()})';
}
