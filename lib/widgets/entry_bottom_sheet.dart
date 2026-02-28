import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/settings_provider.dart';
import 'dpd_html_table.dart';
import 'entry_content.dart';

class EntryBottomSheet extends ConsumerWidget {
  const EntryBottomSheet({
    super.key,
    required this.headword,
    required this.scrollController,
  });

  final DpdHeadword headword;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final h = headword;

    final grammarRows = buildGrammarRows(h);
    final familyRows = buildFamilyRows(h);
    final hasInflections =
        (h.inflectionsHtml != null && h.inflectionsHtml!.isNotEmpty) ||
        (h.freqHtml != null && h.freqHtml!.isNotEmpty);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
      child: ListView(
        controller: scrollController,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Pinned header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.lemma1,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (h.pos != null)
                  Text(
                    posGrammarLine(h),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),

          // Summary box
          EntrySummaryBox(headword: h),

          // Grammar
          if (grammarRows.isNotEmpty)
            ExpansionTile(
              title: const Text('Grammar'),
              initiallyExpanded: settings.grammarOpen,
              children: grammarRows
                  .map((r) => EntryLabelValue(label: r.$1, value: r.$2))
                  .toList(),
            ),

          // Examples
          if (hasExamples)
            ExpansionTile(
              title: const Text('Examples'),
              initiallyExpanded: settings.examplesOpen,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasEx1)
                        EntryExampleBlock(
                          example: h.example1!,
                          sutta: h.sutta1,
                          source: h.source1,
                        ),
                      if (hasEx1 && hasEx2) const SizedBox(height: 16),
                      if (hasEx2)
                        EntryExampleBlock(
                          example: h.example2!,
                          sutta: h.sutta2,
                          source: h.source2,
                        ),
                    ],
                  ),
                ),
              ],
            ),

          // Inflections
          if (hasInflections)
            ExpansionTile(
              title: const Text('Inflections'),
              initiallyExpanded: false,
              children: [
                if (h.inflectionsHtml != null && h.inflectionsHtml!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DpdHtmlTable(data: h.inflectionsHtml!),
                  ),
                if (h.freqHtml != null && h.freqHtml!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text('Frequency', style: theme.textTheme.titleSmall),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: DpdHtmlTable(data: h.freqHtml!),
                  ),
                ],
              ],
            ),

          // Families
          if (familyRows.isNotEmpty)
            ExpansionTile(
              title: const Text('Families'),
              initiallyExpanded: false,
              children: familyRows
                  .map((r) => EntryLabelValue(label: r.$1, value: r.$2))
                  .toList(),
            ),

          // Notes
          if (h.notes != null && h.notes!.isNotEmpty)
            ExpansionTile(
              title: const Text('Notes'),
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(h.notes!),
                ),
              ],
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
