import 'dart:convert';

class ChangelogSection {
  final String title;
  final List<String> items;

  const ChangelogSection({required this.title, required this.items});

  Map<String, Object?> toJson() => {'title': title, 'items': items};

  factory ChangelogSection.fromJson(Map<String, dynamic> json) {
    return ChangelogSection(
      title: (json['title'] as String?) ?? '',
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

class ChangelogData {
  final List<ChangelogSection> sections;

  const ChangelogData({required this.sections});

  Map<String, Object?> toJson() => {
    'sections': sections.map((section) => section.toJson()).toList(),
  };

  String toPrettyJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return '${encoder.convert(toJson())}\n';
  }

  factory ChangelogData.fromJson(Map<String, dynamic> json) {
    return ChangelogData(
      sections: ((json['sections'] as List<dynamic>?) ?? const [])
          .whereType<Map>()
          .map(
            (section) =>
                ChangelogSection.fromJson(Map<String, dynamic>.from(section)),
          )
          .toList(),
    );
  }

  factory ChangelogData.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      return const ChangelogData(sections: []);
    }
    return ChangelogData.fromJson(decoded);
  }
}

List<String> filterChangelogItems(Iterable<String> subjects) {
  return subjects
      .map((subject) => subject.trim())
      .where((subject) => subject.isNotEmpty)
      .where((subject) => !subject.startsWith('chore:'))
      .where((subject) => !subject.startsWith('conductor:'))
      .where((subject) => !subject.startsWith('kamma:'))
      .toList();
}

ChangelogData buildChangelogData({
  required List<String> unreleasedSubjects,
  required List<String> orderedTags,
  required Map<String, List<String>> subjectsByTag,
  String? headSectionTitle,
}) {
  final sections = <ChangelogSection>[];

  final unreleasedItems = filterChangelogItems(unreleasedSubjects);
  if (unreleasedItems.isNotEmpty) {
    sections.add(
      ChangelogSection(
        title: headSectionTitle?.trim().isNotEmpty == true
            ? headSectionTitle!.trim()
            : 'unreleased',
        items: unreleasedItems,
      ),
    );
  }

  for (final tag in orderedTags) {
    final items = filterChangelogItems(subjectsByTag[tag] ?? const []);
    if (items.isEmpty) continue;
    sections.add(ChangelogSection(title: tag, items: items));
  }

  return ChangelogData(sections: sections);
}
