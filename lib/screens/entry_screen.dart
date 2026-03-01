import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/database_provider.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/template_cache_provider.dart';
import '../widgets/entry_content.dart';
import '../widgets/family_toggle_section.dart';
import '../widgets/grammar_table.dart';
import '../widgets/inflection_section.dart';
import '../widgets/sutta_info_section.dart';

final _entryProvider = FutureProvider.autoDispose
    .family<DpdHeadwordWithRoot?, int>((ref, id) {
      return ref.watch(daoProvider).getById(id);
    });

class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key, required this.headwordId});

  final int headwordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(_entryProvider(headwordId));

    return entry.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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

class _EntryView extends ConsumerStatefulWidget {
  const _EntryView({required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<_EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends ConsumerState<_EntryView> {
  bool _suttaOpen = false;
  SuttaInfoData? _suttaInfo;
  bool _suttaLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSuttaInfo();
  }

  Future<void> _loadSuttaInfo() async {
    final info =
        await ref.read(daoProvider).getSuttaInfo(widget.headword.lemma1);
    if (mounted) setState(() { _suttaInfo = info; _suttaLoaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final templateCache = ref.watch(templateCacheProvider).valueOrNull ?? {};

    final h = widget.headword;
    final hasInflections = hasInflectionContent(h);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EntrySummaryBox(headword: h),

                // Sutta info section
                if (_suttaLoaded && _suttaInfo != null)
                  ExpansionTile(
                    title: const Text('Sutta'),
                    initiallyExpanded: _suttaOpen,
                    onExpansionChanged: (v) =>
                        setState(() => _suttaOpen = v),
                    children: [
                      SuttaInfoSection(
                        suttaInfo: _suttaInfo!,
                        headwordId: h.id,
                        lemma1: h.lemma1,
                      ),
                    ],
                  ),

                // Grammar section
                ExpansionTile(
                  title: const Text('Grammar'),
                  initiallyExpanded: settings.grammarOpen,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GrammarTable(headword: h),
                    ),
                  ],
                ),

                // Examples section
                if (hasExamples)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasEx1)
                          EntryExampleBlock(
                            example: h.example1!,
                            sutta: h.sutta1,
                            source: h.source1,
                          ),
                        if (hasEx2)
                          EntryExampleBlock(
                            example: h.example2!,
                            sutta: h.sutta2,
                            source: h.source2,
                          ),
                        EntryExampleFooter(
                          headwordId: h.id,
                          lemma1: h.lemma1,
                        ),
                      ],
                    ),
                  ),

                // Inflections section
                if (hasInflections)
                  ExpansionTile(
                    title: Text(inflectionButtonLabel(h.pos)),
                    initiallyExpanded: false,
                    children: [
                      InflectionSection(
                        headword: h,
                        templateCache: templateCache,
                        lookupKey: ref.watch(searchQueryProvider),
                      ),
                    ],
                  ),

                // Family buttons and sections (one button per family type)
                FamilyToggleSection(headword: h),

                // Notes section
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
