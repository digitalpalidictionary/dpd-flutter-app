import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../models/lookup_results.dart';
import '../models/summary_entry.dart';
import 'dict_provider.dart';
import 'search_provider.dart';
import 'secondary_results_provider.dart';
import 'settings_provider.dart';

// Maps secondary result runtime type to its DPD source ID.
const _secondarySourceId = {
  'AbbreviationResult': 'dpd_abbreviations',
  'AbbreviationOtherResult': 'dpd_abbreviations_other',
  'DeconstructorResult': 'dpd_deconstructor',
  'GrammarDictResult': 'dpd_grammar',
  'HelpResult': 'dpd_help',
  'EpdResult': 'dpd_epd',
  'VariantResult': 'dpd_variants',
  'SpellingResult': 'dpd_spelling',
  'SeeResult': 'dpd_see',
};

final summaryEntriesProvider = Provider.autoDispose
    .family<List<SummaryEntry>, String>((ref, query) {
      if (query.isEmpty) return [];

      final exact = ref.watch(exactResultsProvider(query)).valueOrNull ?? [];
      final roots = ref.watch(rootResultsProvider(query)).valueOrNull ?? [];
      final secondary =
          ref.watch(secondaryResultsProvider(query)).valueOrNull ?? [];
      final visibility = ref.watch(dictVisibilityProvider);
      final settings = ref.watch(settingsProvider);
      final dictExact = settings.showOtherDictsInSummary
          ? ref.watch(dictResultsProvider(query)).valueOrNull?.exact ?? []
          : const <DictResult>[];

      return buildSummaryEntries(
        exact,
        roots,
        secondary,
        enabledSources: visibility.enabled,
        showConstruction: settings.showConstructionInSummary,
        dictExact: dictExact,
        order: visibility.order,
      );
    });

List<SummaryEntry> buildSummaryEntries(
  List<DpdHeadwordWithRoot> exact,
  List<RootWithFamilies> roots,
  List<Object> secondary, {
  Set<String>? enabledSources,
  bool showConstruction = true,
  List<DictResult> dictExact = const [],
  List<String>? order,
}) {
  bool sourceEnabled(String id) =>
      enabledSources == null || enabledSources.contains(id);

  final secondaryBySource = <String, List<Object>>{};
  for (final result in secondary) {
    final srcId = _secondarySourceId[result.runtimeType.toString()];
    if (srcId != null) {
      (secondaryBySource[srcId] ??= <Object>[]).add(result);
    }
  }

  final dictBySource = <String, DictResult>{
    for (final result in dictExact) result.dictId: result,
  };

  final effectiveOrder = order ?? kDpdSources.map((s) => s.id).toList();

  final entries = <SummaryEntry>[];

  for (final sourceId in effectiveOrder) {
    if (sourceId == 'dpd_summary') continue;
    if (!sourceEnabled(sourceId)) continue;

    switch (sourceId) {
      case 'dpd_headwords':
        for (final hw in exact) {
          entries.add(_buildHeadwordEntry(hw, showConstruction));
        }
      case 'dpd_roots':
        for (final rwf in roots) {
          entries.add(_buildRootEntry(rwf));
        }
      default:
        final secondaryResults = secondaryBySource[sourceId];
        if (secondaryResults != null) {
          for (final result in secondaryResults) {
            final built = _buildSecondaryEntry(result);
            if (built != null) entries.add(built);
          }
          continue;
        }
        final dictResult = dictBySource[sourceId];
        if (dictResult != null && dictResult.entries.isNotEmpty) {
          entries.add(_buildDictEntry(dictResult));
        }
    }
  }

  return entries;
}

SummaryEntry _buildHeadwordEntry(
  DpdHeadwordWithRoot hw,
  bool showConstruction,
) {
  final (meaning, hasBold) = _buildHeadwordSummaryMeaning(
    hw.headword,
    showConstruction: showConstruction,
  );
  return SummaryEntry(
    type: SummaryEntryType.headword,
    label: hw.headword.lemma1,
    typeLabel: hw.headword.pos?.isNotEmpty == true ? '${hw.headword.pos}.' : '',
    meaning: meaning,
    meaningHasBold: hasBold,
    targetId: 'hw_${hw.headword.id}',
  );
}

