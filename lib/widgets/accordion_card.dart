import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/settings_provider.dart';
import 'entry_content.dart';

enum _CardState { compact, buttonsVisible }

class AccordionCard extends ConsumerStatefulWidget {
  const AccordionCard({super.key, required this.headword});

  final DpdHeadword headword;

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

    final grammarRows = buildGrammarRows(h);
    final familyRows = buildFamilyRows(h);
    final hasInflections = (h.inflectionsHtml != null && h.inflectionsHtml!.isNotEmpty) ||
        (h.freqHtml != null && h.freqHtml!.isNotEmpty);
    final hasEx1 = h.example1 != null && h.example1!.isNotEmpty;
    final hasEx2 = h.example2 != null && h.example2!.isNotEmpty;
    final hasExamples = hasEx1 || hasEx2;
    final hasNotes = h.notes != null && h.notes!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleCard,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 3, 7, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        h.lemma1,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (h.pos != null && h.pos!.isNotEmpty)
                      Text(
                        h.pos!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Meaning (compact: truncated, expanded: full)
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 4, 7, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (h.meaning1 != null && h.meaning1!.isNotEmpty)
                      Text(
                        h.meaning1!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: isExpanded ? null : 2,
                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                    if (isExpanded) ...[
                      if (h.meaningLit != null && h.meaningLit!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'lit. ${h.meaningLit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (h.construction != null && h.construction!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          h.construction!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // Expanded section: divider + buttons
              if (isExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 0, 7, 3),
                  child: Wrap(
                    spacing: 4,
                    children: [
                      if (grammarRows.isNotEmpty)
                        _SectionButton(
                          label: 'Grammar',
                          isOpen: _grammarOpen,
                          onTap: () => setState(() => _grammarOpen = !_grammarOpen),
                        ),
                      if (hasExamples)
                        _SectionButton(
                          label: 'Examples',
                          isOpen: _examplesOpen,
                          onTap: () => setState(() => _examplesOpen = !_examplesOpen),
                        ),
                      if (hasInflections)
                        _SectionButton(
                          label: 'Inflections',
                          isOpen: _inflectionsOpen,
                          onTap: () => setState(() => _inflectionsOpen = !_inflectionsOpen),
                        ),
                      if (familyRows.isNotEmpty)
                        _SectionButton(
                          label: 'Families',
                          isOpen: _familiesOpen,
                          onTap: () => setState(() => _familiesOpen = !_familiesOpen),
                        ),
                      if (hasNotes)
                        _SectionButton(
                          label: 'Notes',
                          isOpen: _notesOpen,
                          onTap: () => setState(() => _notesOpen = !_notesOpen),
                        ),
                    ],
                  ),
                ),

                // Grammar section content
                if (_grammarOpen && grammarRows.isNotEmpty)
                  _SectionContent(
                    child: Column(
                      children: grammarRows
                          .map((r) => EntryLabelValue(label: r.$1, value: r.$2))
                          .toList(),
                    ),
                  ),

                // Examples section content
                if (_examplesOpen && hasExamples)
                  _SectionContent(
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

                // Inflections section content
                if (_inflectionsOpen && hasInflections)
                  _SectionContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (h.inflectionsHtml != null && h.inflectionsHtml!.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Html(data: h.inflectionsHtml!),
                          ),
                        if (h.freqHtml != null && h.freqHtml!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              'Frequency',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Html(data: h.freqHtml!),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Families section content
                if (_familiesOpen && familyRows.isNotEmpty)
                  _SectionContent(
                    child: Column(
                      children: familyRows
                          .map((r) => EntryLabelValue(label: r.$1, value: r.$2))
                          .toList(),
                    ),
                  ),

                // Notes section content
                if (_notesOpen && hasNotes)
                  _SectionContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(h.notes!),
                    ),
                  ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.label,
    required this.isOpen,
    required this.onTap,
  });

  final String label;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: isOpen
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
      child: Text(label),
    );
  }
}

class _SectionContent extends StatelessWidget {
  const _SectionContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }
}
