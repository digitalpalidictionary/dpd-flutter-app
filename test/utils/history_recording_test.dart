import 'package:dpd_flutter_app/utils/history_recording.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldRecordCommittedSearch', () {
    test('returns false for empty query', () {
      expect(shouldRecordCommittedSearch(''), isFalse);
    });

    test('returns true for a committed search query', () {
      expect(shouldRecordCommittedSearch('kriya'), isTrue);
    });
  });
}