SummaryEntry _buildRootEntry(RootWithFamilies rwf) {
  final rootClean = rwf.root.root.replaceFirst('√', '');
  return SummaryEntry(
    type: SummaryEntryType.root,
    label: rwf.root.root,
    typeLabel: 'root.',
    meaning: '$rootClean (${rwf.root.rootMeaning})',
    targetId: 'root_${rwf.root.root}',
  );
}

SummaryEntry _buildDictEntry(DictResult result) {
  return SummaryEntry(
    type: SummaryEntryType.dict,
    label: result.entries.first.word,
    typeLabel: '${dictShortName(result.dictId)}.',
    meaning: '',
    targetId: 'dict_${result.dictId}',
  );
}

SummaryEntry? _buildSecondaryEntry(Object result) {
  switch (result) {
    case SeeResult r:
      return SummaryEntry(
        type: SummaryEntryType.see,
        label: r.headword,
        typeLabel: 'see headword.',
        meaning: '',
        targetId: 'sec_see_${r.headword}',
      );
    case GrammarDictResult r:
      return SummaryEntry(
        type: SummaryEntryType.grammar,
        label: r.headword,
        typeLabel: 'grammar.',
        meaning: '',
        targetId: 'sec_grammar_${r.headword}',
      );
    case SpellingResult r:
      return SummaryEntry(
        type: SummaryEntryType.spelling,
        label: r.headword,
        typeLabel: 'spelling mistake.',
        meaning: '',
        targetId: 'sec_spelling_${r.headword}',
      );
    case VariantResult r:
      return SummaryEntry(
        type: SummaryEntryType.variant,
        label: r.headword,
        typeLabel: 'variants.',
        meaning: '',
        targetId: 'sec_variant_${r.headword}',
      );
    case AbbreviationResult r:
      return SummaryEntry(
        type: SummaryEntryType.abbreviation,
        label: r.headword,
        typeLabel: 'abbreviation.',
        meaning: r.meaning,
        targetId: 'sec_abbrev_${r.headword}',
      );
    case AbbreviationOtherResult r:
      return SummaryEntry(
        type: SummaryEntryType.abbreviationOther,
        label: r.headword,
        typeLabel: 'other abbreviations.',
        meaning: '',
        targetId: 'sec_abbrev_other_${r.headword}',
      );
    case EpdResult r:
      return SummaryEntry(
        type: SummaryEntryType.epd,
        label: r.headword,
        typeLabel: 'English.',
        meaning: '',
        targetId: 'sec_epd_${r.headword}',
      );
    case DeconstructorResult r:
      return SummaryEntry(
        type: SummaryEntryType.deconstructor,
        label: r.headword,
        typeLabel: 'deconstructor.',
        meaning: '',
        targetId: 'sec_decon_${r.headword}',
      );
    case HelpResult r:
      return SummaryEntry(
        type: SummaryEntryType.help,
        label: r.headword,
        typeLabel: 'help.',
        meaning: '',
        targetId: 'sec_help_${r.headword}',
      );
    default:
      return null;
  }
}

(String, bool) _buildHeadwordSummaryMeaning(
  DpdHeadword headword, {
  bool showConstruction = true,
}) {
  final usesMeaning1 = headword.meaning1?.isNotEmpty == true;
  final meaning = usesMeaning1 ? headword.meaning1! : headword.meaning2 ?? '';
  final summary = headword.constructionSummary;

  if (!showConstruction) return (meaning, usesMeaning1);
  if (summary.isEmpty) return (meaning, usesMeaning1);
  if (meaning.isEmpty) return ('[$summary]', false);
  return ('$meaning [$summary]', usesMeaning1);
}
