import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/models/lookup_results.dart';
import 'package:dpd_flutter_app/models/summary_entry.dart';
import 'package:dpd_flutter_app/providers/summary_provider.dart';
import 'package:flutter_test/flutter_test.dart';

DpdHeadword _headword({
  required int id,
  required String lemma1,
  String? pos,
  String? meaning1,
}) {
  return DpdHeadword(
    id: id,
    lemma1: lemma1,
    lemma2: null,
    pos: pos,
    grammar: null,
    derivedFrom: null,
    neg: null,
    verb: null,
    trans: null,
    plusCase: null,
    meaning1: meaning1,
    meaningLit: null,
    meaning2: null,
    rootKey: null,
    rootSign: null,
    rootBase: null,
    familyRoot: null,
    familyWord: null,
    familyCompound: null,
    familyIdioms: null,
    familySet: null,
    construction: null,
    compoundType: null,
    compoundConstruction: null,
    source1: null,
    sutta1: null,
    example1: null,
    source2: null,
    sutta2: null,
    example2: null,
    antonym: null,
    synonym: null,
    variant: null,
    stem: null,
    pattern: null,
    suffix: null,
    freqData: null,
    ebtCount: null,
    nonIa: null,
    sanskrit: null,
    cognate: null,
    link: null,
    phonetic: null,
    varPhonetic: null,
    varText: null,
    origin: null,
    notes: null,
    commentary: null,
  );
}

DpdRoot _root({required String root, String meaning = ''}) {
  return DpdRoot(
    root: root,
    rootInComps: '',
    rootHasVerb: '',
    rootGroup: 1,
    rootSign: '',
    rootMeaning: meaning,
    sanskritRoot: '',
    sanskritRootMeaning: '',
    sanskritRootClass: '',
    rootExample: '',
    dhatupathaNum: '',
    dhatupathaRoot: '',
    dhatupathaPali: '',
    dhatupathaEnglish: '',
    dhatumanjusaNum: '',
    dhatumanjusaRoot: '',
    dhatumanjusaPali: '',
    dhatumanjusaEnglish: '',
    dhatumalaRoot: '',
    dhatumalaPali: '',
    dhatumalaEnglish: '',
    paniniRoot: '',
    paniniSanskrit: '',
    paniniEnglish: '',
    note: '',
  );
}

void main() {
  group('buildSummaryEntries', () {
    test('returns empty list when all inputs are empty', () {
      final result = buildSummaryEntries([], [], []);
      expect(result, isEmpty);
    });

    test('creates headword entries with correct fields', () {
      final hw = DpdHeadwordWithRoot(
        _headword(id: 1, lemma1: 'dhamma', pos: 'masc', meaning1: 'truth'),
        null,
      );
      final result = buildSummaryEntries([hw], [], []);

      expect(result, hasLength(1));
      expect(result[0].type, SummaryEntryType.headword);
      expect(result[0].label, 'dhamma');
      expect(result[0].typeLabel, 'masc.');
      expect(result[0].meaning, 'truth');
      expect(result[0].targetId, 'hw_1');
    });

    test('creates root entries with correct fields', () {
      final rwf = RootWithFamilies(
        root: _root(root: '√kam', meaning: 'to love'),
        families: [],
        count: 5,
      );
      final result = buildSummaryEntries([], [rwf], []);

      expect(result, hasLength(1));
      expect(result[0].type, SummaryEntryType.root);
      expect(result[0].label, '√kam');
      expect(result[0].typeLabel, 'root.');
      expect(result[0].meaning, 'kam (to love)');
      expect(result[0].targetId, 'root_√kam');
    });

    test('creates see entry from SeeResult', () {
      final see = SeeResult(
        headword: 'dhamma',
        seeHeadwords: ['dhamma 1', 'dhamma 2'],
      );
      final result = buildSummaryEntries([], [], [see]);

      expect(result, hasLength(1));
      expect(result[0].type, SummaryEntryType.see);
      expect(result[0].typeLabel, 'see headword.');
      expect(result[0].meaning, '');
      expect(result[0].targetId, 'sec_see_dhamma');
    });

    test('creates spelling entry from SpellingResult', () {
      final spelling = SpellingResult(
        headword: 'nibbana',
        spellings: ['nibbāna', 'nibbāṇa'],
      );
      final result = buildSummaryEntries([], [], [spelling]);

      expect(result[0].type, SummaryEntryType.spelling);
      expect(result[0].meaning, '');
      expect(result[0].targetId, 'sec_spelling_nibbana');
    });

    test('creates abbreviation entry from AbbreviationResult', () {
      final abbrev = AbbreviationResult(
        headword: 'adj',
        meaning: 'adjective',
      );
      final result = buildSummaryEntries([], [], [abbrev]);

      expect(result[0].type, SummaryEntryType.abbreviation);
      expect(result[0].typeLabel, 'abbreviation.');
      expect(result[0].meaning, 'adjective');
    });

    test('ordering: headwords first, then roots, then secondary', () {
      final hw = DpdHeadwordWithRoot(
        _headword(id: 1, lemma1: 'a', pos: 'ind'),
        null,
      );
      final rwf = RootWithFamilies(
        root: _root(root: '√a'),
        families: [],
        count: 1,
      );
      final see = SeeResult(headword: 'a', seeHeadwords: ['b']);
      final result = buildSummaryEntries([hw], [rwf], [see]);

      expect(result, hasLength(3));
      expect(result[0].type, SummaryEntryType.headword);
      expect(result[1].type, SummaryEntryType.root);
      expect(result[2].type, SummaryEntryType.see);
    });

    test('headword with null pos uses empty string', () {
      final hw = DpdHeadwordWithRoot(
        _headword(id: 2, lemma1: 'x', pos: null, meaning1: 'something'),
        null,
      );
      final result = buildSummaryEntries([hw], [], []);
      expect(result[0].typeLabel, '.');
    });
  });
}
