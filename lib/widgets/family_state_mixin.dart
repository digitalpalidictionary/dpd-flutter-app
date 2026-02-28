import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/family_data.dart';
import '../providers/database_provider.dart';
import 'entry_content.dart';
import 'family_section_builders.dart';
import 'family_table.dart';
import 'multi_family_section.dart';

mixin FamilyStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  DpdHeadwordWithRoot get familyHeadword;

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

  DpdHeadwordWithRoot get _fh => familyHeadword;

  List<String> get _compoundKeys =>
      (_fh.familyCompound ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  List<String> get _idiomKeys =>
      (_fh.familyIdioms ?? '').split(' ').where((s) => s.isNotEmpty).toList();

  List<String> get _setKeys =>
      (_fh.familySet ?? '').split('; ').where((s) => s.isNotEmpty).toList();

  bool get familyHasRoot =>
      _fh.familyRoot != null && _fh.familyRoot!.isNotEmpty && _fh.rootKey != null;

  bool get familyHasWord => _fh.familyWord != null && _fh.familyWord!.isNotEmpty;

  bool get familyHasCompound => _compoundKeys.isNotEmpty;

  bool get familyHasIdioms => _idiomKeys.isNotEmpty;

  bool get familyHasSets => _setKeys.isNotEmpty;

  bool get familyHasAny =>
      familyHasRoot ||
      familyHasWord ||
      familyHasCompound ||
      familyHasIdioms ||
      familyHasSets;

  String get _compoundButtonLabel =>
      _compoundKeys.length > 1 ? 'compound families' : 'compound family';

  String get _setsButtonLabel => _setKeys.length > 1 ? 'sets' : 'set';

  Future<void> _loadRootFamily() async {
    if (_rootFamilyData != null) return;
    final data = await ref.read(daoProvider).getRootFamily(
      _fh.rootKey!,
      _fh.familyRoot!,
    );
    if (mounted) setState(() => _rootFamilyData = data);
  }

  Future<void> _loadWordFamily() async {
    if (_wordFamilyData != null) return;
    final data = await ref.read(daoProvider).getWordFamily(_fh.familyWord!);
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

  void familyToggleRoot() {
    setState(() => _showRootFamily = !_showRootFamily);
    if (_showRootFamily) _loadRootFamily();
  }

  void familyToggleWord() {
    setState(() => _showWordFamily = !_showWordFamily);
    if (_showWordFamily) _loadWordFamily();
  }

  void familyToggleCompound() {
    setState(() => _showCompoundFamilies = !_showCompoundFamilies);
    if (_showCompoundFamilies) _loadCompoundFamilies();
  }

  void familyToggleIdioms() {
    setState(() => _showIdioms = !_showIdioms);
    if (_showIdioms) _loadIdioms();
  }

  void familyToggleSets() {
    setState(() => _showSets = !_showSets);
    if (_showSets) _loadSets();
  }

  List<Widget> buildFamilyButtons() {
    return [
      if (familyHasRoot)
        DpdSectionButton(
          label: 'root family',
          isActive: _showRootFamily,
          onTap: familyToggleRoot,
        ),
      if (familyHasWord)
        DpdSectionButton(
          label: 'word family',
          isActive: _showWordFamily,
          onTap: familyToggleWord,
        ),
      if (familyHasCompound)
        DpdSectionButton(
          label: _compoundButtonLabel,
          isActive: _showCompoundFamilies,
          onTap: familyToggleCompound,
        ),
      if (familyHasIdioms)
        DpdSectionButton(
          label: 'idioms',
          isActive: _showIdioms,
          onTap: familyToggleIdioms,
        ),
      if (familyHasSets)
        DpdSectionButton(
          label: _setsButtonLabel,
          isActive: _showSets,
          onTap: familyToggleSets,
        ),
    ];
  }

  List<Widget> buildFamilySections() {
    return [
      if (_showRootFamily) _buildRootSection(),
      if (_showWordFamily) _buildWordSection(),
      if (_showCompoundFamilies) _buildCompoundSection(),
      if (_showIdioms) _buildIdiomsSection(),
      if (_showSets) _buildSetsSection(),
    ];
  }

  Widget _buildRootSection() {
    final data = _rootFamilyData;
    if (data == null) return const FamilyLoadingSpinner();
    return FamilyTableWidget(
      header: buildRootFamilyHeader(data),
      entries: parseFamilyData(data.data),
      footerConfig: buildRootFamilyFooter(_fh.id, _fh.lemma1),
    );
  }

  Widget _buildWordSection() {
    final data = _wordFamilyData;
    if (data == null) return const FamilyLoadingSpinner();
    return FamilyTableWidget(
      header: buildWordFamilyHeader(data),
      entries: parseFamilyData(data.data),
      footerConfig: buildWordFamilyFooter(_fh.id, _fh.lemma1),
    );
  }

  Widget _buildCompoundSection() {
    final data = _compoundData;
    if (data == null) return const FamilyLoadingSpinner();
    if (data.isEmpty) return const SizedBox.shrink();
    return MultiFamilySection(
      subSections: data
          .map(
            (row) => FamilySubSection(
              key: row.compoundFamily,
              header: buildCompoundFamilyHeader(row),
              entries: parseFamilyData(row.data),
              footerConfig: buildCompoundFamilyFooter(_fh.id, _fh.lemma1),
            ),
          )
          .toList(),
    );
  }

  Widget _buildIdiomsSection() {
    final data = _idiomData;
    if (data == null) return const FamilyLoadingSpinner();
    if (data.isEmpty) return const SizedBox.shrink();
    return MultiFamilySection(
      subSections: data
          .map(
            (row) => FamilySubSection(
              key: row.idiom,
              header: buildIdiomHeader(row),
              entries: parseFamilyData(row.data),
              footerConfig: buildIdiomFooter(_fh.id, _fh.lemma1),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSetsSection() {
    final data = _setsData;
    if (data == null) return const FamilyLoadingSpinner();
    if (data.isEmpty) return const SizedBox.shrink();
    return MultiFamilySection(
      subSections: data
          .map(
            (row) => FamilySubSection(
              key: row.set_,
              header: buildSetHeader(row, _fh.lemma1),
              entries: parseFamilyData(row.data),
              footerConfig: buildSetFooter(_fh.id, _fh.lemma1),
            ),
          )
          .toList(),
    );
  }
}

class FamilyLoadingSpinner extends StatelessWidget {
  const FamilyLoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
