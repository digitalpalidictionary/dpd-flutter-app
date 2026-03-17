import 'package:dpd_flutter_app/utils/app_feedback_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildFeedbackUrlFromParams', () {
    test('returns valid Google Form URL with all parameters', () {
      final url = buildFeedbackUrlFromParams(
        platform: 'Android',
        deviceModel: 'Pixel 9',
        osVersion: 'Android 15',
        appVersion: '0.1.1',
        dbVersion: '2026-03-01',
      );

      expect(url, startsWith(feedbackFormBaseUrl));
      final uri = Uri.parse(url);
      expect(uri.queryParameters['entry.405390413'], 'Android');
      expect(uri.queryParameters['entry.671095698'], 'Pixel 9');
      expect(uri.queryParameters['entry.1162202610'], 'Android 15');
      expect(uri.queryParameters['entry.1433863141'], '0.1.1');
      expect(uri.queryParameters['entry.100565099'], '2026-03-01');
    });

    test('uses empty string when dbVersion is null', () {
      final url = buildFeedbackUrlFromParams(
        platform: 'iOS',
        deviceModel: 'iPhone 15',
        osVersion: 'iOS 17.4',
        appVersion: '0.1.1',
      );

      final uri = Uri.parse(url);
      expect(uri.queryParameters['entry.100565099'], '');
    });

    test('uses empty string when dbVersion is empty', () {
      final url = buildFeedbackUrlFromParams(
        platform: 'iOS',
        deviceModel: 'iPhone 15',
        osVersion: 'iOS 17.4',
        appVersion: '0.1.1',
        dbVersion: '',
      );

      final uri = Uri.parse(url);
      expect(uri.queryParameters['entry.100565099'], '');
    });

    test('URI-encodes special characters in parameters', () {
      final url = buildFeedbackUrlFromParams(
        platform: 'Android',
        deviceModel: 'Samsung Galaxy S24+',
        osVersion: 'Android 14',
        appVersion: '1.0.0',
        dbVersion: '2026-03-01',
      );

      expect(url, contains('Samsung'));
      final uri = Uri.parse(url);
      expect(uri.queryParameters['entry.671095698'], 'Samsung Galaxy S24+');
    });
  });
}
