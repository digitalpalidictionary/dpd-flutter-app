import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../models/frequency_data.dart';
import '../providers/database_provider.dart';
import '../providers/internet_provider.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/template_cache_provider.dart';
import '../theme/dpd_colors.dart';
import 'entry_content.dart';
import 'family_state_mixin.dart';
import 'feedback_section.dart';
import 'frequency_section.dart';
import 'grammar_table.dart';
import 'inflection_section.dart';
import 'sutta_info_section.dart';

/// Manages section open/close state, sutta loading, and builds the shared
/// button row and section content for all three entry display contexts
/// (InlineEntryCard, AccordionCard, EntryScreen).
///
/// Must be used alongside [FamilyStateMixin] — family reset is coordinated
/// via [onBeforeOpenFamilySection].
mixin EntrySectionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, FamilyStateMixin<T> {
  DpdHeadwordWithRoot get sectionHeadword;

  final Set<String> openSections = {};
  SuttaInfoData? _suttaInfo;
  bool _suttaLoaded = false;
  FrequencyData? _cachedFrequencyData;

  bool isOpen(String id) => openSections.contains(id);
  SuttaInfoData? get suttaInfo => _suttaInfo;
  bool get suttaLoaded => _suttaLoaded;

  FrequencyData? get frequencyData =>
      _cachedFrequencyData ??= parseFrequencyData(sectionHeadword.freqData);

  void resetFrequencyCache() => _cachedFrequencyData = null;

  @override
  void onBeforeOpenFamilySection() {
    if (ref.read(settingsProvider).oneButtonAtATime) {
      setState(() {
        openSections.clear();
        familyResetAll();
      });
    }
  }

  void initSectionState() {
    final settings = ref.read(settingsProvider);
    if (settings.grammarOpen) openSections.add('grammar');
    if (settings.examplesOpen) openSections.add('examples');
    _loadSuttaInfo();
  }

  void handleSettingsChange(Settings? prev, Settings next) {
    var changed = false;
    if (prev?.grammarOpen != next.grammarOpen) {
      next.grammarOpen
          ? openSections.add('grammar')
          : openSections.remove('grammar');
      changed = true;
    }
    if (prev?.examplesOpen != next.examplesOpen) {
      next.examplesOpen
          ? openSections.add('examples')
          : openSections.remove('examples');
      changed = true;
    }
    if (changed) setState(() {});
  }

  void toggleSection(String id) {
    setState(() {
      if (!openSections.contains(id)) {
        if (ref.read(settingsProvider).oneButtonAtATime) {
          openSections.clear();
          familyResetAll();
        }
        openSections.add(id);
      } else {
        openSections.remove(id);
      }
    });
  }

  Future<void> _loadSuttaInfo() async {
    final info =
        await ref.read(daoProvider).getSuttaInfo(sectionHeadword.lemma1);
    if (mounted) {
      setState(() {
        _suttaInfo = info;
        _suttaLoaded = true;
      });
    }
  }

  /// Core section buttons: audio, sutta, grammar, examples, inflections,
  /// family buttons. All three contexts use these.
  List<Widget> buildCoreSectionButtons(DpdHeadwordWithRoot h) {
    final hasInternet = ref.watch(hasInternetProvider).valueOrNull ?? true;
    final audioGender = ref.watch(settingsProvider.select((s) => s.audioGender));
    return [
      if (hasInternet)
        DpdPlayButton(
          key: ValueKey(audioGender),
          lemma: h.lemma1,
          gender: audioGender.name,
        ),
      if (suttaLoaded && suttaInfo != null)
        DpdSectionButton(
          label: 'sutta',
          isActive: isOpen('sutta'),
          onTap: () => toggleSection('sutta'),
        ),
      if (h.needsGrammarButton)
        DpdSectionButton(
          label: 'grammar',
          isActive: isOpen('grammar'),
          onTap: () => toggleSection('grammar'),
        ),
      if (h.needsExampleButton || h.needsExamplesButton)
        DpdSectionButton(
          label: h.needsExamplesButton ? 'examples' : 'example',
          isActive: isOpen('examples'),
          onTap: () => toggleSection('examples'),
        ),
      if (h.needsInflectionButton)
        DpdSectionButton(
          label: h.inflectionButtonLabel,
          isActive: isOpen('inflections'),
          onTap: () => toggleSection('inflections'),
        ),
      ...buildFamilyButtons(),
    ];
  }

  /// Extra section buttons only shown in full (non-compact) mode:
  /// frequency and feedback.
  List<Widget> buildExtraSectionButtons(DpdHeadwordWithRoot h) {
    return [
      if (h.needsFrequencyButton)
        DpdSectionButton(
          label: 'frequency',
          isActive: isOpen('frequency'),
          onTap: () => toggleSection('frequency'),
        ),
      DpdSectionButton(
        label: 'feedback',
        isActive: isOpen('feedback'),
        onTap: () => toggleSection('feedback'),
      ),
    ];
  }

  /// Core section content: sutta, grammar, examples, inflections, families.
  List<Widget> buildCoreSections(DpdHeadwordWithRoot h) {
    final templateCache =
        ref.watch(templateCacheProvider).valueOrNull ?? {};
    final lookupKey = ref.watch(searchQueryProvider);
    return [
      if (isOpen('sutta') && suttaInfo != null)
        SuttaInfoSection(
          suttaInfo: suttaInfo!,
          headwordId: h.id,
          lemma1: h.lemma1,
        ),
      if (isOpen('grammar') && h.needsGrammarButton)
        DpdSectionContainer(
          child: Padding(
            padding: DpdColors.sectionPadding,
            child: GrammarTable(headword: h),
          ),
        ),
      if (isOpen('examples') && (h.needsExampleButton || h.needsExamplesButton))
        DpdSectionContainer(
          child: Padding(
            padding: DpdColors.sectionPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EntryExampleBlock(
                  example: h.example1!,
                  sutta: h.sutta1,
                  source: h.source1,
                ),
                if (h.needsExamplesButton)
                  EntryExampleBlock(
                    example: h.example2!,
                    sutta: h.sutta2,
                    source: h.source2,
                  ),
                EntryExampleFooter(headwordId: h.id, lemma1: h.lemma1),
              ],
            ),
          ),
        ),
      if (isOpen('inflections') && h.needsInflectionButton)
        DpdSectionContainer(
          child: InflectionSection(
            headword: h,
            templateCache: templateCache,
            lookupKey: lookupKey,
          ),
        ),
      ...buildFamilySections(),
    ];
  }

  /// Extra section content only shown in full (non-compact) mode:
  /// frequency and feedback.
  List<Widget> buildExtraSections(DpdHeadwordWithRoot h) {
    return [
      if (isOpen('frequency') && h.needsFrequencyButton)
        FrequencySection(
          data: frequencyData!,
          headwordId: h.id,
          lemma1: h.lemma1,
        ),
      if (isOpen('feedback')) FeedbackSection(headwordId: h.id, lemma1: h.lemma1),
    ];
  }
}
