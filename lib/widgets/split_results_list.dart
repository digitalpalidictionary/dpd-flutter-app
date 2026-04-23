import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../database/database.dart';
import '../models/lookup_results.dart';
import '../models/summary_entry.dart';
import '../providers/dict_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/accordion_card.dart';
import '../widgets/dict_html_card.dart';
import '../widgets/inline_entry_card.dart';
import '../widgets/inline_root_card.dart';
import '../widgets/secondary/secondary_result_cards.dart';
import '../widgets/summary_section.dart';

class SplitResultsList extends StatefulWidget {
  const SplitResultsList({
    super.key,
    required this.exact,
    required this.partial,
    required this.partialLoading,
    required this.roots,
    required this.secondary,
    required this.dictExact,
    required this.dictPartial,
    required this.dictFuzzy,
    required this.summaryEntries,
    required this.showSummary,
    required this.mode,
    required this.visibility,
    this.fuzzy = const [],
  });

  final List<DpdHeadwordWithRoot> exact;
  final List<DpdHeadwordWithRoot> partial;
  final bool partialLoading;
  final List<RootWithFamilies> roots;
  final List<Object> secondary;
  final List<DictResult> dictExact;
  final List<DictResult> dictPartial;
  final List<DictResult> dictFuzzy;
  final List<SummaryEntry> summaryEntries;
  final bool showSummary;
  final DisplayMode mode;
  final DictVisibility visibility;
  final List<DpdHeadwordWithRoot> fuzzy;

  @override
  State<SplitResultsList> createState() => _SplitResultsListState();
}

