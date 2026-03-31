import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'dict_provider.dart';
import 'search_provider.dart';
import 'secondary_results_provider.dart';

enum SearchStatus { initial, loading, hasResults, noResults, error }

class SearchAggregateState {
  final String query;
  final bool anyLoading;
  final bool anyError;
  final bool hasResults;
  final bool shouldShowNoResults;
  final SearchStatus status;

  const SearchAggregateState({
    required this.query,
    required this.anyLoading,
    required this.anyError,
    required this.hasResults,
    required this.shouldShowNoResults,
    required this.status,
  });
}

SearchAggregateState computeSearchState({
  required String query,
  required AsyncValue<List<DpdHeadwordWithRoot>> exact,
  required AsyncValue<List<DpdHeadwordWithRoot>> partial,
  required AsyncValue<List<RootWithFamilies>> root,
  required AsyncValue<List<Object>> secondary,
  required AsyncValue<DictSearchResults> dict,
  required AsyncValue<List<DpdHeadwordWithRoot>> fuzzy,
}) {
  if (query.isEmpty) {
    return const SearchAggregateState(
      query: '',
      anyLoading: false,
      anyError: false,
      hasResults: false,
      shouldShowNoResults: false,
      status: SearchStatus.initial,
    );
  }

  final sources = [exact, partial, root, secondary, dict, fuzzy];
  final anyLoading = sources.any((s) => s.isLoading);
  final anyError = sources.any((s) => s.hasError);

  final exactData = exact.valueOrNull ?? [];
  final partialData = partial.valueOrNull ?? [];
  final rootData = root.valueOrNull ?? [];
  final secondaryData = secondary.valueOrNull ?? [];
  final dictData = dict.valueOrNull ?? const DictSearchResults();
  final fuzzyData = fuzzy.valueOrNull ?? [];

  final hasExact = exactData.isNotEmpty;
  final hasPartial = partialData.isNotEmpty;
  final hasRoot = rootData.isNotEmpty;
  final hasSecondary = secondaryData.isNotEmpty;
  final hasDictExact = dictData.exact.isNotEmpty;
  final hasDictPartial = dictData.partial.isNotEmpty;
  final hasDictFuzzy = dictData.fuzzy.isNotEmpty;
  final hasFuzzy = fuzzyData.isNotEmpty;

  final hasResults = hasExact ||
      hasPartial ||
      hasRoot ||
      hasSecondary ||
      hasDictExact ||
      hasDictPartial ||
      hasDictFuzzy ||
      hasFuzzy;

  final SearchStatus status;
  if (hasResults) {
    status = SearchStatus.hasResults;
  } else if (anyLoading) {
    status = SearchStatus.loading;
  } else if (anyError) {
    status = SearchStatus.error;
  } else {
    status = SearchStatus.noResults;
  }

  return SearchAggregateState(
    query: query,
    anyLoading: anyLoading,
    anyError: anyError,
    hasResults: hasResults,
    shouldShowNoResults: status == SearchStatus.noResults,
    status: status,
  );
}

final searchAggregateStateProvider = Provider.autoDispose
    .family<SearchAggregateState, String>((ref, query) {
  return computeSearchState(
    query: query,
    exact: ref.watch(exactResultsProvider(query)),
    partial: ref.watch(partialResultsProvider(query)),
    root: ref.watch(rootResultsProvider(query)),
    secondary: ref.watch(secondaryResultsProvider(query)),
    dict: ref.watch(dictResultsProvider(query)),
    fuzzy: ref.watch(fuzzyResultsProvider(query)),
  );
});
