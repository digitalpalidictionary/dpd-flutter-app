import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'dao.g.dart';

class DpdHeadwordWithRoot {
  final DpdHeadword headword;
  final DpdRoot? root;
  int? rootCount;

  DpdHeadwordWithRoot(this.headword, this.root);
}

@DriftAccessor(
  tables: [
    DpdHeadwords,
    Lookup,
    DpdRoots,
    DbInfo,
    InflectionTemplates,
    FamilyRoot,
    FamilyWord,
    FamilyCompound,
    FamilyIdiom,
    FamilySet,
    SuttaInfo,
  ],
)
class DpdDao extends DatabaseAccessor<AppDatabase> with _$DpdDaoMixin {
  DpdDao(super.db);

  // ── Search ────────────────────────────────────────────────────────────────

  Future<List<DpdHeadwordWithRoot>> searchExact(String query) async {
    if (query.isEmpty) return [];
    final normalized = _normalizeQuery(query);

    final lookupRows = await (select(
      lookup,
    )..where((t) => t.lookupKey.equals(normalized))).get();

    final idSet = _extractIds(lookupRows);
    return _fetchHeadwords(idSet);
  }

  Future<List<DpdHeadwordWithRoot>> searchPartial(
    String query, {
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];
    final normalized = _normalizeQuery(query);

    final lookupRows =
        await (select(lookup)
              ..where(
                (t) =>
                    t.lookupKey.like('$normalized%') &
                    t.lookupKey.equals(normalized).not(),
              )
              ..limit(limit))
            .get();

    final idSet = _extractIds(lookupRows);
    return _fetchHeadwords(idSet);
  }

  Set<int> _extractIds(List<LookupData> lookupRows) {
    final idSet = <int>{};
    for (final row in lookupRows) {
      final hw = row.headwords;
      if (hw != null && hw.isNotEmpty) {
        final ids = (jsonDecode(hw) as List).cast<int>();
        idSet.addAll(ids);
      }
    }
    return idSet;
  }

