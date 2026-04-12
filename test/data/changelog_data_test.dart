import 'package:dpd_flutter_app/data/changelog_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildChangelogData', () {
    test('groups unreleased before tags and filters chore commits', () {
      final changelog = buildChangelogData(
        unreleasedSubjects: const [
          'feat: add change log entry',
          'chore: update docs',
        ],
        orderedTags: const ['v0.1.1', 'v0.1.0'],
        subjectsByTag: const {
          'v0.1.1': ['fix: polish info popup', 'chore: tidy justfile'],
          'v0.1.0': ['feat: initial release'],
        },
      );

      expect(changelog.sections.length, 3);
      expect(changelog.sections[0].title, 'unreleased');
      expect(changelog.sections[0].items, ['feat: add change log entry']);
      expect(changelog.sections[1].title, 'v0.1.1');
      expect(changelog.sections[1].items, ['fix: polish info popup']);
      expect(changelog.sections[2].title, 'v0.1.0');
      expect(changelog.sections[2].items, ['feat: initial release']);
    });

    test('omits empty unreleased and empty tags', () {
      final changelog = buildChangelogData(
        unreleasedSubjects: const ['chore: release prep'],
        orderedTags: const ['v0.1.0'],
        subjectsByTag: const {
          'v0.1.0': ['chore: bootstrap'],
        },
      );

      expect(changelog.sections, isEmpty);
    });

    test('round trips JSON data', () {
      final original = buildChangelogData(
        unreleasedSubjects: const ['fix: keep release notes local'],
        orderedTags: const ['v0.1.0'],
        subjectsByTag: const {
          'v0.1.0': ['feat: first shipped version'],
        },
      );

      final decoded = ChangelogData.fromJsonString(original.toPrettyJson());

      expect(decoded.sections.length, 2);
      expect(decoded.sections[0].title, 'unreleased');
      expect(decoded.sections[0].items, ['fix: keep release notes local']);
      expect(decoded.sections[1].title, 'v0.1.0');
      expect(decoded.sections[1].items, ['feat: first shipped version']);
    });

    test('uses provided head tag instead of unreleased', () {
      final changelog = buildChangelogData(
        unreleasedSubjects: const [
          'fix: package the release changelog correctly',
        ],
        orderedTags: const ['v0.1.0'],
        subjectsByTag: const {
          'v0.1.0': ['feat: first shipped version'],
        },
        headSectionTitle: 'v0.1.1',
      );

      expect(changelog.sections.length, 2);
      expect(changelog.sections.first.title, 'v0.1.1');
      expect(changelog.sections.first.items, [
        'fix: package the release changelog correctly',
      ]);
    });
  });
}
