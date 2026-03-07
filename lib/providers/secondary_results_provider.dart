import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/lookup_results.dart';
import 'database_provider.dart';

/// Parses a [LookupData] row into an ordered list of secondary result objects.
///
/// Results are ordered: abbreviations → deconstructor → grammar → help →
/// EPD → variant → spelling → see.
/// Null or empty columns produce no entry.
class SecondaryResultsProvider {
  static List<Object> parse(String headword, LookupData row) {
    final results = <Object>[];

    final abbrev = AbbreviationResult.fromJson(headword, row.abbrev);
    if (abbrev != null) results.add(abbrev);

    final deconstructor = DeconstructorResult.fromJson(headword, row.deconstructor);
    if (deconstructor != null) results.add(deconstructor);

    final grammar = GrammarDictResult.fromJson(headword, row.grammar);
    if (grammar != null) results.add(grammar);

    final help = HelpResult.fromJson(headword, row.help);
    if (help != null) results.add(help);

    final epd = EpdResult.fromJson(headword, row.epd);
    if (epd != null) results.add(epd);

    final variant = VariantResult.fromJson(headword, row.variant);
    if (variant != null) results.add(variant);

    final spelling = SpellingResult.fromJson(headword, row.spelling);
    if (spelling != null) results.add(spelling);

    final see = SeeResult.fromJson(headword, row.see);
    if (see != null) results.add(see);

    return results;
  }
}

final secondaryResultsProvider = FutureProvider.autoDispose
    .family<List<Object>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dao = ref.watch(daoProvider);
  final row = await dao.getLookupRow(query);
  if (row == null) return [];
  return SecondaryResultsProvider.parse(row.lookupKey, row);
});
