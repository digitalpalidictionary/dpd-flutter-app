import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/dict_provider.dart';
import '../providers/search_provider.dart';
import '../providers/secondary_results_provider.dart';
import '../models/summary_entry.dart';
import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import '../utils/search_timing.dart';
import 'empty_prompt.dart';
import 'split_results_list.dart';

/// The full result stack for one query — headwords, roots, secondary sources
/// and external dictionaries, across the exact/partial/fuzzy tiers.
///
/// Shared by the search screen and the word popup so both show the same thing.
/// The caller supplies the surrounding [TapSearchWrapper], because a tap means
/// different things on the two surfaces.
class SearchResultsBody extends ConsumerWidget {
  const SearchResultsBody({
    super.key,
    required this.query,
    this.allowSummary = true,
    this.suggestionsVisible = false,
    this.recordTimings = false,
  });

  final String query;

  /// Surfaces that must never show the summary pass false. The user's own
  /// summary setting and compact mode still apply on top of this.
  final bool allowSummary;

  /// While an autocomplete dropdown is offering completions the "no results"
  /// verdict is withheld. Surfaces without a dropdown pass false.
  final bool suggestionsVisible;

  /// Only the search screen records timings; popup renders would pollute them.
  final bool recordTimings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exactAsync = ref.watch(exactResultsProvider(query));
    final partialAsync = ref.watch(partialResultsProvider(query));

    final exact = exactAsync.valueOrNull ?? [];
    final exactIds = exact.map((e) => e.headword.id).toSet();
    final partial = (partialAsync.valueOrNull ?? [])
        .where((e) => !exactIds.contains(e.headword.id))
        .toList();
    final exactLoading = exactAsync.isLoading;
    final partialLoading = partialAsync.isLoading;

    final rootAsync = ref.watch(rootResultsProvider(query));
    final roots = rootAsync.valueOrNull ?? [];

    final secondaryAsync = ref.watch(secondaryResultsProvider(query));
    final secondary = secondaryAsync.valueOrNull ?? [];

    final dictAsync = ref.watch(dictResultsProvider(query));
    final dictSearch = dictAsync.valueOrNull ?? const DictSearchResults();
    final dictExact = dictSearch.exact;
    final dictPartial = dictSearch.partial;
    final dictFuzzy = dictSearch.fuzzy;

    if (exactLoading && exact.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exactAsync.hasError && exact.isEmpty) {
      return Center(child: Text('Error: ${exactAsync.error}'));
    }

    final settings = ref.watch(settingsProvider);

    final fuzzyAsync = ref.watch(fuzzyResultsProvider(query));
    final exactAndPartialIds = {
      ...exactIds,
      ...partial.map((e) => e.headword.id),
    };
    final fuzzyRaw = (fuzzyAsync.valueOrNull ?? [])
        .where((e) => !exactAndPartialIds.contains(e.headword.id))
        .toList();

    final visiblePartial = settings.showPartialResults
        ? partial
        : <DpdHeadwordWithRoot>[];
    final visibleFuzzy = settings.showFuzzyResults
        ? fuzzyRaw
        : <DpdHeadwordWithRoot>[];
    final visibleDictPartial = settings.showPartialResults
        ? dictPartial
        : <DictResult>[];
    final visibleDictFuzzy = settings.showFuzzyResults
        ? dictFuzzy
        : <DictResult>[];

    if (exact.isEmpty &&
        visiblePartial.isEmpty &&
        roots.isEmpty &&
        secondary.isEmpty &&
        dictExact.isEmpty &&
        visibleDictPartial.isEmpty &&
        visibleDictFuzzy.isEmpty &&
        visibleFuzzy.isEmpty &&
        !partialLoading &&
        !fuzzyAsync.isLoading &&
        !dictAsync.isLoading) {
      // While the dropdown is offering completions the user is still mid-word,
      // so withhold the no-results verdict — declaring failure and suggesting
      // words at the same time is contradictory. The verdict appears as soon
      // as the dropdown closes (word finished, tapped, or no completions).
      if (suggestionsVisible) {
        return const EmptyPrompt();
      }
      return NoResultsWithSuggestions(query: query);
    }

    final showSummary =
        allowSummary &&
        settings.showSummary &&
        settings.displayMode != DisplayMode.compact;

    final visibility = ref.watch(dictVisibilityProvider);
    final summaryEntries = showSummary
        ? ref.watch(summaryEntriesProvider(query))
        : const <SummaryEntry>[];

    if (recordTimings && enableSearchTiming) {
      final timing = SearchTimingData(query: query);
      timing.startRenderTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        timing.endRenderTimer();
        timing.recordTotalSearchTime(
          DateTime.now().difference(timing.startedAt),
        );
        recordTiming(timing);
      });
    }

    return SplitResultsList(
      exact: exact,
      partial: visiblePartial,
      partialLoading: partialLoading,
      roots: roots,
      secondary: secondary,
      dictExact: dictExact,
      dictPartial: visibleDictPartial,
      dictFuzzy: visibleDictFuzzy,
      summaryEntries: summaryEntries,
      showSummary: showSummary,
      mode: settings.displayMode,
      visibility: visibility,
      fuzzy: visibleFuzzy,
    );
  }
}
