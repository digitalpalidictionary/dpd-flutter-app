import 'package:flutter/material.dart';

import '../database/database.dart';
import '../models/inflection_table_builder.dart';
import '../theme/dpd_colors.dart';
import '../widgets/entry_content.dart';
import 'inflection_table.dart';

/// Renders the complete inflection section: dynamic table + footer.
///
/// Pass [templateCache] from [templateCacheProvider]. If the template is not
/// found or the stem is indeclinable, the table part is omitted gracefully.
class InflectionSection extends StatelessWidget {
  const InflectionSection({
    super.key,
    required this.headword,
    required this.templateCache,
    this.lookupKey,
  });

  final DpdHeadwordWithRoot headword;
  final Map<String, InflectionTemplate> templateCache;

  /// The exact search term to highlight in the table. Passed through to
  /// [InflectionTable]; null or empty means no highlight.
  final String? lookupKey;

  @override
  Widget build(BuildContext context) {
    final h = headword;
    final pattern = h.pattern;
    final template = pattern != null ? templateCache[pattern] : null;

    final tableData = template != null
        ? buildInflectionTable(
            stem: h.stem,
            pattern: h.pattern,
            pos: h.pos,
            lemma1: h.lemma1,
            templateLike: template.templateLike,
            templateData: template.data,
          )
        : null;

    return Padding(
      padding: DpdColors.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tableData != null) ...[
            InflectionTable(data: tableData, lookupKey: lookupKey),
            const SizedBox(height: 12),
          ],
          _InflectionFooter(headwordId: h.id, lemma1: h.lemma1),
        ],
      ),
    );
  }
}

class _InflectionFooter extends StatelessWidget {
  const _InflectionFooter({required this.headwordId, required this.lemma1});

  final int headwordId;
  final String lemma1;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final encodedLemma = Uri.encodeComponent(lemma1);

    return DpdFooter(
      messagePrefix: 'Did you spot a mistake?',
      linkText: 'Correct it here',
      urlBuilder: () =>
          'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500=$headwordId%20$encodedLemma&entry.326955045=Inflection&entry.1433863141=DPD+$date',
    );
  }
}

/// Determine if a headword has inflection content to show.
/// Indeclinables (stem == '-') never get an inflection button.
bool hasInflectionContent(DpdHeadwordWithRoot h) {
  if (h.stem == '-') return false;
  return h.stem != null && h.pattern != null && h.pattern!.isNotEmpty;
}

/// Returns the button label based on the headword's pos.
/// Uses [DpdColors] constants — delegates to the builder's logic.
String inflectionButtonLabel(String? pos) {
  const conjugationPos = {
    'aor',
    'cond',
    'fut',
    'imp',
    'imperf',
    'opt',
    'perf',
    'pr',
  };
  return conjugationPos.contains(pos) ? 'Conjugation' : 'Declension';
}