class _SplitResultsListState extends State<SplitResultsList> {
  final Map<String, int> _itemIndex = {};
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  void _scrollToEntry(String targetId) {
    final target = _itemIndex[targetId];
    if (target == null || !_itemScrollController.isAttached) return;

    final positions = _itemPositionsListener.itemPositions.value;
    final firstVisible = positions.isEmpty
        ? 0
        : positions.map((p) => p.index).reduce((a, b) => a < b ? a : b);

    const nearbyWindow = 6;
    if ((target - firstVisible).abs() <= nearbyWindow) {
      _itemScrollController.scrollTo(
        index: target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
      return;
    }

    _itemScrollController.jumpTo(index: target, alignment: 0.1);
  }

  Object? _secondaryForSource(String sourceId) => switch (sourceId) {
    'dpd_abbreviations' =>
      widget.secondary.whereType<AbbreviationResult>().firstOrNull,
    'dpd_abbreviations_other' =>
      widget.secondary.whereType<AbbreviationOtherResult>().firstOrNull,
    'dpd_deconstructor' =>
      widget.secondary.whereType<DeconstructorResult>().firstOrNull,
    'dpd_grammar' =>
      widget.secondary.whereType<GrammarDictResult>().firstOrNull,
    'dpd_help' => widget.secondary.whereType<HelpResult>().firstOrNull,
    'dpd_epd' => widget.secondary.whereType<EpdResult>().firstOrNull,
    'dpd_variants' => widget.secondary.whereType<VariantResult>().firstOrNull,
    'dpd_spelling' => widget.secondary.whereType<SpellingResult>().firstOrNull,
    'dpd_see' => widget.secondary.whereType<SeeResult>().firstOrNull,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.visibility.enabled;
    final order = widget.visibility.order;

    final tier1 = <Widget>[];
    final tier2 = <Widget>[];
    final tier3 = <Widget>[];
    _itemIndex.clear();

    // All scroll-to targets live in tier1, which occupies the first
    // contiguous block of allItems. So tier1 local index == final index.
    void addTier1(Widget w, [String? id]) {
      if (id != null && id.isNotEmpty) _itemIndex[id] = tier1.length;
      tier1.add(w);
    }

    for (final sourceId in order) {
      if (!enabled.contains(sourceId)) continue;

      switch (sourceId) {
        case 'dpd_summary':
          if (widget.showSummary && widget.summaryEntries.isNotEmpty) {
            addTier1(
              SummarySection(
                entries: widget.summaryEntries,
                onTap: _scrollToEntry,
              ),
            );
          }
        case 'dpd_headwords':
          for (final hw in widget.exact) {
            addTier1(_buildItem(context, hw), 'hw_${hw.headword.id}');
          }
          for (final hw in widget.partial) {
            tier2.add(_buildItem(context, hw));
          }
          for (final hw in widget.fuzzy) {
            tier3.add(_buildItem(context, hw));
          }
        case 'dpd_roots':
          for (final rwf in widget.roots) {
            addTier1(_buildRootItem(context, rwf), 'root_${rwf.root.root}');
          }
        case 'dpd_abbreviations':
        case 'dpd_abbreviations_other':
        case 'dpd_deconstructor':
        case 'dpd_grammar':
        case 'dpd_help':
        case 'dpd_epd':
        case 'dpd_variants':
        case 'dpd_spelling':
        case 'dpd_see':
          final result = _secondaryForSource(sourceId);
          if (result != null) {
            addTier1(
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: _buildSecondaryItem(result),
              ),
              _secondaryTargetId(result),
            );
          }
        default:
          final exactResult = widget.dictExact
              .where((dr) => dr.dictId == sourceId)
              .firstOrNull;
          if (exactResult != null) {
            tier1.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: DictHtmlCard(
                  dictId: exactResult.dictId,
                  dictName: exactResult.dictName,
                  entries: exactResult.entries,
                ),
              ),
            );
          }
          final partialResult = widget.dictPartial
              .where((dr) => dr.dictId == sourceId)
              .firstOrNull;
          if (partialResult != null) {
            tier2.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: DictHtmlCard(
                  dictId: partialResult.dictId,
                  dictName: partialResult.dictName,
                  entries: partialResult.entries,
                ),
              ),
            );
          }
          final fuzzyResult = widget.dictFuzzy
              .where((dr) => dr.dictId == sourceId)
              .firstOrNull;
          if (fuzzyResult != null) {
            tier3.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: DictHtmlCard(
                  dictId: fuzzyResult.dictId,
                  dictName: fuzzyResult.dictName,
                  entries: fuzzyResult.entries,
                ),
              ),
            );
          }
      }
    }

    final showPartialDivider = tier2.isNotEmpty;
    final showFuzzyDivider = tier3.isNotEmpty;

    final allItems = [
      ...tier1,
      if (showPartialDivider)
        TierDivider(
          label: 'Partial Results',
          isCompact: widget.mode == DisplayMode.compact,
        ),
      ...tier2,
      if (showPartialDivider && widget.partialLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      if (showFuzzyDivider)
        TierDivider(
          label: 'Fuzzy Results',
          isCompact: widget.mode == DisplayMode.compact,
        ),
      ...tier3,
    ];

    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemCount: allItems.length,
      itemBuilder: (context, index) => allItems[index],
    );
  }

  String _secondaryTargetId(Object result) => switch (result) {
    SeeResult r => 'sec_see_${r.headword}',
    GrammarDictResult r => 'sec_grammar_${r.headword}',
    SpellingResult r => 'sec_spelling_${r.headword}',
    VariantResult r => 'sec_variant_${r.headword}',
    AbbreviationResult r => 'sec_abbrev_${r.headword}',
    AbbreviationOtherResult r => 'sec_abbrev_other_${r.headword}',
    EpdResult r => 'sec_epd_${r.headword}',
    DeconstructorResult r => 'sec_decon_${r.headword}',
    HelpResult r => 'sec_help_${r.headword}',
    _ => '',
  };

  Widget _buildSecondaryItem(Object result) {
    if (widget.mode != DisplayMode.compact) {
      return switch (result) {
        DeconstructorResult r => DeconstructorCard(result: r),
        GrammarDictResult r => GrammarDictCard(result: r),
        AbbreviationResult r => AbbreviationCard(result: r),
        AbbreviationOtherResult r => AbbreviationOtherCard(result: r),
        HelpResult r => HelpCard(result: r),
        EpdResult r => EpdCard(result: r),
        VariantResult r => VariantCard(result: r),
        SpellingResult r => SpellingCard(result: r),
        SeeResult r => SeeCard(result: r),
        _ => const SizedBox.shrink(),
      };
    }

    final (title, compactChild, expandedChild) = switch (result) {
      GrammarDictResult r => (
        'grammar: ${r.headword}',
        CompactGrammarTable(entries: r.entries) as Widget,
        GrammarDictCard(result: r) as Widget,
      ),
      DeconstructorResult r => (
        'deconstructor: ${r.headword}',
        CompactTextLines(lines: r.deconstructions) as Widget,
        DeconstructorCard(result: r) as Widget,
      ),
      AbbreviationResult r => (
        r.headword,
        CompactTextLines(lines: [r.meaning]) as Widget,
        AbbreviationCard(result: r) as Widget,
      ),
      AbbreviationOtherResult r => (
        'other abbreviations: ${r.headword}',
        CompactTextLines(
              lines: r.rows
                  .map(
                    (row) => row.notes == null
                        ? '${row.source}: ${row.meaning}'
                        : '${row.source}: ${row.meaning} ${row.notes}',
                  )
                  .toList(),
            )
            as Widget,
        AbbreviationOtherCard(result: r) as Widget,
      ),
      HelpResult r => (
        r.headword,
        CompactTextLines(lines: [r.helpText]) as Widget,
        HelpCard(result: r) as Widget,
      ),
      EpdResult r => (
        'English: ${r.headword}',
        CompactEpdList(entries: r.entries) as Widget,
        EpdCard(result: r) as Widget,
      ),
      VariantResult r => (
        'variants: ${r.headword}',
        CompactVariantSummary(variants: r.variants) as Widget,
        VariantCard(result: r) as Widget,
      ),
      SpellingResult r => (
        'spelling: ${r.headword}',
        CompactTextLines(
              lines: r.spellings
                  .map((s) => 'incorrect spelling of $s')
                  .toList(),
            )
            as Widget,
        SpellingCard(result: r) as Widget,
      ),
      SeeResult r => (
        'see: ${r.headword}',
        CompactTextLines(lines: r.seeHeadwords.map((s) => 'see $s').toList())
            as Widget,
        SeeCard(result: r) as Widget,
      ),
      _ => (
        '',
        const SizedBox.shrink() as Widget,
        const SizedBox.shrink() as Widget,
      ),
    };

    return AccordionSecondaryCard(
      title: title,
      compactChild: compactChild,
      expandedChild: expandedChild,
    );
  }

  Widget _buildItem(BuildContext context, DpdHeadwordWithRoot hw) {
    return switch (widget.mode) {
      DisplayMode.classic => InlineEntryCard(headword: hw),
      DisplayMode.compact => AccordionCard(headword: hw),
    };
  }

  Widget _buildRootItem(BuildContext context, RootWithFamilies rwf) {
    return switch (widget.mode) {
      DisplayMode.classic => InlineRootCard(rwf: rwf),
      DisplayMode.compact => AccordionRootCard(rwf: rwf),
    };
  }
}

