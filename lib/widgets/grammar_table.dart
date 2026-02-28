import 'package:flutter/material.dart';

import '../database/database.dart';

class GrammarTable extends StatelessWidget {
  final DpdHeadwordWithRoot headword;

  const GrammarTable({super.key, required this.headword});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _buildLemmaRow(headword),
      _buildGrammarRow(headword),
    ].whereType<TableRow>().toList();

    return Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      children: rows,
    );
  }

  TableRow? _buildLemmaRow(DpdHeadwordWithRoot headword) {
    final lemma = headword.lemma1;
    if (lemma.isEmpty) return null;
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
          child: Text('lemma', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(lemma),
        ),
      ],
    );
  }

  TableRow? _buildGrammarRow(DpdHeadwordWithRoot headword) {
    final grammar = headword.grammar;
    if (grammar == null || grammar.isEmpty) return null;
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
          child: Text('grammar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(grammar),
        ),
      ],
    );
  }
}
