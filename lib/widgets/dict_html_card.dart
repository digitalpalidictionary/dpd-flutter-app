import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;

import '../database/database.dart';
import '../theme/dpd_colors.dart';
import 'entry_content.dart';
import 'family_table.dart';

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
    return DpdSectionContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadingUnderlined(
              child: Text(
                dictName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DpdColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in entries) ...[
              HtmlWidget(
                entry.definitionHtml ?? '',
                customStylesBuilder: _coneStylesBuilder,
                textStyle: DefaultTextStyle.of(context).style,
              ),
              if (entry != entries.last) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

Map<String, String>? _coneStylesBuilder(dom.Element element) {
  final classes = element.classes;
  final tag = element.localName;

  if (tag == 'div' && classes.contains('lemma')) {
    return {
      'font-size': '15pt',
      'line-height': '17pt',
      'font-weight': '600',
      'color': 'orange',
    };
  }
  if (classes.contains('lemma') && tag == 'span') {
    return {'color': 'orange', 'font-weight': '600'};
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
  if (classes.contains('subsense')) {
    return {'display': 'inline'};
  }
  if (classes.contains('highlight')) {
    return {'background-color': '#fbff00', 'color': 'black'};
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
}
