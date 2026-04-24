import 'package:dpd_flutter_app/services/intent_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntentService.clean', () {
    test('returns null for null input', () {
      expect(IntentService.clean(null), isNull);
    });

    test('trims whitespace', () {
      expect(IntentService.clean('  hello  '), 'hello');
    });

    test('strips URLs', () {
      expect(
        IntentService.clean('check https://example.com/foo here'),
        'check  here',
      );
    });

    test('strips straight and curly quotes', () {
      expect(IntentService.clean('"kamma"'), 'kamma');
      expect(IntentService.clean("'kamma'"), 'kamma');
      expect(IntentService.clean('\u201Ckamma\u201D'), 'kamma');
      expect(IntentService.clean('\u2018kamma\u2019'), 'kamma');
    });

    test('strips parentheses around sutta codes', () {
      expect(IntentService.clean('(SN12.34)'), 'SN12.34');
    });

    test('strips square brackets', () {
      expect(IntentService.clean('[SN12.34]'), 'SN12.34');
    });

    test('strips curly braces', () {
      expect(IntentService.clean('{kamma}'), 'kamma');
    });

    test('strips mixed brackets and quotes together', () {
      expect(IntentService.clean('"(SN12.34)"'), 'SN12.34');
    });

    test('strips brackets in the middle of text', () {
      expect(IntentService.clean('see (SN12.34) for ref'), 'see SN12.34 for ref');
    });
  });
}
