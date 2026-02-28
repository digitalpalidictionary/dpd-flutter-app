import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'dao.g.dart';

class DpdHeadwordWithRoot {
  final DpdHeadword headword;
  final DpdRoot? root;

  DpdHeadwordWithRoot(this.headword, this.root);
}

@DriftAccessor(tables: [DpdHeadwords, Lookup, DpdRoots, DbInfo])
class DpdDao extends DatabaseAccessor<AppDatabase> with _$DpdDaoMixin {
  DpdDao(super.db);

  // ── Search ────────────────────────────────────────────────────────────────

  Future<List<DpdHeadwordWithRoot>> search(
    String query, {
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final normalized = _normalizeQuery(query);

    final lookupRows =
        await (select(lookup)
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

    final rows = await (select(dpdHeadwords).join([
      leftOuterJoin(dpdRoots, dpdRoots.root.equalsExp(dpdHeadwords.rootKey)),
    ])..where(dpdHeadwords.id.isIn(idSet))).get();

    final results = rows.map((row) {
      return DpdHeadwordWithRoot(
        row.readTable(dpdHeadwords),
        row.readTableOrNull(dpdRoots),
      );
    }).toList();

    results.sort(
      (a, b) => paliSortKey(
        a.headword.lemma1,
      ).compareTo(paliSortKey(b.headword.lemma1)),
    );
    return results;
  }

  // ── Single entry ──────────────────────────────────────────────────────────

  Future<DpdHeadwordWithRoot?> getById(int id) async {
    final row = await (select(dpdHeadwords).join([
      leftOuterJoin(dpdRoots, dpdRoots.root.equalsExp(dpdHeadwords.rootKey)),
    ])..where(dpdHeadwords.id.equals(id))).getSingleOrNull();

    if (row == null) return null;

    return DpdHeadwordWithRoot(
      row.readTable(dpdHeadwords),
      row.readTableOrNull(dpdRoots),
    );
  }

  Future<DpdRoot?> getRoot(String rootKey) {
    return (select(
      dpdRoots,
    )..where((t) => t.root.equals(rootKey))).getSingleOrNull();
  }

  // ── DB metadata ───────────────────────────────────────────────────────────

  Future<String?> getDbValue(String key) async {
    final row = await (select(
      dbInfo,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _normalizeQuery(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll('\u1e43', '\u1e43');
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

extension DpdHeadwordGetters on DpdHeadwordWithRoot {
  int get id => headword.id;
  String get lemma1 => headword.lemma1;
  String? get lemma2 => headword.lemma2;
  String? get pos => headword.pos;
  String? get grammar => headword.grammar;
  String? get derivedFrom => headword.derivedFrom;
  String? get neg => headword.neg;
  String? get verb => headword.verb;
  String? get trans => headword.trans;
  String? get plusCase => headword.plusCase;
  String? get derivative => headword.derivative;
  String? get meaning1 => headword.meaning1;
  String? get meaningLit => headword.meaningLit;
  String? get meaning2 => headword.meaning2;
  String? get rootKey => headword.rootKey;
  String? get rootSign => headword.rootSign;
  String? get rootBase => headword.rootBase;
  String? get familyRoot => headword.familyRoot;
  String? get familyWord => headword.familyWord;
  String? get familyCompound => headword.familyCompound;
  String? get familyIdioms => headword.familyIdioms;
  String? get familySet => headword.familySet;
  String? get construction => headword.construction;
  String? get compoundType => headword.compoundType;
  String? get compoundConstruction => headword.compoundConstruction;
  String? get source1 => headword.source1;
  String? get sutta1 => headword.sutta1;
  String? get example1 => headword.example1;
  String? get source2 => headword.source2;
  String? get sutta2 => headword.sutta2;
  String? get example2 => headword.example2;
  String? get antonym => headword.antonym;
  String? get synonym => headword.synonym;
  String? get variant => headword.variant;
  String? get stem => headword.stem;
  String? get pattern => headword.pattern;
  String? get suffix => headword.suffix;
  String? get inflectionsHtml => headword.inflectionsHtml;
  String? get freqHtml => headword.freqHtml;
  int? get ebtCount => headword.ebtCount;
  String? get nonIa => headword.nonIa;
  String? get sanskrit => headword.sanskrit;
  String? get cognate => headword.cognate;
  String? get link => headword.link;
  String? get phonetic => headword.phonetic;
  String? get varPhonetic => headword.varPhonetic;
  String? get varText => headword.varText;
  String? get origin => headword.origin;
  String? get notes => headword.notes;
  String? get commentary => headword.commentary;
}
