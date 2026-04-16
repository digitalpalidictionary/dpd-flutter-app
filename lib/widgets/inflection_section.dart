import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../models/inflection_table_builder.dart';
import '../providers/database_provider.dart';
import '../theme/dpd_colors.dart';
import '../widgets/entry_content.dart';
import 'conjugation_form_sheet.dart';
import 'declension_form_sheet.dart';
import 'inflection_table.dart';

/// Renders the complete inflection section: dynamic table + footer.
///
/// Pass [templateCache] from [templateCacheProvider]. If the template is not
/// found or the stem is indeclinable, the table part is omitted gracefully.
///
/// Occurrence data (gray forms) is loaded lazily per-table via a targeted
/// lookup query — only the ~50-200 words in this specific table are checked.
class InflectionSection extends ConsumerStatefulWidget {
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
  ConsumerState<InflectionSection> createState() => _InflectionSectionState();
}

class _InflectionSectionState extends ConsumerState<InflectionSection> {
  Set<String>? _occurrenceSet;

  @override
  void initState() {
    super.initState();
    _loadOccurrences();
  }

  @override
  void didUpdateWidget(InflectionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headword.id != widget.headword.id) {
      setState(() => _occurrenceSet = null);
      _loadOccurrences();
    }
  }

  Future<void> _loadOccurrences() async {
    final h = widget.headword;
    final pattern = h.pattern;
    final template = pattern != null ? widget.templateCache[pattern] : null;
    if (template == null) return;

    final words = extractWordForms(stem: h.stem, templateData: template.data);
    if (words.isEmpty) return;

    final existing = await ref.read(daoProvider).checkWordsInLookup(words);
    if (mounted) setState(() => _occurrenceSet = existing);
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.headword;
    final pattern = h.pattern;
    final template = pattern != null ? widget.templateCache[pattern] : null;

    final tableData = template != null
        ? buildInflectionTable(
            stem: h.stem,
            pattern: h.pattern,
            pos: h.pos,
            lemma1: h.lemma1,
            templateLike: template.templateLike,
            templateData: template.data,
            lookupKeys: _occurrenceSet,
          )
        : null;

    return DpdSectionContainer(
      child: Padding(
        padding: DpdColors.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tableData != null) ...[
              InflectionTable(data: tableData, lookupKey: widget.lookupKey),
            ],
            _InflectionFooter(
              headwordId: h.id,
              lemma1: h.lemma1,
              isConjugation: h.inflectionButtonLabel == 'conjugation',
            ),
          ],
        ),
      ),
    );
  }
}

class _InflectionFooter extends StatelessWidget {
  const _InflectionFooter({
    required this.headwordId,
    required this.lemma1,
    required this.isConjugation,
  });

  final int headwordId;
  final String lemma1;
  final bool isConjugation;

  @override
  Widget build(BuildContext context) {
    return DpdFooter(
      messagePrefix: 'Did you spot a mistake?',
      linkText: 'Correct it here',
      customOnTap: (context) {
        if (isConjugation) {
          showConjugationSheet(
            context,
            headword: lemma1,
            headwordId: headwordId,
          );
          return;
        }
        showDeclensionSheet(
          context,
          headword: lemma1,
          headwordId: headwordId,
        );
      },
    );
  }
}