  Future<List<DpdHeadwordWithRoot>> _fetchHeadwords(Set<int> idSet) async {
    if (idSet.isEmpty) return [];

    final rows = await (select(dpdHeadwords).join([
      leftOuterJoin(dpdRoots, dpdRoots.root.equalsExp(dpdHeadwords.rootKey)),
    ])..where(dpdHeadwords.id.isIn(idSet))).get();

    final uniqueRoots = rows
        .map((row) => row.readTableOrNull(dpdRoots)?.root)
        .whereType<String>()
        .toSet();

    final rootCounts = <String, int>{};
    if (uniqueRoots.isNotEmpty) {
      final countQuery =
          await (selectOnly(dpdHeadwords)
                ..addColumns([dpdHeadwords.rootKey, dpdHeadwords.id.count()])
                ..where(dpdHeadwords.rootKey.isIn(uniqueRoots))
                ..groupBy([dpdHeadwords.rootKey]))
              .get();
      for (final row in countQuery) {
        final root = row.read(dpdHeadwords.rootKey);
        final count = row.read(dpdHeadwords.id.count());
        if (root != null) rootCounts[root] = count ?? 0;
      }
    }

    final results = rows.map((row) {
      final hw = DpdHeadwordWithRoot(
        row.readTable(dpdHeadwords),
        row.readTableOrNull(dpdRoots),
      );
      final rootKey = hw.root?.root;
      if (rootKey != null) {
        hw.rootCount = rootCounts[rootKey];
      }
      return hw;
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

    final hw = DpdHeadwordWithRoot(
      row.readTable(dpdHeadwords),
      row.readTableOrNull(dpdRoots),
    );

    // Calculate rootCount
    final rootKey = hw.root?.root;
    if (rootKey != null) {
      final countQuery =
          await (selectOnly(dpdHeadwords)
                ..addColumns([dpdHeadwords.id.count()])
                ..where(dpdHeadwords.rootKey.equals(rootKey)))
              .getSingle();
      hw.rootCount = countQuery.read(dpdHeadwords.id.count()) ?? 0;
    }

    return hw;
  }

  Future<DpdRoot?> getRoot(String rootKey) {
    return (select(
      dpdRoots,
    )..where((t) => t.root.equals(rootKey))).getSingleOrNull();
  }

  // ── DB metadata ───────────────────────────────────────────────────────────

  // ── Inflection templates ──────────────────────────────────────────────────

  Future<InflectionTemplate?> getInflectionTemplate(String pattern) {
    return (select(
      inflectionTemplates,
    )..where((t) => t.pattern.equals(pattern))).getSingleOrNull();
  }

  Future<List<InflectionTemplate>> getAllInflectionTemplates() {
    return select(inflectionTemplates).get();
  }

  // ── DB metadata ───────────────────────────────────────────────────────────

  // ── Family tables ─────────────────────────────────────────────────────────

  Future<FamilyRootData?> getRootFamily(String rootKey, String familyRootVal) {
    return (select(familyRoot)..where(
          (t) => t.rootKey.equals(rootKey) & t.rootFamily.equals(familyRootVal),
        ))
        .getSingleOrNull();
  }

  Future<FamilyWordData?> getWordFamily(String wordFamilyKey) {
    return (select(
      familyWord,
    )..where((t) => t.wordFamily.equals(wordFamilyKey))).getSingleOrNull();
  }

  Future<List<FamilyCompoundData>> getCompoundFamilies(
    List<String> compoundFamilies,
  ) {
    if (compoundFamilies.isEmpty) return Future.value([]);
    return (select(
      familyCompound,
    )..where((t) => t.compoundFamily.isIn(compoundFamilies))).get();
  }

  Future<List<FamilyIdiomData>> getIdioms(List<String> idioms) {
    if (idioms.isEmpty) return Future.value([]);
    return (select(familyIdiom)..where((t) => t.idiom.isIn(idioms))).get();
  }

  Future<List<FamilySetData>> getSets(List<String> sets) {
    if (sets.isEmpty) return Future.value([]);
    return (select(familySet)..where((t) => t.set_.isIn(sets))).get();
  }

  // ── Sutta info ──────────────────────────────────────────────────────────

  Future<SuttaInfoData?> getSuttaInfo(String lemma1) {
    return (select(
      suttaInfo,
    )..where((t) => t.dpdSutta.equals(lemma1))).getSingleOrNull();
  }

  // ── DB metadata ───────────────────────────────────────────────────────────

  Future<String?> getDbValue(String key) async {
    final row = await (select(
      dbInfo,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // ── Autocomplete index ───────────────────────────────────────────────────

  Future<List<String>> getAllLemmas() async {
    final rows = await (selectOnly(
      dpdHeadwords,
      distinct: true,
    )..addColumns([dpdHeadwords.lemma1])).get();
    return rows.map((r) => r.read(dpdHeadwords.lemma1)!).toList();
  }

  Future<List<String>> getAllRoots() async {
    final rows = await (selectOnly(
      dpdRoots,
      distinct: true,
    )..addColumns([dpdRoots.root])).get();
    return rows.map((r) => r.read(dpdRoots.root)!).toList();
  }

  Future<List<String>> getAllRootFamilies() async {
    final rows = await (selectOnly(
      familyRoot,
      distinct: true,
    )..addColumns([familyRoot.rootFamily])).get();
    return rows.map((r) => r.read(familyRoot.rootFamily)!).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _normalizeQuery(String input) {
    return input.trim().toLowerCase().replaceAll("'", '');
  }
}

// Pāḷi alphabet sort order — digraphs checked before single chars.
const Map<String, String> _paliOrder = {
  '√': '00',
  'a': '01',
  'ā': '02',
  'i': '03',
  'ī': '04',
  'u': '05',
  'ū': '06',
  'e': '07',
  'o': '08',
  'k': '09',
  'kh': '10',
  'g': '11',
  'gh': '12',
  'ṅ': '13',
  'c': '14',
  'ch': '15',
  'j': '16',
  'jh': '17',
  'ñ': '18',
  'ṭ': '19',
  'ṭh': '20',
  'ḍ': '21',
  'ḍh': '22',
  'ṇ': '23',
  't': '24',
  'th': '25',
  'd': '26',
  'dh': '27',
  'n': '28',
  'p': '29',
  'ph': '30',
  'b': '31',
  'bh': '32',
  'm': '33',
  'y': '34',
  'r': '35',
  'l': '36',
  'v': '37',
  's': '38',
  'h': '39',
  'ḷ': '40',
  'ṃ': '41',
};

const _paliDigraphs = {
  'kh',
  'gh',
  'ch',
  'jh',
  'ṭh',
  'ḍh',
  'th',
  'dh',
  'ph',
  'bh',
};

String paliSortKey(String lemma) {
  final lower = lemma.toLowerCase();
  final spaceIdx = lower.indexOf(' ');
  final base = spaceIdx == -1 ? lower : lower.substring(0, spaceIdx);
  final suffix = spaceIdx == -1 ? '' : lower.substring(spaceIdx);

  final buffer = StringBuffer();
  int i = 0;
  while (i < base.length) {
    if (i + 1 < base.length) {
      final digraph = base.substring(i, i + 2);
      if (_paliDigraphs.contains(digraph)) {
        buffer.write(_paliOrder[digraph]);
        i += 2;
        continue;
      }
    }
    final ch = base[i];
    final order = _paliOrder[ch];
    if (order != null) {
      buffer.write(order);
    }
    i++;
  }

  buffer.write(suffix);
  return buffer.toString();
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
  int? get rootCount => this.rootCount;
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
  String? get freqData => headword.freqData;
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
