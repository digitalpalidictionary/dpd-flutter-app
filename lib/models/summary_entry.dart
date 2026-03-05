enum SummaryEntryType {
  headword,
  root,
  see,
  grammar,
  spelling,
  variant,
  abbreviation,
  epd,
  help,
  deconstructor,
}

class SummaryEntry {
  final SummaryEntryType type;
  final String label;
  final String typeLabel;
  final String meaning;
  final String targetId;

  const SummaryEntry({
    required this.type,
    required this.label,
    required this.typeLabel,
    required this.meaning,
    required this.targetId,
  });
}
