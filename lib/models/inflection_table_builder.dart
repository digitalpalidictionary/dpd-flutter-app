import 'dart:convert';

import 'inflection_table_data.dart';

// pos values that use "Declension" button label
const _declensionPos = {
  'adj',
  'card',
  'cs',
  'fem',
  'masc',
  'nt',
  'ordin',
  'pp',
  'pron',
  'prp',
  'ptp',
  'root',
  've',
  'letter',
};

// pos values that use "Conjugation" button label
const _conjugationPos = {
  'aor',
  'cond',
  'fut',
  'imp',
  'imperf',
  'opt',
  'perf',
  'pr',
};

/// Builds a structured [InflectionTableData] from raw headword and template data.
///
/// Returns null for indeclinables (stem == '-').
InflectionTableData? buildInflectionTable({
  required String? stem,
  required String? pattern,
  required String? pos,
  required String lemma1,
  required String? templateLike,
  required String templateData,
}) {
  if (stem == null || stem == '-') return null;

  final isIrregular = stem == '*';
  final cleanStem = isIrregular ? '' : stem.replaceAll(RegExp(r'^[!]'), '');

  final grid = jsonDecode(templateData) as List;

  final headerRow = grid[0] as List;
  final headers = <String>[''];
  for (int col = 1; col < headerRow.length; col += 2) {
    final cell = headerRow[col] as List;
    headers.add(cell.isNotEmpty ? cell[0] as String : '');
  }

  final rows = <(String, List<InflectionCell>)>[];
  for (int row = 1; row < grid.length; row++) {
    final rowData = grid[row] as List;
    final labelCell = rowData[0] as List;
    final rowLabel = labelCell.isNotEmpty ? labelCell[0] as String : '';

    final cells = <InflectionCell>[];
    for (int col = 1; col < rowData.length; col += 2) {
      final endingCell = rowData[col] as List;
      final tooltipCol = col + 1;
      String? tooltip;
      if (tooltipCol < rowData.length) {
        final tooltipCell = rowData[tooltipCol] as List;
        if (tooltipCell.isNotEmpty) {
          tooltip = tooltipCell[0] as String;
          if (tooltip.isEmpty) tooltip = null;
        }
      }

      final forms = <InflectionForm>[];
      for (final ending in endingCell) {
        final e = ending as String;
        if (e.isEmpty) continue;
        final word = isIrregular ? e : '$cleanStem$e';
        forms.add(InflectionForm(stem: cleanStem, ending: e, word: word));
      }
      cells.add(InflectionCell(forms: forms, grammarTooltip: tooltip));
    }

    rows.add((rowLabel, cells));
  }

  final buttonLabel = _conjugationPos.contains(pos)
      ? 'Conjugation'
      : _declensionPos.contains(pos)
      ? 'Declension'
      : 'Declension';

  final lemmaBase = lemma1.split(' ').first;
  final declLabel = buttonLabel == 'Conjugation' ? 'conjugation' : 'declension';
  final isLikeIrregular =
      isIrregular ||
      templateLike == null ||
      templateLike.isEmpty ||
      templateLike == 'irreg';

  return InflectionTableData(
    headers: headers,
    rows: rows,
    buttonLabel: buttonLabel,
    headingLemma: lemmaBase,
    headingPattern: pattern ?? '',
    headingDeclLabel: declLabel,
    headingLike: isLikeIrregular ? null : templateLike,
    headingIsIrregular: isLikeIrregular,
  );
}
