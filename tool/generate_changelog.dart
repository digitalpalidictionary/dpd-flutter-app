import 'dart:io';

import 'package:dpd_flutter_app/data/changelog_data.dart';

Future<void> main(List<String> args) async {
  final headTag = _parseHeadTag(args);
  final tags = await _gitLines(['tag', '--sort=-creatordate']);
  final newestToOldestTags = tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  final unreleasedSubjects = newestToOldestTags.isEmpty
      ? await _gitCommitSubjects(['log', '--format=%s'])
      : await _gitCommitSubjects([
          'log',
          '--format=%s',
          '${newestToOldestTags.first}..HEAD',
        ]);

  final subjectsByTag = <String, List<String>>{};
  for (var i = 0; i < newestToOldestTags.length; i++) {
    final tag = newestToOldestTags[i];
    final range = i + 1 < newestToOldestTags.length
        ? ['log', '--format=%s', '${newestToOldestTags[i + 1]}..$tag']
        : ['log', '--format=%s', tag];
    subjectsByTag[tag] = await _gitCommitSubjects(range);
  }

  final changelog = buildChangelogData(
    unreleasedSubjects: unreleasedSubjects,
    orderedTags: newestToOldestTags,
    subjectsByTag: subjectsByTag,
    headSectionTitle: headTag,
  );

  final outputFile = File('assets/help/changelog.json');
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(changelog.toPrettyJson());
}

String? _parseHeadTag(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--head-tag=')) {
      final value = arg.substring('--head-tag='.length).trim();
      return value.isEmpty ? null : value;
    }
  }
  return null;
}

Future<List<String>> _gitCommitSubjects(List<String> args) async {
  return _gitLines(args);
}

Future<List<String>> _gitLines(List<String> args) async {
  final result = await Process.run('git', args);
  if (result.exitCode != 0) {
    final error = result.stderr?.toString() ?? '';
    stderr.write(error);
    throw ProcessException('git', args, error, result.exitCode);
  }

  return (result.stdout as String)
      .split('\n')
      .map((line) => line.trimRight())
      .where((line) => line.isNotEmpty)
      .toList();
}
