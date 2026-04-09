import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dpd_flutter_app/services/feedback_draft_service.dart';

void main() {
  group('FeedbackDraftService', () {
    late FeedbackDraftService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = FeedbackDraftService(prefs);
    });

    test('load returns empty draft when nothing saved', () {
      final draft = service.load();
      expect(draft.name, '');
      expect(draft.email, '');
      expect(draft.issueType, '');
      expect(draft.description, '');
      expect(draft.improvement, '');
    });

    test('save and restore all fields', () async {
      const original = FeedbackDraft(
        name: 'Alice',
        email: 'alice@example.com',
        issueType: 'App crash or freeze',
        description: 'It crashed when I opened the app',
        improvement: 'Please fix it',
      );
      await service.save(original);

      final restored = service.load();
      expect(restored.name, 'Alice');
      expect(restored.email, 'alice@example.com');
      expect(restored.issueType, 'App crash or freeze');
      expect(restored.description, 'It crashed when I opened the app');
      expect(restored.improvement, 'Please fix it');
    });

    test('clearTransientDraft removes transient fields but preserves name and email', () async {
      const original = FeedbackDraft(
        name: 'Bob',
        email: 'bob@example.com',
        issueType: 'Feature request',
        description: 'Would love dark mode',
        improvement: 'More themes',
      );
      await service.save(original);
      await service.clearTransientDraft();

      final restored = service.load();
      expect(restored.name, 'Bob');
      expect(restored.email, 'bob@example.com');
      expect(restored.issueType, '');
      expect(restored.description, '');
      expect(restored.improvement, '');
    });

    test('load with partial prefs returns defaults for missing keys', () async {
      SharedPreferences.setMockInitialValues({
        'feedback_contact.name': 'Charlie',
      });
      final prefs = await SharedPreferences.getInstance();
      final partialService = FeedbackDraftService(prefs);

      final draft = partialService.load();
      expect(draft.name, 'Charlie');
      expect(draft.email, '');
      expect(draft.issueType, '');
    });
  });
}
