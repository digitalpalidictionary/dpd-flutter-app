import 'package:flutter_test/flutter_test.dart';
import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/database/dpd_headword_extensions.dart';

void main() {
  group('DpdHeadwordGrammar Extensions', () {
    test('lemmaClean removes numbers at the end', () {
      final hw1 = const DpdHeadword(id: 1, lemma1: 'dhamma 1.01');
      expect(hw1.lemmaClean, 'dhamma');

      final hw2 = const DpdHeadword(id: 2, lemma1: 'sutta 2');
      expect(hw2.lemmaClean, 'sutta');
    });

    test('rootClean removes numbers at the end', () {
      final hw1 = const DpdHeadword(id: 1, lemma1: 'test', rootKey: '√dham 1');
      expect(hw1.rootClean, '√dham');

      final hw2 = const DpdHeadword(id: 2, lemma1: 'test', rootKey: '√sut 2.0');
      expect(hw2.rootClean, '√sut');
    });

    test('cleanConstruction removes phonetic changes and brackets', () {
      final hw = const DpdHeadword(
        id: 1,
        lemma1: 'test',
        construction: 'a + [b] + c > d\nsecond line',
      );
      expect(hw.cleanConstruction(), 'a + c > d');

      final hw2 = const DpdHeadword(
        id: 2,
        lemma1: 'test',
        construction: '[a] + ?? b > phonetic + c + [d]',
      );
      expect(hw2.cleanConstruction(), 'b + c');
    });

    test('cleanConstruction handles empty construction', () {
      final hw = const DpdHeadword(id: 1, lemma1: 'test');
      expect(hw.cleanConstruction(), '');
    });

    test('grammarLine constructs grammar correctly', () {
      final hw = const DpdHeadword(
        id: 1,
        lemma1: 'test',
        grammar: 'masc',
        neg: 'neg',
        verb: 'caus',
        trans: 'trans',
        plusCase: '+acc',
      );
      expect(hw.grammarLine, 'masc, neg, caus, trans (+acc)');

      final hw2 = const DpdHeadword(
        id: 2,
        lemma1: 'test',
        grammar: '',
        neg: 'neg',
      );
      expect(hw2.grammarLine, 'neg');

      final hw3 = const DpdHeadword(id: 3, lemma1: 'test', plusCase: '+acc');
      expect(hw3.grammarLine, '(+acc)');
    });

    test('placeholders return empty string or specific placeholder', () {
      final hw = const DpdHeadword(id: 1, lemma1: 'test');
      expect(hw.lemmaIpa ?? '', isEmpty);
    });

    test('lemmaTradClean applies traditional endings from pattern', () {
      // Test 'ant adj' pattern
      final hw1 = const DpdHeadword(
        id: 1,
        lemma1: 'sīlavant',
        stem: 'sīlav',
        pattern: 'ant adj',
      );
      expect(hw1.lemmaTradClean, 'sīlavantu');

      // Test 'ar masc' pattern
      final hw2 = const DpdHeadword(
        id: 2,
        lemma1: 'satthar',
        stem: 'satth',
        pattern: 'ar masc',
      );
      expect(hw2.lemmaTradClean, 'satthu');

      // Test unknown pattern returns lemmaClean
      final hw3 = const DpdHeadword(
        id: 3,
        lemma1: 'buddha',
        stem: 'buddh',
        pattern: 'unknown',
      );
      expect(hw3.lemmaTradClean, 'buddha');

      // Test stem with ! returns lemmaClean (inflected form)
      final hw4 = const DpdHeadword(
        id: 4,
        lemma1: 'buddhā',
        stem: 'buddh!',
        pattern: 'ar masc',
      );
      expect(hw4.lemmaTradClean, 'buddhā');

      // Test null pattern returns lemmaClean
      final hw5 = const DpdHeadword(id: 5, lemma1: 'gacchati', stem: 'gam');
      expect(hw5.lemmaTradClean, 'gacchati');
    });
  });
}
