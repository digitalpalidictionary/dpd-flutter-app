import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import 'entry_content.dart';
import 'family_state_mixin.dart';
import 'frequency_section.dart';
import 'grammar_table.dart';
import 'inflection_section.dart';
import '../models/frequency_data.dart';
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
  bool _examplesOpen = false;
  bool _inflectionsOpen = false;
  bool _frequencyOpen = false;
  bool _notesOpen = false;

  @override
  DpdHeadwordWithRoot get familyHeadword => widget.headword;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _grammarOpen = settings.grammarOpen;
    _examplesOpen = settings.examplesOpen;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = widget.headword;

    final templateCache =
        ref.watch(templateCacheProvider).valueOrNull ?? {};
    final hasInflections = hasInflectionContent(h);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;
    final hasTwoExamples = hasEx1 && hasEx2;
    final hasFrequency = h.freqData != null && h.freqData!.isNotEmpty;
    final hasNotes = h.notes != null && h.notes!.isNotEmpty;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DpdColors.borderRadiusValue),
      ),
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
              h.lemma1,
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
                DpdSectionButton(
                  label: 'Grammar',
                  isActive: _grammarOpen,
                  onTap: () => setState(() => _grammarOpen = !_grammarOpen),
                ),
                if (hasExamples)
                  DpdSectionButton(
                    label: hasTwoExamples ? 'Examples' : 'Example',
                    isActive: _examplesOpen,
                    onTap: () =>
                        setState(() => _examplesOpen = !_examplesOpen),
                  ),
                if (hasInflections)
                  DpdSectionButton(
                    label: inflectionButtonLabel(h.pos),
                    isActive: _inflectionsOpen,
                    onTap: () =>
                        setState(() => _inflectionsOpen = !_inflectionsOpen),
                  ),
                ...buildFamilyButtons(),
                if (hasFrequency)
                  DpdSectionButton(
                    label: 'Frequency',
                    isActive: _frequencyOpen,
                    onTap: () =>
                        setState(() => _frequencyOpen = !_frequencyOpen),
                  ),
                if (hasNotes)
                  DpdSectionButton(
                    label: 'Notes',
                    isActive: _notesOpen,
                    onTap: () => setState(() => _notesOpen = !_notesOpen),
                  ),
              ],
            ),
          ),

          // Sections
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
                    EntryExampleFooter(headwordId: h.id, lemma1: h.lemma1),
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

          if (_frequencyOpen && hasFrequency)
            FrequencySection(
              data: parseFrequencyData(h.freqData)!,
              headwordId: h.id,
              lemma1: h.lemma1,
            ),

          if (_notesOpen && hasNotes)
            DpdSectionContainer(
              child: Padding(
                padding: DpdColors.sectionPadding,
                child: Text(h.notes!),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
