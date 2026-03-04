import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/search_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/template_cache_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/text_filters.dart';
import 'entry_content.dart';
import 'family_state_mixin.dart';
import 'grammar_table.dart';
import 'inflection_section.dart';
import 'sutta_info_section.dart';
import '../providers/database_provider.dart';

enum _CardState { compact, buttonsVisible }

class AccordionCard extends ConsumerStatefulWidget {
  const AccordionCard({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<AccordionCard> createState() => _AccordionCardState();
}

class _AccordionCardState extends ConsumerState<AccordionCard>
    with FamilyStateMixin<AccordionCard> {
  _CardState _cardState = _CardState.compact;
  bool _grammarOpen = false;
  bool _suttaOpen = false;
  bool _examplesOpen = false;
  bool _inflectionsOpen = false;

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
        familyResetAll();
      });
    }
  }

  void _toggleCard() {
    setState(() {
      _cardState = _cardState == _CardState.compact
          ? _CardState.buttonsVisible
          : _CardState.compact;
    });
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
    final isExpanded = _cardState == _CardState.buttonsVisible;

    final templateCache = ref.watch(templateCacheProvider).valueOrNull ?? {};
    final hasInflections = hasInflectionContent(h);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;
    final hasTwoExamples = hasEx1 && hasEx2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleCard,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (Lemma) - above the box
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 1),
                child: Text(
                  n(h.lemma1),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Summary Box (Bordered)
              EntrySummaryBox(headword: h),

              // Expanded section: buttons + sections
              if (isExpanded) ...[
                // Unified button row
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 2, 7, 3),
                  child: Wrap(
                    spacing: 0,
                    runSpacing: 0,
                    children: [
                      if (_suttaLoaded && _suttaInfo != null)
                        DpdSectionButton(
                          label: 'sutta',
                          isActive: _suttaOpen,
                          onTap: () => _toggleSection(
                            isOpen: _suttaOpen,
                            setter: (v) => _suttaOpen = v,
                          ),
                        ),
                      DpdSectionButton(
                        label: 'grammar',
                        isActive: _grammarOpen,
                        onTap: () => _toggleSection(
                          isOpen: _grammarOpen,
                          setter: (v) => _grammarOpen = v,
                        ),
                      ),
                      if (hasExamples)
                        DpdSectionButton(
                          label: hasTwoExamples ? 'examples' : 'example',
                          isActive: _examplesOpen,
                          onTap: () => _toggleSection(
                            isOpen: _examplesOpen,
                            setter: (v) => _examplesOpen = v,
                          ),
                        ),
                      if (hasInflections)
                        DpdSectionButton(
                          label: inflectionButtonLabel(h.pos),
                          isActive: _inflectionsOpen,
                          onTap: () => _toggleSection(
                            isOpen: _inflectionsOpen,
                            setter: (v) => _inflectionsOpen = v,
                          ),
                        ),
                      ...buildFamilyButtons(),
                    ],
                  ),
                ),

                if (_suttaOpen && _suttaInfo != null)
                  SuttaInfoSection(
                    suttaInfo: _suttaInfo!,
                    headwordId: h.id,
                    lemma1: h.lemma1,
                  ),

                if (_grammarOpen)
                  DpdSectionContainer(
                    child: Padding(
                      padding: DpdColors.sectionPadding,
                      child: GrammarTable(headword: h),
                    ),
                  ),

                if (_examplesOpen && hasExamples)
                  DpdSectionContainer(
                    child: Padding(
                      padding: DpdColors.sectionPadding,
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
                  ),

                if (_inflectionsOpen && hasInflections)
                  DpdSectionContainer(
                    child: InflectionSection(
                      headword: h,
                      templateCache: templateCache,
                      lookupKey: ref.watch(searchQueryProvider),
                    ),
                  ),

                ...buildFamilySections(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
