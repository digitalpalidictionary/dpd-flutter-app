import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/family_data.dart';
import '../providers/database_provider.dart';
import 'entry_content.dart';
import 'family_section_builders.dart';
import 'family_table.dart';
import 'multi_family_section.dart';

/// Renders all family toggle buttons and their lazy-loaded sections.
///
/// Drop this widget anywhere a headword's family sections should appear.
/// It manages all toggle state and lazy loading internally.
class FamilyToggleSection extends ConsumerStatefulWidget {
  const FamilyToggleSection({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<FamilyToggleSection> createState() =>
      _FamilyToggleSectionState();
}

class _FamilyToggleSectionState extends ConsumerState<FamilyToggleSection> {
  bool _showRootFamily = false;
  bool _showWordFamily = false;
  bool _showCompoundFamilies = false;
  bool _showIdioms = false;
  bool _showSets = false;

  FamilyRootData? _rootFamilyData;
  FamilyWordData? _wordFamilyData;
  List<FamilyCompoundData>? _compoundData;
  List<FamilyIdiomData>? _idiomData;
  List<FamilySetData>? _setsData;

  DpdHeadwordWithRoot get h => widget.headword;

  List<String> get _compoundKeys =>
      (h.familyCompound ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  List<String> get _idiomKeys =>
      (h.familyIdioms ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  List<String> get _setKeys =>
      (h.familySet ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  bool get _hasRootFamily =>
      h.familyRoot != null && h.familyRoot!.isNotEmpty && h.rootKey != null;

  bool get _hasWordFamily => h.familyWord != null && h.familyWord!.isNotEmpty;

  bool get _hasCompoundFamily => _compoundKeys.isNotEmpty;

  bool get _hasIdioms => _idiomKeys.isNotEmpty;

  bool get _hasSets => _setKeys.isNotEmpty;

  bool get hasAnyFamily =>
      _hasRootFamily ||
      _hasWordFamily ||
      _hasCompoundFamily ||
      _hasIdioms ||
      _hasSets;

  String get _compoundButtonLabel =>
      _compoundKeys.length > 1 ? 'compound families' : 'compound family';

  String get _setsButtonLabel => _setKeys.length > 1 ? 'sets' : 'set';

  Future<void> _loadRootFamily() async {
    if (_rootFamilyData != null) return;
    final data = await ref.read(daoProvider).getRootFamily(
      h.rootKey!,
      h.familyRoot!,
    );
    if (mounted) setState(() => _rootFamilyData = data);
  }

  Future<void> _loadWordFamily() async {
    if (_wordFamilyData != null) return;
    final data = await ref.read(daoProvider).getWordFamily(h.familyWord!);
    if (mounted) setState(() => _wordFamilyData = data);
  }

  Future<void> _loadCompoundFamilies() async {
    if (_compoundData != null) return;
    final data = await ref.read(daoProvider).getCompoundFamilies(_compoundKeys);
    if (mounted) setState(() => _compoundData = data);
  }

  Future<void> _loadIdioms() async {
    if (_idiomData != null) return;
    final data = await ref.read(daoProvider).getIdioms(_idiomKeys);
    if (mounted) setState(() => _idiomData = data);
  }

  Future<void> _loadSets() async {
    if (_setsData != null) return;
    final data = await ref.read(daoProvider).getSets(_setKeys);
    if (mounted) setState(() => _setsData = data);
  }

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

  Widget _buildRootFamilySection() {
    final data = _rootFamilyData;
    if (data == null) return const _LoadingSection();
    return FamilyTableWidget(
      header: buildRootFamilyHeader(data),
      entries: parseFamilyData(data.data),
      footerConfig: buildRootFamilyFooter(h.id, h.lemma1),
    );
  }

  Widget _buildWordFamilySection() {
    final data = _wordFamilyData;
    if (data == null) return const _LoadingSection();
    return FamilyTableWidget(
      header: buildWordFamilyHeader(data),
      entries: parseFamilyData(data.data),
      footerConfig: buildWordFamilyFooter(h.id, h.lemma1),
    );
  }

  Widget _buildCompoundFamiliesSection() {
    final data = _compoundData;
    if (data == null) return const _LoadingSection();
    if (data.isEmpty) return const SizedBox.shrink();
    return MultiFamilySection(
      subSections: data.map((row) => FamilySubSection(
        key: row.compoundFamily,
        header: buildCompoundFamilyHeader(row),
        entries: parseFamilyData(row.data),
        footerConfig: buildCompoundFamilyFooter(h.id, h.lemma1),
      )).toList(),
    );
  }

  Widget _buildIdiomsSection() {
    final data = _idiomData;
    if (data == null) return const _LoadingSection();
    if (data.isEmpty) return const SizedBox.shrink();
    return MultiFamilySection(
      subSections: data.map((row) => FamilySubSection(
        key: row.idiom,
        header: buildIdiomHeader(row),
        entries: parseFamilyData(row.data),
        footerConfig: buildIdiomFooter(h.id, h.lemma1),
      )).toList(),
    );
  }

  Widget _buildSetsSection() {
    final data = _setsData;
    if (data == null) return const _LoadingSection();
    if (data.isEmpty) return const SizedBox.shrink();
    return MultiFamilySection(
      subSections: data.map((row) => FamilySubSection(
        key: row.set_,
        header: buildSetHeader(row, h.lemma1),
        entries: parseFamilyData(row.data),
        footerConfig: buildSetFooter(h.id, h.lemma1),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hasAnyFamily) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Family buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 2, 7, 3),
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
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

        // Sections
        if (_showRootFamily) _buildRootFamilySection(),
        if (_showWordFamily) _buildWordFamilySection(),
        if (_showCompoundFamilies) _buildCompoundFamiliesSection(),
        if (_showIdioms) _buildIdiomsSection(),
        if (_showSets) _buildSetsSection(),
      ],
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
