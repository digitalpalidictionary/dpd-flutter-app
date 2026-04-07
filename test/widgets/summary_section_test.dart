import 'package:dpd_flutter_app/widgets/summary_section.dart';
import 'package:dpd_flutter_app/models/summary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('splitSummaryLemma', () {
    test('returns full lemma when there is no numeric suffix', () {
      final result = splitSummaryLemma('dhammavicara');

      expect(result.lemma, 'dhammavicara');
      expect(result.suffix, isNull);
    });

    test('splits a decimal numeric suffix from the lemma', () {
      final result = splitSummaryLemma('dhamma 1.01');

      expect(result.lemma, 'dhamma');
      expect(result.suffix, '1.01');
    });

    test('splits dotted numeric suffix variants from the lemma', () {
      final result = splitSummaryLemma('dhamma 1.1.');

      expect(result.lemma, 'dhamma');
      expect(result.suffix, '1.1.');
    });
  });

  group('shouldShowHeadwordHeading', () {
    const numberedFirst = SummaryEntry(
      type: SummaryEntryType.headword,
      label: 'dhamma 1.01',
      typeLabel: 'masc.',
      meaning: 'nature',
      targetId: 'hw_1',
    );
    const numberedSecond = SummaryEntry(
      type: SummaryEntryType.headword,
      label: 'dhamma 1.02',
      typeLabel: 'masc.',
      meaning: 'quality',
      targetId: 'hw_2',
    );
    const plain = SummaryEntry(
      type: SummaryEntryType.headword,
      label: 'dhammavicara',
      typeLabel: 'masc.',
      meaning: 'pondering',
      targetId: 'hw_3',
    );

    test('shows heading for a plain headword entry', () {
      expect(shouldShowHeadwordHeading(plain, null), isTrue);
    });

    test('shows heading for first numbered entry in a sequence', () {
      expect(shouldShowHeadwordHeading(numberedFirst, null), isTrue);
    });

    test('hides heading for later numbered entries with same lemma', () {
      expect(shouldShowHeadwordHeading(numberedSecond, numberedFirst), isFalse);
    });

    test('shows heading again when numbered sequence changes lemma', () {
      const other = SummaryEntry(
        type: SummaryEntryType.headword,
        label: 'vinaya 1.01',
        typeLabel: 'masc.',
        meaning: 'discipline',
        targetId: 'hw_4',
      );

      expect(shouldShowHeadwordHeading(other, numberedSecond), isTrue);
    });
  });
}
