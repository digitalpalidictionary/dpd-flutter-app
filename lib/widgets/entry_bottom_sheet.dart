import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import 'dpd_html_table.dart';
import 'entry_content.dart';
import 'grammar_table.dart';

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

class _EntryBottomSheetState extends ConsumerState<EntryBottomSheet> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = widget.headword;

    final familyRows = buildFamilyRows(h);
    final hasInflections =
        (h.inflectionsHtml != null && h.inflectionsHtml!.isNotEmpty) ||
        (h.freqHtml != null && h.freqHtml!.isNotEmpty);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;
    final hasTwoExamples = hasEx1 && hasEx2;
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
                  onTap: () => setState(() => _grammarOpen = !_grammarOpen),
                ),
                if (hasExamples)
                  DpdSectionButton(
                    label: hasTwoExamples ? 'examples' : 'example',
                    isActive: _examplesOpen,
                    onTap: () => setState(() => _examplesOpen = !_examplesOpen),
                  ),
                if (hasInflections)
                  DpdSectionButton(
                    label: 'Inflections',
                    isActive: _inflectionsOpen,
                    onTap: () =>
                        setState(() => _inflectionsOpen = !_inflectionsOpen),
                  ),
                if (familyRows.isNotEmpty)
                  DpdSectionButton(
                    label: 'Families',
                    isActive: _familiesOpen,
                    onTap: () => setState(() => _familiesOpen = !_familiesOpen),
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
                padding: const EdgeInsets.all(16.0),
                child: GrammarTable(headword: h),
              ),
            ),

          if (_examplesOpen && hasExamples)
            DpdSectionContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasEx1)
                      EntryExampleBlock(
                        example: h.example1!,
                        sutta: h.sutta1,
                        source: h.source1,
                      ),
                    if (hasEx1 && hasEx2) const SizedBox(height: 16),
                    if (hasEx2)
                      EntryExampleBlock(
                        example: h.example2!,
                        sutta: h.sutta2,
                        source: h.source2,
                      ),
                  ],
                ),
              ),
            ),

          if (_inflectionsOpen && hasInflections)
            DpdSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (h.inflectionsHtml != null &&
                      h.inflectionsHtml!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DpdHtmlTable(data: h.inflectionsHtml!),
                    ),
                  if (h.freqHtml != null && h.freqHtml!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        'Frequency',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: DpdHtmlTable(data: h.freqHtml!),
                    ),
                  ],
                ],
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

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
