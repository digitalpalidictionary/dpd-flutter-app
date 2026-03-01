import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
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
import '../models/frequency_data.dart';

class InlineEntryCard extends ConsumerStatefulWidget {
  const InlineEntryCard({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<InlineEntryCard> createState() => _InlineEntryCardState();
}

class _InlineEntryCardState extends ConsumerState<InlineEntryCard>
    with FamilyStateMixin<InlineEntryCard> {
  bool _grammarOpen = false;
  bool _examplesOpen = false;
  bool _inflectionsOpen = false;
  bool _frequencyOpen = false;
  bool _notesOpen = false;
  bool _feedbackOpen = false;

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
    final hasFrequency = h.freqData != null && h.freqData!.isNotEmpty;
    final hasNotes = h.notes != null && h.notes!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Lemma) - above the box
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 1),
            child: Text(
              h.lemma1,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Summary Box (Bordered)
          EntrySummaryBox(headword: h),

          // Unified button row
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
                    label: 'Examples',
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
                DpdSectionButton(
                  label: 'Feedback',
                  isActive: _feedbackOpen,
                  onTap: () =>
                      setState(() => _feedbackOpen = !_feedbackOpen),
                ),
              ],
            ),
          ),

          // Grammar section content
          if (_grammarOpen)
            DpdSectionContainer(
              child: Padding(
                padding: DpdColors.sectionPadding,
                child: GrammarTable(headword: h),
              ),
            ),

          // Examples section content
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

          // Inflections section content
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

          // Notes section content
          if (_notesOpen && hasNotes)
            DpdSectionContainer(
              child: Padding(
                padding: DpdColors.sectionPadding,
                child: Text(h.notes!),
              ),
            ),

          if (_feedbackOpen)
            FeedbackSection(headwordId: h.id, lemma1: h.lemma1),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
