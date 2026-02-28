import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';

class GrammarTable extends StatelessWidget {
  final DpdHeadwordWithRoot headword;

  const GrammarTable({super.key, required this.headword});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _buildLemmaRow(headword),
      _buildLemmaTradRow(headword),
      _buildLemmaIpaRow(headword),
      _buildGrammarRow(headword),
      _buildFamilyRootRow(headword),
      _buildRootDetailsRow(headword),
      _buildConstructionRow(headword),
      _buildDerivativeRow(headword),
      _buildPhoneticRow(headword),
      _buildCompoundRow(headword),
      _buildAntonymRow(headword),
      _buildSynonymRow(headword),
      _buildVariantRow(headword),
      _buildCommentaryRow(headword),
      _buildNotesRow(headword),
      _buildCognateRow(headword),
      _buildLinkRow(headword),
      _buildNonIaRow(headword),
      _buildSanskritRow(headword),
      _buildSanskritRootDetailsRow(headword),
    ].whereType<TableRow>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          children: rows,
        ),
        const SizedBox(height: 16.0),
        _buildFooter(context, headword),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, DpdHeadwordWithRoot headword) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Center(
        child: InkWell(
          onTap: () => _launchMistakeForm(headword.lemma1),
          child: const Text(
            'Did you spot a mistake?',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchMistakeForm(String lemma) async {
    final encodedLemma = Uri.encodeComponent(lemma);
    final url = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHRhqXPoaHNxgCE-jCpCGKsqISI761/viewform?usp=pp_url&entry.438735500=$encodedLemma',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  TableRow _buildRow(String label, Widget content) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 4.0), child: content),
      ],
    );
  }

  TableRow? _buildTextRow(String label, String? text) {
    if (text == null || text.isEmpty) return null;
    return _buildRow(label, Text(text));
  }

  TableRow? _buildHtmlRow(String label, String? htmlData) {
    if (htmlData == null || htmlData.isEmpty) return null;
    return _buildRow(
      label,
      Html(
        data: htmlData,
        style: {
          "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        },
      ),
    );
  }

  TableRow? _buildLemmaRow(DpdHeadwordWithRoot headword) {
    final lemma = headword.headword.lemmaClean;
    if (lemma.isEmpty) return null;
    return _buildTextRow('lemma', lemma);
  }

  TableRow? _buildLemmaTradRow(DpdHeadwordWithRoot headword) {
    final lemmaTrad = headword.headword.lemmaTradClean;
    if (lemmaTrad.isEmpty) return null;
    return _buildTextRow('traditional lemma', lemmaTrad);
  }

  TableRow? _buildLemmaIpaRow(DpdHeadwordWithRoot headword) {
    final ipa = headword.headword.lemmaIpa;
    if (ipa.isEmpty) return null;
    return _buildRow(
      'ipa',
      Row(
        children: [
          Text('/$ipa/'),
          const SizedBox(width: 8),
          const Icon(Icons.volume_up, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  TableRow? _buildGrammarRow(DpdHeadwordWithRoot headword) {
    final grammar = headword.headword.grammarLine;
    if (grammar.isEmpty) return null;
    return _buildTextRow('grammar', grammar);
  }

  TableRow? _buildFamilyRootRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('family root', headword.familyRoot);
  }

  TableRow? _buildRootDetailsRow(DpdHeadwordWithRoot headword) {
    final root = headword.root;
    if (root == null) return null;
    final parts = [
      if (root.root.isNotEmpty) '√ ${root.root}',
      if (root.rootGroup != null) root.rootGroup.toString(),
      if (root.rootSign != null && root.rootSign!.isNotEmpty) root.rootSign,
      if (root.rootMeaning != null && root.rootMeaning!.isNotEmpty)
        '(${root.rootMeaning})',
    ];
    final details = parts.join(' ').trim();
    if (details.isEmpty) return null;
    return _buildTextRow('root', details);
  }

  TableRow? _buildConstructionRow(DpdHeadwordWithRoot headword) {
    return _buildHtmlRow('construction', headword.headword.cleanConstruction());
  }

  TableRow? _buildDerivativeRow(DpdHeadwordWithRoot headword) {
    final derivative = headword.derivative;
    final suffix = headword.suffix;
    if ((derivative == null || derivative.isEmpty) &&
        (suffix == null || suffix.isEmpty)) {
      return null;
    }
    final text = [
      if (derivative != null && derivative.isNotEmpty) derivative,
      if (suffix != null && suffix.isNotEmpty) '($suffix)',
    ].join(' ').trim();
    return _buildTextRow('derivative', text);
  }

  TableRow? _buildPhoneticRow(DpdHeadwordWithRoot headword) {
    return _buildHtmlRow('phonetic', headword.phonetic);
  }

  TableRow? _buildCompoundRow(DpdHeadwordWithRoot headword) {
    final type = headword.compoundType;
    final construction = headword.compoundConstruction;
    if ((type == null || type.isEmpty) &&
        (construction == null || construction.isEmpty)) {
      return null;
    }
    final text = [
      if (type != null && type.isNotEmpty) type,
      if (construction != null && construction.isNotEmpty) '($construction)',
    ].join(' ').trim();
    return _buildHtmlRow('compound', text);
  }

  TableRow? _buildAntonymRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('antonym', headword.antonym);
  }

  TableRow? _buildSynonymRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('synonym', headword.synonym);
  }

  TableRow? _buildVariantRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('variant', headword.variant);
  }

  TableRow? _buildCommentaryRow(DpdHeadwordWithRoot headword) {
    return _buildHtmlRow('commentary', headword.commentary);
  }

  TableRow? _buildNotesRow(DpdHeadwordWithRoot headword) {
    return _buildHtmlRow('notes', headword.notes);
  }

  TableRow? _buildCognateRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('cognate', headword.cognate);
  }

  TableRow? _buildLinkRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('link', headword.link);
  }

  TableRow? _buildNonIaRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('non ia', headword.nonIa);
  }

  TableRow? _buildSanskritRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('sanskrit', headword.sanskrit);
  }

  TableRow? _buildSanskritRootDetailsRow(DpdHeadwordWithRoot headword) {
    final root = headword.root;
    if (root == null) return null;
    final parts = [
      if (root.sanskritRoot != null && root.sanskritRoot!.isNotEmpty)
        '√ ${root.sanskritRoot}',
      if (root.sanskritRootClass != null && root.sanskritRootClass!.isNotEmpty)
        root.sanskritRootClass,
      if (root.sanskritRootMeaning != null &&
          root.sanskritRootMeaning!.isNotEmpty)
        '(${root.sanskritRootMeaning})',
    ];
    final details = parts.join(' ').trim();
    if (details.isEmpty) return null;
    return _buildTextRow('sanskrit root', details);
  }
}
