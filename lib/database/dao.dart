import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'dao.g.dart';

@DriftAccessor(tables: [DpdHeadwords, Lookup, DpdRoots, DbInfo])
class DpdDao extends DatabaseAccessor<AppDatabase> with _$DpdDaoMixin {
  DpdDao(super.db);

  // ── Search ────────────────────────────────────────────────────────────────

  Future<List<DpdHeadword>> search(String query, {int limit = 20}) async {
    if (query.isEmpty) return [];

    final normalized = _normalizeQuery(query);

    final lookupRows = await (select(lookup)
          ..where((t) => t.lookupKey.like('$normalized%'))
          ..limit(limit))
        .get();

    final idSet = <int>{};
    for (final row in lookupRows) {
      final hw = row.headwords;
      if (hw != null && hw.isNotEmpty) {
        final ids = (jsonDecode(hw) as List).cast<int>();
        idSet.addAll(ids);
      }
    }

    if (idSet.isEmpty) return [];

    final headwords = await (select(dpdHeadwords)
          ..where((t) => t.id.isIn(idSet)))
        .get();

    headwords.sort((a, b) => paliSortKey(a.lemma1).compareTo(paliSortKey(b.lemma1)));
    return headwords;
  }

  // ── Single entry ──────────────────────────────────────────────────────────

  Future<DpdHeadword?> getById(int id) {
    return (select(dpdHeadwords)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<DpdRoot?> getRoot(String rootKey) {
    return (select(dpdRoots)..where((t) => t.root.equals(rootKey))).getSingleOrNull();
  }

  // ── DB metadata ───────────────────────────────────────────────────────────

  Future<String?> getDbValue(String key) async {
    final row = await (select(dbInfo)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _normalizeQuery(String input) {
    return input.trim().toLowerCase().replaceAll("'", '').replaceAll('\u1e43', '\u1e43');
  }
}

// Pāḷi alphabet sort order — each character maps to a sort position.
// Standard Pāḷi alphabet: a ā i ī u ū e o k kh g gh ṅ c ch j jh ñ ṭ ṭh ḍ ḍh ṇ t th d dh n p ph b bh m y r l ḷ v s h
const Map<String, int> _paliOrder = {
  'a': 0,
  'ā': 1,
  'i': 2,
  'ī': 3,
  'u': 4,
  'ū': 5,
  'e': 6,
  'o': 7,
  'k': 8,
  'g': 10,
  'ṅ': 12,
  'c': 13,
  'j': 15,
  'ñ': 17,
  'ṭ': 18,
  'ḍ': 20,
  'ṇ': 22,
  't': 23,
  'd': 25,
  'n': 27,
  'p': 28,
  'b': 30,
  'm': 32,
  'y': 33,
  'r': 34,
  'l': 35,
  'ḷ': 36,
  'v': 37,
  's': 38,
  'h': 39,
};

String paliSortKey(String lemma) {
  // Strip the numeric suffix (e.g. "dhamma 1.01" → "dhamma")
  final base = lemma.split(' ').first.toLowerCase();
  final buffer = StringBuffer();
  for (final ch in base.characters) {
    final order = _paliOrder[ch];
    if (order != null) {
      buffer.write(order.toString().padLeft(3, '0'));
    } else {
      buffer.write(ch.codeUnitAt(0).toString().padLeft(5, '0'));
    }
  }
  return buffer.toString();
}

// Extension for character iteration (avoids importing characters package)
extension on String {
  Iterable<String> get characters sync* {
    for (int i = 0; i < length;) {
      final rune = runes.elementAt(i);
      yield String.fromCharCode(rune);
      i += rune > 0xFFFF ? 2 : 1;
    }
  }
}
