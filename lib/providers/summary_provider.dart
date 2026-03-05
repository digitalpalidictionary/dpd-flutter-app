import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/lookup_results.dart';
import '../models/summary_entry.dart';
import 'search_provider.dart';
import 'secondary_results_provider.dart';

final summaryEntriesProvider = Provider.autoDispose
    .family<List<SummaryEntry>, String>((ref, query) {
  if (query.isEmpty) return [];

  final exact = ref.watch(exactResultsProvider(query)).valueOrNull ?? [];
  final roots = ref.watch(rootResultsProvider(query)).valueOrNull ?? [];
  final secondary =
      ref.watch(secondaryResultsProvider(query)).valueOrNull ?? [];

  return buildSummaryEntries(exact, roots, secondary);
});

List<SummaryEntry> buildSummaryEntries(
  List<DpdHeadwordWithRoot> exact,
  List<RootWithFamilies> roots,
  List<Object> secondary,
) {
  final entries = <SummaryEntry>[];

  for (final hw in exact) {
    entries.add(SummaryEntry(
      type: SummaryEntryType.headword,
      label: hw.headword.lemma1,
      typeLabel: hw.headword.pos ?? '',
      meaning: hw.headword.meaning1 ?? '',
      targetId: 'hw_${hw.headword.id}',
    ));
  }

  for (final rwf in roots) {
    entries.add(SummaryEntry(
      type: SummaryEntryType.root,
      label: rwf.root.root,
      typeLabel: 'root',
      meaning: rwf.root.rootMeaning,
      targetId: 'root_${rwf.root.root}',
    ));
  }

  for (final result in secondary) {
    switch (result) {
      case SeeResult r:
        entries.add(SummaryEntry(
          type: SummaryEntryType.see,
          label: r.headword,
          typeLabel: 'see',
          meaning: r.seeHeadwords.join(', '),
          targetId: 'sec_see_${r.headword}',
        ));
      case GrammarDictResult r:
        final first = r.entries.isNotEmpty ? r.entries.first : null;
        final desc = first != null
            ? '${first.pos} ${first.components.where((c) => c.isNotEmpty).join(' ')}'
                .trim()
            : '';
        entries.add(SummaryEntry(
          type: SummaryEntryType.grammar,
          label: r.headword,
          typeLabel: 'grammar',
          meaning: desc,
          targetId: 'sec_grammar_${r.headword}',
        ));
      case SpellingResult r:
        entries.add(SummaryEntry(
          type: SummaryEntryType.spelling,
          label: r.headword,
          typeLabel: 'spelling',
          meaning: r.spellings.join(', '),
          targetId: 'sec_spelling_${r.headword}',
        ));
      case VariantResult r:
        entries.add(SummaryEntry(
          type: SummaryEntryType.variant,
          label: r.headword,
          typeLabel: 'variant',
          meaning: '',
          targetId: 'sec_variant_${r.headword}',
        ));
      case AbbreviationResult r:
        entries.add(SummaryEntry(
          type: SummaryEntryType.abbreviation,
          label: r.headword,
          typeLabel: 'abbrev',
          meaning: r.meaning,
          targetId: 'sec_abbrev_${r.headword}',
        ));
      case EpdResult r:
        final first = r.entries.isNotEmpty ? r.entries.first : null;
        entries.add(SummaryEntry(
          type: SummaryEntryType.epd,
          label: r.headword,
          typeLabel: 'epd',
          meaning: first?.meaning ?? '',
          targetId: 'sec_epd_${r.headword}',
        ));
      case DeconstructorResult r:
        entries.add(SummaryEntry(
          type: SummaryEntryType.deconstructor,
          label: r.headword,
          typeLabel: 'decon',
          meaning:
              r.deconstructions.isNotEmpty ? r.deconstructions.first : '',
          targetId: 'sec_decon_${r.headword}',
        ));
      case HelpResult r:
        final text = r.helpText.length > 60
            ? '${r.helpText.substring(0, 60)}…'
            : r.helpText;
        entries.add(SummaryEntry(
          type: SummaryEntryType.help,
          label: r.headword,
          typeLabel: 'help',
          meaning: text,
          targetId: 'sec_help_${r.headword}',
        ));
      default:
        break;
    }
  }

  return entries;
}
