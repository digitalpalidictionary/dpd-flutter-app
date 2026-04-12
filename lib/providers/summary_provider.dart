import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../models/lookup_results.dart';
import '../models/summary_entry.dart';
import 'dict_provider.dart';
import 'search_provider.dart';
import 'secondary_results_provider.dart';

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
      final enabled = ref.watch(dictVisibilityProvider).enabled;

      return buildSummaryEntries(
        exact,
        roots,
        secondary,
        enabledSources: enabled,
      );
    });

List<SummaryEntry> buildSummaryEntries(
  List<DpdHeadwordWithRoot> exact,
  List<RootWithFamilies> roots,
  List<Object> secondary, {
  Set<String>? enabledSources,
}) {
  bool sourceEnabled(String id) =>
      enabledSources == null || enabledSources.contains(id);

  final entries = <SummaryEntry>[];

  if (sourceEnabled('dpd_headwords')) {
    for (final hw in exact) {
      final meaning = _buildHeadwordSummaryMeaning(hw.headword);
      entries.add(
        SummaryEntry(
          type: SummaryEntryType.headword,
          label: hw.headword.lemma1,
          typeLabel: hw.headword.pos?.isNotEmpty == true
              ? '${hw.headword.pos}.'
              : '',
          meaning: meaning,
          targetId: 'hw_${hw.headword.id}',
        ),
      );
    }
  }

  if (sourceEnabled('dpd_roots')) {
    for (final rwf in roots) {
      final rootClean = rwf.root.root.replaceFirst('√', '');
      entries.add(
        SummaryEntry(
          type: SummaryEntryType.root,
          label: rwf.root.root,
          typeLabel: 'root.',
          meaning: '$rootClean (${rwf.root.rootMeaning})',
          targetId: 'root_${rwf.root.root}',
        ),
      );
    }
  }

  for (final result in secondary) {
    final srcId = _secondarySourceId[result.runtimeType.toString()];
    if (srcId != null && !sourceEnabled(srcId)) continue;

    switch (result) {
      case SeeResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.see,
            label: r.headword,
            typeLabel: 'see headword.',
            meaning: '',
            targetId: 'sec_see_${r.headword}',
          ),
        );
      case GrammarDictResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.grammar,
            label: r.headword,
            typeLabel: 'grammar.',
            meaning: '',
            targetId: 'sec_grammar_${r.headword}',
          ),
        );
      case SpellingResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.spelling,
            label: r.headword,
            typeLabel: 'spelling mistake.',
            meaning: '',
            targetId: 'sec_spelling_${r.headword}',
          ),
        );
      case VariantResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.variant,
            label: r.headword,
            typeLabel: 'variants.',
            meaning: '',
            targetId: 'sec_variant_${r.headword}',
          ),
        );
      case AbbreviationResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.abbreviation,
            label: r.headword,
            typeLabel: 'abbreviation.',
            meaning: r.meaning,
            targetId: 'sec_abbrev_${r.headword}',
          ),
        );
      case AbbreviationOtherResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.abbreviationOther,
            label: r.headword,
            typeLabel: 'other abbreviations.',
            meaning: '',
            targetId: 'sec_abbrev_other_${r.headword}',
          ),
        );
      case EpdResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.epd,
            label: r.headword,
            typeLabel: 'English.',
            meaning: '',
            targetId: 'sec_epd_${r.headword}',
          ),
        );
      case DeconstructorResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.deconstructor,
            label: r.headword,
            typeLabel: 'deconstructor.',
            meaning: '',
            targetId: 'sec_decon_${r.headword}',
          ),
        );
      case HelpResult r:
        entries.add(
          SummaryEntry(
            type: SummaryEntryType.help,
            label: r.headword,
            typeLabel: 'help.',
            meaning: '',
            targetId: 'sec_help_${r.headword}',
          ),
        );
      default:
        break;
    }
  }

  return entries;
}

String _buildHeadwordSummaryMeaning(DpdHeadword headword) {
  final meaning = headword.meaning1?.isNotEmpty == true
      ? headword.meaning1!
      : headword.meaning2 ?? '';
  final summary = headword.constructionSummary;

  if (summary.isEmpty) return meaning;
  if (meaning.isEmpty) return '[$summary]';
  return '$meaning [$summary]';
}
