import 'package:flutter/material.dart';

import '../database/database.dart';
import '../theme/dpd_colors.dart';

const Map<int, String> _rootGroupPali = {
  1: 'bhūvādigaṇa',
  2: 'rudhādigaṇa',
  3: 'divādigaṇa',
  4: 'svādigaṇa',
  5: 'kiyādigaṇa',
  6: 'gahādigaṇa',
  7: 'tanādigaṇa',
  8: 'curādigaṇa',
};

class RootInfoTable extends StatelessWidget {
  const RootInfoTable({super.key, required this.root, this.bases});

  final DpdRoot root;
  final List<String>? bases;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: DpdColors.primaryText,
      fontWeight: FontWeight.w700,
    );
    final valueStyle = theme.textTheme.bodyMedium;
    final grayStyle = valueStyle?.copyWith(color: Colors.grey);
    final italicStyle = valueStyle?.copyWith(fontStyle: FontStyle.italic);

    final rows = <TableRow>[];

    // Pāḷi Root
    final rootClean = root.root.replaceAll('√', '');
    final groupPali = _rootGroupPali[root.rootGroup] ?? '';
    rows.add(
      _buildRichRow(
        label: 'Pāḷi Root:',
        labelStyle: labelStyle,
        child: Text.rich(
          TextSpan(
            style: valueStyle,
            children: [
              TextSpan(text: rootClean),
              if (root.rootHasVerb.isNotEmpty)
                TextSpan(
                  text: root.rootHasVerb,
                  style: valueStyle?.copyWith(
                    fontSize: (valueStyle.fontSize ?? 14) * 0.7,
                    fontFeatures: [const FontFeature.superscripts()],
                  ),
                ),
              TextSpan(
                text: ' ${root.rootGroup} $groupPali + ${root.rootSign}',
              ),
              TextSpan(text: ' (${root.rootMeaning})'),
            ],
          ),
        ),
      ),
    );

    // Base(s)
    final b = bases;
    final basesLabel = (b != null && b.length > 1) ? 'Bases:' : 'Base:';
    final basesValue = b == null ? '…' : (b.isEmpty ? '-' : b.join(', '));
    rows.add(_buildTextRow(basesLabel, basesValue, labelStyle, valueStyle));

    // Root in Compounds (optional)
    if (root.rootInComps.isNotEmpty) {
      rows.add(
        _buildTextRow(
          'Root in Compounds:',
          root.rootInComps,
          labelStyle,
          valueStyle,
        ),
      );
    }

    // Dhātupātha
    if (root.dhatupathaRoot != '-') {
      rows.add(
        _buildRichRow(
          label: 'Dhātupātha:',
          labelStyle: labelStyle,
          child: Text.rich(
            TextSpan(
              style: valueStyle,
              children: [
                TextSpan(text: '${root.dhatupathaRoot} '),
                TextSpan(text: root.dhatupathaPali, style: italicStyle),
                TextSpan(
                  text: ' (${root.dhatupathaEnglish}) #${root.dhatupathaNum}',
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      rows.add(_buildTextRow('Dhātupātha:', '-', labelStyle, valueStyle));
    }

    // Dhātumañjūsa
    if (root.dhatumanjusaRoot != '-') {
      rows.add(
        _buildRichRow(
          label: 'Dhātumañjūsa:',
          labelStyle: labelStyle,
          child: Text.rich(
            TextSpan(
              style: valueStyle,
              children: [
                TextSpan(text: '${root.dhatumanjusaRoot} '),
                TextSpan(text: root.dhatumanjusaPali, style: italicStyle),
                TextSpan(
                  text:
                      ' (${root.dhatumanjusaEnglish}) #${root.dhatumanjusaNum}',
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      rows.add(_buildTextRow('Dhātumañjūsa:', '-', labelStyle, valueStyle));
    }

    // Saddanīti
    if (root.dhatumalaRoot != '-') {
      rows.add(
        _buildRichRow(
          label: 'Saddanīti:',
          labelStyle: labelStyle,
          child: Text.rich(
            TextSpan(
              style: valueStyle,
              children: [
                TextSpan(text: '${root.dhatumalaRoot} '),
                TextSpan(text: root.dhatumalaPali, style: italicStyle),
                TextSpan(text: ' (${root.dhatumalaEnglish})'),
              ],
            ),
          ),
        ),
      );
    } else {
      rows.add(_buildTextRow('Saddanīti:', '-', labelStyle, valueStyle));
    }

    // Sanskrit Root (gray)
    rows.add(
      _buildRichRow(
        label: 'Sanskrit Root:',
        labelStyle: labelStyle,
        child: Text(
          '${root.sanskritRoot} ${root.sanskritRootClass} (${root.sanskritRootMeaning})',
          style: grayStyle,
        ),
      ),
    );

    // Pāṇinīya Dhātupāṭha (gray or "-")
    if (root.paniniRoot != '-') {
      rows.add(
        _buildRichRow(
          label: 'Pāṇinīya Dhātupāṭha:',
          labelStyle: labelStyle,
          child: Text.rich(
            TextSpan(
              style: grayStyle,
              children: [
                TextSpan(text: '${root.paniniRoot} '),
                TextSpan(
                  text: root.paniniSanskrit,
                  style: grayStyle?.copyWith(fontStyle: FontStyle.italic),
                ),
                TextSpan(text: ' (${root.paniniEnglish})'),
              ],
            ),
          ),
        ),
      );
    } else {
      rows.add(
        _buildTextRow('Pāṇinīya Dhātupāṭha:', '-', labelStyle, valueStyle),
      );
    }

    // Notes (optional)
    if (root.note.isNotEmpty) {
      rows.add(_buildTextRow('Notes:', root.note, labelStyle, valueStyle));
    }

    return Padding(
      padding: DpdColors.sectionPadding,
      child: Table(
        columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
        defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: rows,
      ),
    );
  }

  TableRow _buildTextRow(
    String label,
    String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
          child: Text(label, style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Text(value, style: valueStyle),
        ),
      ],
    );
  }

  TableRow _buildRichRow({
    required String label,
    required TextStyle? labelStyle,
    required Widget child,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
          child: Text(label, style: labelStyle),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: child,
        ),
      ],
    );
  }
}
