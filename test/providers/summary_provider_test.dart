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
  String? meaning2,
  String? construction,
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
    meaning2: meaning2,
    rootKey: null,
    rootSign: null,
    rootBase: null,
    familyRoot: null,
    familyWord: null,
    familyCompound: null,
    familyIdioms: null,
    familySet: null,
    construction: construction,
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

    test('appends construction summary to headword meaning when present', () {
      final hw = DpdHeadwordWithRoot(
        _headword(
          id: 3,
          lemma1: 'dhamma',
          pos: 'masc',
          meaning1: 'truth',
          construction: 'dhar + ma',
        ),
        null,
      );

      final result = buildSummaryEntries([hw], [], []);

      expect(result[0].meaning, 'truth [dhar + ma]');
    });

    test('falls back to meaning2 when meaning1 is empty', () {
      final hw = DpdHeadwordWithRoot(
        _headword(
          id: 4,
          lemma1: 'attha',
          pos: 'masc',
          meaning1: '',
          meaning2: 'meaning',
        ),
        null,
      );

      final result = buildSummaryEntries([hw], [], []);

      expect(result[0].meaning, 'meaning');
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
      final abbrev = AbbreviationResult(headword: 'adj', meaning: 'adjective');
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

    test('headword with null pos omits the type label', () {
      final hw = DpdHeadwordWithRoot(
        _headword(id: 2, lemma1: 'x', pos: null, meaning1: 'something'),
        null,
      );
      final result = buildSummaryEntries([hw], [], []);
      expect(result[0].typeLabel, '');
    });
  });

  group('buildSummaryEntries — DPD source filtering', () {
    final hwResult = DpdHeadwordWithRoot(
      _headword(id: 1, lemma1: 'buddha', meaning1: 'awakened'),
      null,
    );
    final abbrevResult = AbbreviationResult(
      headword: 'adj',
      meaning: 'adjective',
    );
    final grammarResult = GrammarDictResult(headword: 'buddha', entries: []);
    final deconResult = DeconstructorResult(
      headword: 'buddha',
      deconstructions: ['budh + a'],
    );
    final helpResult = HelpResult(headword: 'adj', helpText: 'help');
    final epdResult = EpdResult(headword: 'adj', entries: []);
    final variantResult = VariantResult(headword: 'adj', variants: {});
    final spellingResult = SpellingResult(headword: 'adj', spellings: ['adj']);
    final seeResult = SeeResult(headword: 'adj', seeHeadwords: ['adjectival']);

    final allSecondary = <Object>[
      abbrevResult,
      deconResult,
      grammarResult,
      helpResult,
      epdResult,
      variantResult,
      spellingResult,
      seeResult,
    ];

    test('enabledSources null includes all entries (backward compat)', () {
      final entries = buildSummaryEntries([hwResult], [], allSecondary);
      expect(
        entries.where((e) => e.type == SummaryEntryType.headword),
        hasLength(1),
      );
      expect(
        entries.where((e) => e.type == SummaryEntryType.abbreviation),
        hasLength(1),
      );
      expect(
        entries.where((e) => e.type == SummaryEntryType.grammar),
        hasLength(1),
      );
      expect(entries.length, 9);
    });

    test('dpd_headwords disabled removes headword entries', () {
      final enabledSources = {
        'dpd_abbreviations',
        'dpd_grammar',
        'dpd_deconstructor',
        'dpd_help',
        'dpd_epd',
        'dpd_variants',
        'dpd_spelling',
        'dpd_see',
      };
      final entries = buildSummaryEntries(
        [hwResult],
        [],
        allSecondary,
        enabledSources: enabledSources,
      );
      expect(entries.any((e) => e.type == SummaryEntryType.headword), isFalse);
      expect(
        entries.any((e) => e.type == SummaryEntryType.abbreviation),
        isTrue,
      );
    });

    test('dpd_abbreviations disabled removes abbreviation entries', () {
      final enabledSources = {
        'dpd_headwords',
        'dpd_grammar',
        'dpd_deconstructor',
        'dpd_help',
        'dpd_epd',
        'dpd_variants',
        'dpd_spelling',
        'dpd_see',
      };
      final entries = buildSummaryEntries(
        [hwResult],
        [],
        allSecondary,
        enabledSources: enabledSources,
      );
      expect(
        entries.any((e) => e.type == SummaryEntryType.abbreviation),
        isFalse,
      );
      expect(entries.any((e) => e.type == SummaryEntryType.headword), isTrue);
    });

    test('each secondary type filtered by its corresponding source ID', () {
      final typeToSource = {
        SummaryEntryType.abbreviation: 'dpd_abbreviations',
        SummaryEntryType.deconstructor: 'dpd_deconstructor',
        SummaryEntryType.grammar: 'dpd_grammar',
        SummaryEntryType.help: 'dpd_help',
        SummaryEntryType.epd: 'dpd_epd',
        SummaryEntryType.variant: 'dpd_variants',
        SummaryEntryType.spelling: 'dpd_spelling',
        SummaryEntryType.see: 'dpd_see',
      };

      for (final entry in typeToSource.entries) {
        final entryType = entry.key;
        final sourceId = entry.value;

        // Enabled with only this source
        final withSource = buildSummaryEntries(
          [],
          [],
          allSecondary,
          enabledSources: {sourceId},
        );
        expect(
          withSource.any((e) => e.type == entryType),
          isTrue,
          reason: '$sourceId should include $entryType',
        );

        // Disabled — none of the sources
        final withoutSource = buildSummaryEntries(
          [],
          [],
          allSecondary,
          enabledSources: const {},
        );
        expect(
          withoutSource.any((e) => e.type == entryType),
          isFalse,
          reason: 'empty enabledSources should exclude $entryType',
        );
      }
    });

    test(
      'all secondary DPD sources enabled with empty enabledSources omits all',
      () {
        final entries = buildSummaryEntries(
          [hwResult],
          [],
          allSecondary,
          enabledSources: const {},
        );
        expect(entries, isEmpty);
      },
    );

    test('dpd_roots disabled removes root entries', () {
      final rwf = RootWithFamilies(
        root: _root(root: '√bud', meaning: 'to know'),
        families: [],
        count: 1,
      );
      final entries = buildSummaryEntries(
        [],
        [rwf],
        [],
        enabledSources: const {'dpd_headwords'},
      );
      expect(entries.any((e) => e.type == SummaryEntryType.root), isFalse);
    });

    test('dpd_roots enabled includes root entries', () {
      final rwf = RootWithFamilies(
        root: _root(root: '√bud', meaning: 'to know'),
        families: [],
        count: 1,
      );
      final entries = buildSummaryEntries(
        [],
        [rwf],
        [],
        enabledSources: const {'dpd_roots'},
      );
      expect(entries.any((e) => e.type == SummaryEntryType.root), isTrue);
    });
  });
}
