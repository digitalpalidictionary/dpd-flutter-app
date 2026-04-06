import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../utils/search_timing.dart';
import 'database_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final exactResultsProvider = FutureProvider.autoDispose
    .family<List<DpdHeadwordWithRoot>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dao = ref.watch(daoProvider);
  
  final sw = Stopwatch()..start();
  final result = await dao.searchExact(query);
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
