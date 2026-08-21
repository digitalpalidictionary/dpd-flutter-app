import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../utils/diacritics.dart';
import 'database_provider.dart';
import 'dict_provider.dart';

final searchIndexProvider = FutureProvider<List<String>>((ref) async {
  final cacheFile = await _cacheFile();
  final dao = ref.watch(daoProvider);

  final dbVersion = await dao.getDbValue('version');
  final cachedVersion = await _readCachedVersion(cacheFile);

  if (cachedVersion == dbVersion && await cacheFile.exists()) {
    try {
      final raw = await cacheFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.cast<String>();
      }
    } catch (_) {
      // Corrupted cache - rebuild
    }
  }

  final terms = <String>{};

  final lemmas = await dao.getAllLemmas();
  for (final l in lemmas) {
    terms.add(l.replaceAll(RegExp(r' \d.*$'), ''));
  }

  final roots = await dao.getAllRoots();
  for (final r in roots) {
    terms.add(r.replaceAll(RegExp(r' \d.*$'), ''));
  }

  final families = await dao.getAllRootFamilies();
  terms.addAll(families);

  final index = _buildIndex(terms);

  await cacheFile.writeAsString(jsonEncode(index));
  await _writeCachedVersion(cacheFile, dbVersion ?? '');

  return index;
});

final autocompleteSuggestionsProvider = Provider.family<List<String>, String>((
  ref,
  query,
) {
  if (query.length < 2) return [];
  final indexAsync = ref.watch(searchIndexProvider);
  final index = indexAsync.valueOrNull;
  if (index == null || index.isEmpty) return [];

  final normalizedQuery = stripDiacritics(query).toLowerCase();
  final matches = <String>[];

  var low = 0;
  var high = index.length - 1;
  var firstMatch = -1;

  while (low <= high) {
    final mid = (low + high) ~/ 2;
    final midKey = index[mid].split('|')[0];
    if (midKey.compareTo(normalizedQuery) >= 0) {
      firstMatch = mid;
      high = mid - 1;
    } else {
      low = mid + 1;
    }
  }

  if (firstMatch == -1) return [];

  for (var i = firstMatch; i < index.length; i++) {
    final entry = index[i];
    final pipeIndex = entry.indexOf('|');
    final key = pipeIndex == -1 ? entry : entry.substring(0, pipeIndex);

    if (!key.startsWith(normalizedQuery)) break;

    if (pipeIndex != -1) {
      final values = entry.substring(pipeIndex + 1).split('|');
      matches.addAll(values);
    }

    if (matches.length >= 100) break;
  }

  matches.sort(_suggestionComparator);

  return matches.length > 100 ? matches.sublist(0, 100) : matches;
});

/// Shortest-first, then alphabetical (diacritic-insensitive), then exact —
/// shared by the headword index and both fallback tiers so suggestions from
/// any tier are ordered the same way.
int _suggestionComparator(String a, String b) {
  final cleanA = stripDiacritics(a).toLowerCase();
  final cleanB = stripDiacritics(b).toLowerCase();
  final lenDiff = cleanA.length - cleanB.length;
  if (lenDiff != 0) return lenDiff;
  if (cleanA != cleanB) return cleanA.compareTo(cleanB);
  return a.compareTo(b);
}

/// Rescue tier: a genuine exact `fuzzy_key` match from the lookup table —
/// e.g. `kammaṃ` for a mistyped `kammam`. [autocompleteSuggestionsProvider]'s
/// index is built from bare lemmas only, so it can miss this entirely: a
/// lemma's own collapsed key can be *shorter* than an inflected query's,
/// which means it can never satisfy that index's prefix rule. Where this
/// fits in the tier order is decided by the caller (`_updateAutocomplete()`
/// in `search_screen.dart`) — it runs after tier 1's synchronous check and
/// can only upgrade an already-shown dropdown, never delay its first paint.
final fuzzyExactSuggestionsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, query) async {
      if (query.length < 2) return [];
      final dao = ref.watch(daoProvider);
      return dao.searchFuzzyExactKeyMatches(query);
    });

/// Fallback: exact-prefix suggestions from the lookup table. Where this fits
/// in the tier order is decided by the caller (`_updateAutocomplete()` in
/// `search_screen.dart`), not here — currently the last resort.
final lookupSuggestionsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, query) async {
      if (query.length < 2) return [];
      final dao = ref.watch(daoProvider);
      final matches = await dao.searchLookupKeysPrefix(query);
      if (matches.isEmpty) return [];

      matches.sort(_suggestionComparator);
      return matches.length > 100 ? matches.sublist(0, 100) : matches;
    });

/// Fallback: exact-prefix suggestions from the enabled external dictionaries.
/// Where this fits in the tier order is decided by the caller
/// (`_updateAutocomplete()` in `search_screen.dart`), not here — currently
/// tried before [lookupSuggestionsProvider].
final dictSuggestionsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, query) async {
      if (query.length < 2) return [];
      final dao = ref.watch(daoProvider);
      final visibility = ref.watch(dictVisibilityProvider);
      // Nothing can be in both `externalIds` and an empty `enabled` set, so
      // skip the await entirely when every dictionary is switched off.
      if (visibility.enabled.isEmpty) return [];
      final allMeta = await ref.watch(dictMetaAllProvider.future);
      // `visibility.order` also lists DPD's own internal sections (grammar,
      // roots, ...); only real external dictionary ids belong in dict_entries.
      final externalIds = allMeta.map((m) => m.dictId).toSet();
      final dictIds = visibility.order
          .where(
            (id) => externalIds.contains(id) && visibility.enabled.contains(id),
          )
          .toList();
      if (dictIds.isEmpty) return [];

      final matches = await dao.searchDictWordsPrefix(dictIds, query);
      if (matches.isEmpty) return [];

      matches.sort(_suggestionComparator);
      return matches.length > 100 ? matches.sublist(0, 100) : matches;
    });

List<String> _buildIndex(Set<String> terms) {
  final indexDict = <String, Set<String>>{};
  for (final term in terms) {
    if (term.isEmpty) continue;
    final normalized = stripDiacritics(term).toLowerCase();
    (indexDict[normalized] ??= {}).add(term);
  }

  final sorted = indexDict.keys.toList()..sort();
  return sorted.map((key) {
    final values = indexDict[key]!.toList()..sort();
    return '$key|${values.join('|')}';
  }).toList();
}

Future<File> _cacheFile() async {
  final docsDir = await getApplicationDocumentsDirectory();
  return File(p.join(docsDir.path, 'search_index.json'));
}

Future<String?> _readCachedVersion(File cacheFile) async {
  final versionFile = File('${cacheFile.path}.version');
  if (await versionFile.exists()) return versionFile.readAsString();
  return null;
}

Future<void> _writeCachedVersion(File cacheFile, String version) async {
  final versionFile = File('${cacheFile.path}.version');
  await versionFile.writeAsString(version);
}
