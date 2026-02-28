import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/entry_content.dart';

final _entryProvider =
    FutureProvider.autoDispose.family<DpdHeadword?, int>((ref, id) {
  return ref.watch(daoProvider).getById(id);
});

class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key, required this.headwordId});

  final int headwordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(_entryProvider(headwordId));

    return entry.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (headword) {
        if (headword == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Entry not found')),
          );
        }
        return _EntryView(headword: headword);
      },
    );
  }
}

class _EntryView extends ConsumerWidget {
  const _EntryView({required this.headword});

  final DpdHeadword headword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    final grammarRows = buildGrammarRows(headword);
    final hasInflections = (headword.inflectionsHtml != null && headword.inflectionsHtml!.isNotEmpty) ||
        (headword.freqHtml != null && headword.freqHtml!.isNotEmpty);
    final familySections = buildFamilyRows(headword);
    final hasEx1 = headword.example1 != null && headword.example1!.isNotEmpty;
    final hasEx2 = headword.example2 != null && headword.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headword.lemma1,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (headword.pos != null)
                  Text(
                    posGrammarLine(headword),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EntrySummaryBox(headword: headword),

                // Grammar section
                if (grammarRows.isNotEmpty)
                  ExpansionTile(
                    title: const Text('Grammar'),
                    initiallyExpanded: settings.grammarOpen,
                    children: grammarRows
                        .map((r) => EntryLabelValue(label: r.$1, value: r.$2))
                        .toList(),
                  ),

                // Examples section
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
                                example: headword.example1!,
                                sutta: headword.sutta1,
                                source: headword.source1,
                              ),
                            if (hasEx1 && hasEx2) const SizedBox(height: 16),
                            if (hasEx2)
                              EntryExampleBlock(
                                example: headword.example2!,
                                sutta: headword.sutta2,
                                source: headword.source2,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // Inflections section
                if (hasInflections)
                  ExpansionTile(
                    title: const Text('Inflections'),
                    initiallyExpanded: false,
                    children: [
                      if (headword.inflectionsHtml != null && headword.inflectionsHtml!.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Html(data: headword.inflectionsHtml!),
                        ),
                      if (headword.freqHtml != null && headword.freqHtml!.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            'Frequency',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Html(data: headword.freqHtml!),
                        ),
                      ],
                    ],
                  ),

                // Families section
                if (familySections.isNotEmpty)
                  ExpansionTile(
                    title: const Text('Families'),
                    initiallyExpanded: false,
                    children: familySections
                        .map((s) => EntryLabelValue(label: s.$1, value: s.$2))
                        .toList(),
                  ),

                // Notes section
                if (headword.notes != null && headword.notes!.isNotEmpty)
                  ExpansionTile(
                    title: const Text('Notes'),
                    initiallyExpanded: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(headword.notes!),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
