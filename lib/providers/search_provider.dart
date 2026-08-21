import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../utils/history_recording.dart';
import '../utils/search_timing.dart';
import '../utils/transliteration.dart';
import 'database_provider.dart';
import 'history_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

// Holds the original-script text to display in the search bar when a lookup
// is triggered externally (e.g. share intent). Cleared after one use.
final searchBarTextProvider = StateProvider<String?>((ref) => null);

class ExternalSearchHandler {
  const ExternalSearchHandler(this._ref);

  final Ref _ref;

  void apply(String text) {
    final displayText = text.trim();
    final query = normalizeLookupQuery(text);

    _ref.read(searchBarTextProvider.notifier).state = displayText;
    _ref.read(searchQueryProvider.notifier).state = query;

    if (shouldRecordCommittedSearch(query)) {
      _ref.read(historyProvider.notifier).navigateTo(query);
    }
  }
}

final externalSearchHandlerProvider = Provider<ExternalSearchHandler>((ref) {
  return ExternalSearchHandler(ref);
});


final exactResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadwordWithRoot>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final dao = ref.watch(daoProvider);

      final sw = Stopwatch()..start();
      final literalMatches = await dao.searchExact(query);
      // A query with no literal exact hit may still be an exact match once
      // diacritics/aspirates/doubled consonants are folded (e.g. "kammam"
      // for "kammaṃ") — promote that rescue into the exact tier so it
      // outranks a merely coincidental Partial-tier hit, which renders above
      // Fuzzy regardless of relevance. Skipped entirely when a literal hit
      // already exists, so every already-working exact search is unaffected.
      final result = literalMatches.isEmpty
          ? await dao.searchFuzzyExact(query)
          : literalMatches;
      sw.stop();

      if (enableSearchTiming) {
        final timing = SearchTimingData(query: query);
        timing.recordQueryTime('exact_provider', sw.elapsed);
        recordTiming(timing);
      }

      return result;
    });

final partialResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadwordWithRoot>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final dao = ref.watch(daoProvider);

      final sw = Stopwatch()..start();
      final result = await dao.searchPartial(query);
      sw.stop();

      if (enableSearchTiming) {
        final timing = SearchTimingData(query: query);
        timing.recordQueryTime('partial_provider', sw.elapsed);
        recordTiming(timing);
      }

      return result;
    });

final rootResultsProvider = FutureProvider.autoDispose
    .family<List<RootWithFamilies>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final dao = ref.watch(daoProvider);
      return dao.searchRoots(query);
    });

final fuzzyResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadwordWithRoot>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final dao = ref.watch(daoProvider);

      final sw = Stopwatch()..start();
      final result = await dao.searchFuzzy(query);
      sw.stop();

      if (enableSearchTiming) {
        final timing = SearchTimingData(query: query);
        timing.recordQueryTime('fuzzy_provider', sw.elapsed);
        recordTiming(timing);
      }

      return result;
    });

final closestMatchesProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final dao = ref.watch(daoProvider);
      return dao.searchClosestMatches(query);
    });
