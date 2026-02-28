import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/family_data.dart';
import '../providers/database_provider.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/template_cache_provider.dart';
import '../widgets/entry_content.dart';
import '../widgets/family_section_builders.dart';
import '../widgets/family_table.dart';
import '../widgets/grammar_table.dart';
import '../widgets/inflection_section.dart';
import '../widgets/multi_family_section.dart';

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
  // Section visibility toggles
  bool _showRootFamily = false;
  bool _showWordFamily = false;
  bool _showCompoundFamilies = false;
  bool _showIdioms = false;
  bool _showSets = false;

  // Loaded data (null = not yet loaded)
  FamilyRootData? _rootFamilyData;
  FamilyWordData? _wordFamilyData;
  List<FamilyCompoundData>? _compoundData;
  List<FamilyIdiomData>? _idiomData;
  List<FamilySetData>? _setsData;

  DpdHeadwordWithRoot get h => widget.headword;

  // ── Family key lists (parsed from space-separated headword fields) ─────────

  List<String> get _compoundKeys =>
      (h.familyCompound ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  List<String> get _idiomKeys =>
      (h.familyIdioms ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  List<String> get _setKeys =>
      (h.familySet ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  // ── Button visibility ──────────────────────────────────────────────────────

  bool get _hasRootFamily =>
      h.familyRoot != null && h.familyRoot!.isNotEmpty && h.rootKey != null;

  bool get _hasWordFamily => h.familyWord != null && h.familyWord!.isNotEmpty;

  bool get _hasCompoundFamily => _compoundKeys.isNotEmpty;

  bool get _hasIdioms => _idiomKeys.isNotEmpty;

  bool get _hasSets => _setKeys.isNotEmpty;

  String get _compoundButtonLabel =>
      _compoundKeys.length > 1 ? 'compound families' : 'compound family';

  String get _setsButtonLabel => _setKeys.length > 1 ? 'sets' : 'set';

  // ── Lazy load helpers ──────────────────────────────────────────────────────

  Future<void> _loadRootFamily() async {
    if (_rootFamilyData != null) return;
    final dao = ref.read(daoProvider);
    final data = await dao.getRootFamily(h.rootKey!, h.familyRoot!);
    if (mounted) setState(() => _rootFamilyData = data);
  }

  Future<void> _loadWordFamily() async {
    if (_wordFamilyData != null) return;
    final dao = ref.read(daoProvider);
    final data = await dao.getWordFamily(h.familyWord!);
    if (mounted) setState(() => _wordFamilyData = data);
  }

  Future<void> _loadCompoundFamilies() async {
    if (_compoundData != null) return;
    final dao = ref.read(daoProvider);
    final data = await dao.getCompoundFamilies(_compoundKeys);
    if (mounted) setState(() => _compoundData = data);
  }

  Future<void> _loadIdioms() async {
    if (_idiomData != null) return;
    final dao = ref.read(daoProvider);
    final data = await dao.getIdioms(_idiomKeys);
    if (mounted) setState(() => _idiomData = data);
  }

  Future<void> _loadSets() async {
    if (_setsData != null) return;
    final dao = ref.read(daoProvider);
    final data = await dao.getSets(_setKeys);
    if (mounted) setState(() => _setsData = data);
  }

  // ── Toggle handlers ────────────────────────────────────────────────────────

  void _toggleRootFamily() {
    setState(() => _showRootFamily = !_showRootFamily);
    if (_showRootFamily) _loadRootFamily();
  }

  void _toggleWordFamily() {
    setState(() => _showWordFamily = !_showWordFamily);
    if (_showWordFamily) _loadWordFamily();
  }

  void _toggleCompoundFamilies() {
    setState(() => _showCompoundFamilies = !_showCompoundFamilies);
    if (_showCompoundFamilies) _loadCompoundFamilies();
  }

  void _toggleIdioms() {
    setState(() => _showIdioms = !_showIdioms);
    if (_showIdioms) _loadIdioms();
  }

  void _toggleSets() {
    setState(() => _showSets = !_showSets);
    if (_showSets) _loadSets();
  }

  // ── Section builders ───────────────────────────────────────────────────────

  Widget _buildRootFamilySection() {
    final data = _rootFamilyData;
    if (data == null) return const _LoadingSection();
    final entries = parseFamilyData(data.data);
    return FamilyTableWidget(
      header: buildRootFamilyHeader(data),
      entries: entries,
      footerConfig: buildRootFamilyFooter(h.id, h.lemma1),
    );
  }

  Widget _buildWordFamilySection() {
    final data = _wordFamilyData;
    if (data == null) return const _LoadingSection();
    final entries = parseFamilyData(data.data);
    return FamilyTableWidget(
      header: buildWordFamilyHeader(data),
      entries: entries,
      footerConfig: buildWordFamilyFooter(h.id, h.lemma1),
    );
  }

  Widget _buildCompoundFamiliesSection() {
    final data = _compoundData;
    if (data == null) return const _LoadingSection();
    if (data.isEmpty) return const SizedBox.shrink();

    final subSections = data.map((row) {
      return FamilySubSection(
        key: row.compoundFamily,
        header: buildCompoundFamilyHeader(row),
        entries: parseFamilyData(row.data),
        footerConfig: buildCompoundFamilyFooter(h.id, h.lemma1),
      );
    }).toList();

    return MultiFamilySection(subSections: subSections);
  }

  Widget _buildIdiomsSection() {
    final data = _idiomData;
    if (data == null) return const _LoadingSection();
    if (data.isEmpty) return const SizedBox.shrink();

    final subSections = data.map((row) {
      return FamilySubSection(
        key: row.idiom,
        header: buildIdiomHeader(row),
        entries: parseFamilyData(row.data),
        footerConfig: buildIdiomFooter(h.id, h.lemma1),
      );
    }).toList();

    return MultiFamilySection(subSections: subSections);
  }

  Widget _buildSetsSection() {
    final data = _setsData;
    if (data == null) return const _LoadingSection();
    if (data.isEmpty) return const SizedBox.shrink();

    final subSections = data.map((row) {
      return FamilySubSection(
        key: row.set_,
        header: buildSetHeader(row, h.lemma1),
        entries: parseFamilyData(row.data),
        footerConfig: buildSetFooter(h.id, h.lemma1),
      );
    }).toList();

    return MultiFamilySection(subSections: subSections);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final templateCache = ref.watch(templateCacheProvider).valueOrNull ?? {};

    final hasInflections = hasInflectionContent(h);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;

    final hasFamilyButtons =
        _hasRootFamily ||
        _hasWordFamily ||
        _hasCompoundFamily ||
        _hasIdioms ||
        _hasSets;

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

                // Family buttons
                if (hasFamilyButtons)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (_hasRootFamily)
                          DpdSectionButton(
                            label: 'root family',
                            isActive: _showRootFamily,
                            onTap: _toggleRootFamily,
                          ),
                        if (_hasWordFamily)
                          DpdSectionButton(
                            label: 'word family',
                            isActive: _showWordFamily,
                            onTap: _toggleWordFamily,
                          ),
                        if (_hasCompoundFamily)
                          DpdSectionButton(
                            label: _compoundButtonLabel,
                            isActive: _showCompoundFamilies,
                            onTap: _toggleCompoundFamilies,
                          ),
                        if (_hasIdioms)
                          DpdSectionButton(
                            label: 'idioms',
                            isActive: _showIdioms,
                            onTap: _toggleIdioms,
                          ),
                        if (_hasSets)
                          DpdSectionButton(
                            label: _setsButtonLabel,
                            isActive: _showSets,
                            onTap: _toggleSets,
                          ),
                      ],
                    ),
                  ),

                // Family sections (shown when active)
                if (_showRootFamily) _buildRootFamilySection(),
                if (_showWordFamily) _buildWordFamilySection(),
                if (_showCompoundFamilies) _buildCompoundFamiliesSection(),
                if (_showIdioms) _buildIdiomsSection(),
                if (_showSets) _buildSetsSection(),

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

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
