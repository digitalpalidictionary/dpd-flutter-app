/// A single inflected word form: stem + ending = word.
class InflectionForm {
  const InflectionForm({
    required this.stem,
    required this.ending,
    required this.word,
  });

  final String stem;
  final String ending;
  final String word;
}

/// One cell in the inflection table: zero or more forms, optional grammar tooltip.
class InflectionCell {
  const InflectionCell({required this.forms, this.grammarTooltip});

  final List<InflectionForm> forms;
  final String? grammarTooltip;

  bool get isEmpty => forms.isEmpty;
}

/// Fully parsed inflection table ready for rendering.
class InflectionTableData {
  const InflectionTableData({
    required this.headers,
    required this.rows,
    required this.headingText,
    required this.buttonLabel,
  });

  /// Column header labels (e.g. ["", "singular", "plural"]).
  final List<String> headers;

  /// Each row is a tuple of (rowLabel, cells) — one cell per column header (excluding label col).
  final List<(String, List<InflectionCell>)> rows;

  /// Heading displayed above the table.
  final String headingText;

  /// Button label: "Declension" or "Conjugation".
  final String buttonLabel;
}
