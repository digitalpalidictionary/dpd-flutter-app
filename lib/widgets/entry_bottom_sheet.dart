import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/text_filters.dart';
import 'double_tap_search_wrapper.dart';
import 'entry_content.dart';
import 'family_state_mixin.dart';
import 'feedback_section.dart';
import 'frequency_section.dart';
import 'grammar_table.dart';
import 'inflection_section.dart';
import 'sutta_info_section.dart';
import '../models/frequency_data.dart';
import '../providers/database_provider.dart';
import '../providers/internet_provider.dart';
import '../providers/search_provider.dart';
import '../providers/template_cache_provider.dart';

class EntryBottomSheet extends ConsumerStatefulWidget {
  const EntryBottomSheet({
    super.key,
    required this.headword,
    required this.scrollController,
  });

  final DpdHeadwordWithRoot headword;
  final ScrollController scrollController;

  @override
  ConsumerState<EntryBottomSheet> createState() => _EntryBottomSheetState();
}

class _EntryBottomSheetState extends ConsumerState<EntryBottomSheet>
    with FamilyStateMixin<EntryBottomSheet> {
  bool _grammarOpen = false;
  bool _suttaOpen = false;
  bool _examplesOpen = false;
  bool _inflectionsOpen = false;
  bool _frequencyOpen = false;
  bool _feedbackOpen = false;

  SuttaInfoData? _suttaInfo;
  bool _suttaLoaded = false;

  @override
  DpdHeadwordWithRoot get familyHeadword => widget.headword;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _grammarOpen = settings.grammarOpen;
    _examplesOpen = settings.examplesOpen;
    _loadSuttaInfo();
  }

  Future<void> _loadSuttaInfo() async {
    final info = await ref
        .read(daoProvider)
        .getSuttaInfo(widget.headword.lemma1);
    if (mounted) {
      setState(() {
        _suttaInfo = info;
        _suttaLoaded = true;
      });
    }
  }

  void _toggleSection({required bool isOpen, required void Function(bool) setter}) {
    setState(() {
      if (!isOpen && ref.read(settingsProvider).oneButtonAtATime) {
        _suttaOpen = false;
        _grammarOpen = false;
        _examplesOpen = false;
        _inflectionsOpen = false;
        _frequencyOpen = false;
        _feedbackOpen = false;
        familyResetAll();
      }
      setter(!isOpen);
    });
  }

  @override
  void onBeforeOpenFamilySection() {
    if (ref.read(settingsProvider).oneButtonAtATime) {
      setState(() {
        _suttaOpen = false;
        _grammarOpen = false;
        _examplesOpen = false;
        _inflectionsOpen = false;
        _frequencyOpen = false;
        _feedbackOpen = false;
        familyResetAll();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Settings>(settingsProvider, (prev, next) {
      if (prev?.grammarOpen != next.grammarOpen) {
        setState(() => _grammarOpen = next.grammarOpen);
      }
      if (prev?.examplesOpen != next.examplesOpen) {
        setState(() => _examplesOpen = next.examplesOpen);
      }
    });

    final niggahitaMode = ref.watch(settingsProvider.select((s) => s.niggahitaMode));
    final filterMode = NiggahitaFilterMode.values[niggahitaMode.index];
    String n(String t) => filterNiggahita(t, mode: filterMode);
    final theme = Theme.of(context);
    final h = widget.headword;

    final templateCache = ref.watch(templateCacheProvider).valueOrNull ?? {};

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DpdColors.borderRadiusValue),
      ),
      child: DoubleTapSearchWrapper(
        shouldPop: true,
        child: ListView(
          controller: widget.scrollController,
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

            // Pinned header (Lemma)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                n(h.lemma1),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Summary box
            EntrySummaryBox(headword: h),

            // Unified button row (Grammar + Examples + Inflections + Family + Notes)
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 3),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: [
                  if (ref.watch(hasInternetProvider).valueOrNull ?? true)
                    DpdPlayButton(
                      key: ValueKey(ref.watch(settingsProvider.select((s) => s.audioGender))),
                      lemma: h.lemma1,
                      gender: ref.watch(settingsProvider.select((s) => s.audioGender)).name,
                    ),
                  if (_suttaLoaded && _suttaInfo != null)
                    DpdSectionButton(
                      label: 'sutta',
                      isActive: _suttaOpen,
                      onTap: () => _toggleSection(
                        isOpen: _suttaOpen,
                        setter: (v) => _suttaOpen = v,
                      ),
                    ),
                  if (h.needsGrammarButton)
                    DpdSectionButton(
                      label: 'grammar',
                      isActive: _grammarOpen,
                      onTap: () => _toggleSection(
                        isOpen: _grammarOpen,
                        setter: (v) => _grammarOpen = v,
                      ),
                    ),
                  if (h.needsExampleButton || h.needsExamplesButton)
                    DpdSectionButton(
                      label: h.needsExamplesButton ? 'examples' : 'example',
                      isActive: _examplesOpen,
                      onTap: () => _toggleSection(
                        isOpen: _examplesOpen,
                        setter: (v) => _examplesOpen = v,
                      ),
                    ),
                  if (h.needsInflectionButton)
                    DpdSectionButton(
                      label: h.inflectionButtonLabel,
                      isActive: _inflectionsOpen,
                      onTap: () => _toggleSection(
                        isOpen: _inflectionsOpen,
                        setter: (v) => _inflectionsOpen = v,
                      ),
                    ),
                  ...buildFamilyButtons(),
                  if (h.needsFrequencyButton)
                    DpdSectionButton(
                      label: 'frequency',
                      isActive: _frequencyOpen,
                      onTap: () => _toggleSection(
                        isOpen: _frequencyOpen,
                        setter: (v) => _frequencyOpen = v,
                      ),
                    ),
                  DpdSectionButton(
                    label: 'feedback',
                    isActive: _feedbackOpen,
                    onTap: () => _toggleSection(
                      isOpen: _feedbackOpen,
                      setter: (v) => _feedbackOpen = v,
                    ),
                  ),
                ],
              ),
            ),

            // Sections
            if (_suttaOpen && _suttaInfo != null)
              SuttaInfoSection(
                suttaInfo: _suttaInfo!,
                headwordId: h.id,
                lemma1: h.lemma1,
              ),

            if (_grammarOpen && h.needsGrammarButton)
              DpdSectionContainer(
                child: Padding(
                  padding: DpdColors.sectionPadding,
                  child: GrammarTable(headword: h),
                ),
              ),

            if (_examplesOpen && (h.needsExampleButton || h.needsExamplesButton))
              DpdSectionContainer(
                child: Padding(
                  padding: DpdColors.sectionPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (h.needsExampleButton || h.needsExamplesButton)
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

            if (_inflectionsOpen && h.needsInflectionButton)
              DpdSectionContainer(
                child: InflectionSection(
                  headword: h,
                  templateCache: templateCache,
                  lookupKey: ref.watch(searchQueryProvider),
                ),
              ),

            ...buildFamilySections(),

            if (_frequencyOpen && h.needsFrequencyButton)
              FrequencySection(
                data: parseFrequencyData(h.freqData)!,
                headwordId: h.id,
                lemma1: h.lemma1,
              ),

            if (_feedbackOpen)
              FeedbackSection(headwordId: h.id, lemma1: h.lemma1),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
