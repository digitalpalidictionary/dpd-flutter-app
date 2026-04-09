import 'package:dpd_flutter_app/utils/app_feedback_url.dart';
import 'package:dpd_flutter_app/utils/feedback_email_draft.dart';
import 'package:flutter_test/flutter_test.dart';

const _meta = FeedbackMetadata(
  platform: 'Android',
  deviceModel: 'Pixel 9',
  osVersion: 'Android 15',
  appVersion: '0.1.1',
  dbVersion: '2026-03-01',
);

void main() {
  group('buildFeedbackEmailUri', () {
    test('recipient is correct', () {
      final uri = buildFeedbackEmailUri(
        name: 'Alice',
        email: 'alice@example.com',
        issueType: 'App crash or freeze',
        description: 'Crashes on startup',
        improvement: '',
        metadata: _meta,
      );

      expect(uri.scheme, 'mailto');
      expect(uri.path, 'digitalpalidictionary@gmail.com');
    });

    test('subject includes issue type', () {
      final uri = buildFeedbackEmailUri(
        name: 'Alice',
        email: 'alice@example.com',
        issueType: 'Feature request',
        description: 'Dark mode please',
        improvement: '',
        metadata: _meta,
      );

      expect(uri.queryParameters['subject'], 'DPD App Feedback: Feature request');
    });

    test('body contains all required headings and values', () {
      final uri = buildFeedbackEmailUri(
        name: 'Bob',
        email: 'bob@example.com',
        issueType: 'Display problem',
        description: 'Text is clipped',
        improvement: 'Larger font option',
        metadata: _meta,
      );

      final body = uri.queryParameters['body']!;
      expect(body, contains('Name: Bob'));
      expect(body, contains('Email: bob@example.com'));
      expect(body, contains('Issue Type: Display problem'));
      expect(body, contains('Description: Text is clipped'));
      expect(body, contains('Improvement: Larger font option'));
      expect(body, contains('Platform: Android'));
      expect(body, contains('Device: Pixel 9'));
      expect(body, contains('OS Version: Android 15'));
      expect(body, contains('App Version: 0.1.1'));
      expect(body, contains('Database Version: 2026-03-01'));
    });

    test('improvement line is omitted when empty', () {
      final uri = buildFeedbackEmailUri(
        name: 'Carol',
        email: 'carol@example.com',
        issueType: 'Other',
        description: 'Just a note',
        improvement: '',
        metadata: _meta,
      );

      final body = uri.queryParameters['body']!;
      expect(body, isNot(contains('Improvement:')));
    });

    test('null dbVersion renders as empty string in body', () {
      const metaNoDb = FeedbackMetadata(
        platform: 'iOS',
        deviceModel: 'iPhone 15',
        osVersion: 'iOS 17.4',
        appVersion: '0.1.1',
      );
      final uri = buildFeedbackEmailUri(
        name: 'Dave',
        email: 'dave@example.com',
        issueType: 'General feedback',
        description: 'Good app',
        improvement: '',
        metadata: metaNoDb,
      );

      final body = uri.queryParameters['body']!;
      expect(body, contains('Database Version: '));
    });
  });
}