class TierDivider extends StatelessWidget {
  const TierDivider({super.key, required this.label, this.isCompact = false});

  final String label;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? HSLColor.fromAHSL(1, 198, 1, 0.18).toColor()
        : HSLColor.fromAHSL(1, 198, 1, 0.82).toColor();
    final textColor = theme.colorScheme.onSurface;
    final textStyle = isCompact
        ? theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          );
    return Container(
      width: double.infinity,
      color: bgColor,
      margin: const EdgeInsets.only(top: 24, bottom: 15),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isCompact ? 6 : 8,
      ),
      child: Text(label, style: textStyle),
    );
  }
}

class AccordionSecondaryCard extends StatefulWidget {
  const AccordionSecondaryCard({
    super.key,
    required this.title,
    required this.compactChild,
    required this.expandedChild,
  });

  final String title;
  final Widget compactChild;
  final Widget expandedChild;

  @override
  State<AccordionSecondaryCard> createState() => _AccordionSecondaryCardState();
}

class _AccordionSecondaryCardState extends State<AccordionSecondaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boldStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.5,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _isExpanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = false),
                    child: widget.expandedChild,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = true),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                      child: Text(widget.title, style: boldStyle),
                    ),
                  ),
                ),
                widget.compactChild,
              ],
            ),
    );
  }
}

class CompactGrammarTable extends StatelessWidget {
  const CompactGrammarTable({super.key, required this.entries});

  final List<GrammarDictEntry> entries;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in entries)
            Text(
              '${e.components.where((c) => c.isNotEmpty).join(' ')} of ${e.headword}',
              style: style,
            ),
        ],
      ),
    );
  }
}

class CompactTextLines extends StatelessWidget {
  const CompactTextLines({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final line in lines) Text(line, style: style)],
      ),
    );
  }
}

class CompactEpdList extends StatelessWidget {
  const CompactEpdList({super.key, required this.entries});

  final List<EpdEntry> entries;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    final boldStyle = style?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in entries)
            Text.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(text: e.headword, style: boldStyle),
                  if (e.posInfo.isNotEmpty) TextSpan(text: ' ${e.posInfo}.'),
                  TextSpan(text: ' ${e.meaning}.'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CompactVariantSummary extends StatelessWidget {
  const CompactVariantSummary({super.key, required this.variants});

  final Map<String, Map<String, List<List<String>>>> variants;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    final lines = <String>[];
    for (final corpus in variants.keys) {
      for (final book in variants[corpus]!.keys) {
        for (final entry in variants[corpus]![book]!) {
          if (entry.length >= 2) {
            lines.add('$corpus $book: ${entry[1]}');
          }
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final line in lines) Text(line, style: style)],
      ),
    );
  }
}
