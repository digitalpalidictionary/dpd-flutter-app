import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/settings_provider.dart';
import '../providers/template_cache_provider.dart';
import 'entry_content.dart';
import 'grammar_table.dart';
import 'inflection_section.dart';

enum _CardState { compact, buttonsVisible }

class AccordionCard extends ConsumerStatefulWidget {
  const AccordionCard({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<AccordionCard> createState() => _AccordionCardState();
}

class _AccordionCardState extends ConsumerState<AccordionCard> {
  _CardState _cardState = _CardState.compact;
  bool _grammarOpen = false;
  bool _examplesOpen = false;
  bool _inflectionsOpen = false;
  bool _familiesOpen = false;
  bool _notesOpen = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _grammarOpen = settings.grammarOpen;
    _examplesOpen = settings.examplesOpen;
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
    final theme = Theme.of(context);
    final h = widget.headword;
    final isExpanded = _cardState == _CardState.buttonsVisible;

    final familyRows = buildFamilyRows(h);
    final templateCache =
        ref.watch(templateCacheProvider).valueOrNull ?? {};
    final hasInflections = hasInflectionContent(h);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;
    final hasTwoExamples = hasEx1 && hasEx2;
    final hasNotes = h.notes != null && h.notes!.isNotEmpty;

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
                  h.lemma1,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Summary Box (Bordered)
              EntrySummaryBox(headword: h),

              // Expanded section: buttons + sections
              if (isExpanded) ...[
                // Button Box (Sibling)
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 2, 7, 3),
                  child: Wrap(
                    spacing: 0,
                    runSpacing: 0,
                    children: [
                      DpdSectionButton(
                        label: 'Grammar',
                        isActive: _grammarOpen,
                        onTap: () =>
                            setState(() => _grammarOpen = !_grammarOpen),
                      ),
                      if (hasExamples)
                        DpdSectionButton(
                          label: hasTwoExamples ? 'examples' : 'example',
                          isActive: _examplesOpen,
                          onTap: () =>
                              setState(() => _examplesOpen = !_examplesOpen),
                        ),
                      if (hasInflections)
                        DpdSectionButton(
                          label: inflectionButtonLabel(h.pos),
                          isActive: _inflectionsOpen,
                          onTap: () => setState(
                            () => _inflectionsOpen = !_inflectionsOpen,
                          ),
                        ),
                      if (familyRows.isNotEmpty)
                        DpdSectionButton(
                          label: 'Families',
                          isActive: _familiesOpen,
                          onTap: () =>
                              setState(() => _familiesOpen = !_familiesOpen),
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

                // Sections (Each in its own DpdSectionContainer)
                if (_grammarOpen)
                  DpdSectionContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GrammarTable(headword: h),
                    ),
                  ),

                if (hasExamples)
                  DpdSectionContainer(
                    child: Padding(
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
                  ),

                if (_inflectionsOpen && hasInflections)
                  DpdSectionContainer(
                    child: InflectionSection(
                      headword: h,
                      templateCache: templateCache,
                    ),
                  ),

                if (_familiesOpen && familyRows.isNotEmpty)
                  DpdSectionContainer(
                    child: Column(
                      children: familyRows
                          .map((r) => EntryLabelValue(label: r.$1, value: r.$2))
                          .toList(),
                    ),
                  ),

                if (_notesOpen && hasNotes)
                  DpdSectionContainer(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(h.notes!),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
