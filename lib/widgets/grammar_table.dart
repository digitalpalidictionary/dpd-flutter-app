import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';

class GrammarTable extends StatelessWidget {
  final DpdHeadwordWithRoot headword;

  const GrammarTable({super.key, required this.headword});

  static const Color _labelColor = Color(0xFF0895D7);

  @override
  Widget build(BuildContext context) {
    final rows = [
      _buildLemmaRow(headword),
      _buildLemmaTradRow(headword),
      _buildLemmaIpaRow(headword),
      _buildGrammarRow(headword),
      _buildFamilyRootRow(headword),
      _buildRootDetailsRow(headword),
      _buildRootInCompsRow(headword),
      _buildBaseRow(headword),
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
    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      padding: const EdgeInsets.only(top: 5.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _labelColor, width: 1)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => _launchMistakeForm(headword.lemma1),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12.8, color: Colors.grey),
              children: const [
                TextSpan(text: 'Did you spot a mistake? '),
                TextSpan(
                  text: 'Correct it here',
                  style: TextStyle(
                    color: _labelColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchMistakeForm(String lemma) async {
    final encodedLemma = Uri.encodeComponent(lemma);
    final url = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500=$encodedLemma&entry.326955045=Grammar',
    );
    try {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  TableRow _buildRow(String label, Widget content) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5.0, bottom: 2.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _labelColor,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 2.0), child: content),
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
    return _buildTextRow('Lemma', lemma);
  }

  TableRow? _buildLemmaTradRow(DpdHeadwordWithRoot headword) {
    final lemmaTrad = headword.headword.lemmaTradClean;
    if (lemmaTrad.isEmpty) return null;
    return _buildTextRow('Traditional Lemma', lemmaTrad);
  }

  TableRow? _buildLemmaIpaRow(DpdHeadwordWithRoot headword) {
    // PLACEHOLDER: awaiting IPA conversion implementation
    const ipa = '';
    return _buildRow(
      'IPA',
      Row(
        children: [
          Text(ipa.isEmpty ? '—' : '/$ipa/'),
          const SizedBox(width: 8),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, size: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  TableRow? _buildGrammarRow(DpdHeadwordWithRoot headword) {
    final grammar = headword.headword.grammarLine;
    if (grammar.isEmpty) return null;
    return _buildTextRow('Grammar', grammar);
  }

  TableRow? _buildFamilyRootRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('Root Family', headword.familyRoot);
  }

  TableRow? _buildRootDetailsRow(DpdHeadwordWithRoot headword) {
    final root = headword.root;
    if (root == null) return null;
    final parts = [
      if (root.root.isNotEmpty) root.root,
      if (root.rootGroup != null) root.rootGroup.toString(),
      if (root.rootSign != null && root.rootSign!.isNotEmpty) root.rootSign,
      if (root.rootMeaning != null && root.rootMeaning!.isNotEmpty)
        '(${root.rootMeaning})',
    ];
    final details = parts.join(' ').trim();
    if (details.isEmpty) return null;
    return _buildTextRow('Root', details);
  }

  TableRow? _buildRootInCompsRow(DpdHeadwordWithRoot headword) {
    final root = headword.root;
    if (root == null) return null;
    final inComps = root.rootInComps;
    if (inComps == null || inComps.isEmpty) return null;
    return _buildTextRow('√ In Sandhi', inComps);
  }

  TableRow? _buildBaseRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('Base', headword.rootBase);
  }

  TableRow? _buildConstructionRow(DpdHeadwordWithRoot headword) {
    return _buildHtmlRow('Construction', headword.headword.cleanConstruction());
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
    return _buildTextRow('Derivative', text);
  }

  TableRow? _buildPhoneticRow(DpdHeadwordWithRoot headword) {
    return _buildHtmlRow('Phonetic Change', headword.phonetic);
  }

  TableRow? _buildCompoundRow(DpdHeadwordWithRoot headword) {
    final type = headword.compoundType;
    final construction = headword.compoundConstruction;
    if ((type == null || type.isEmpty) &&
        (construction == null || construction.isEmpty)) {
      return null;
    }
    if (type != null && type.contains('?')) return null;
    final text = [
      if (type != null && type.isNotEmpty) type,
      if (construction != null && construction.isNotEmpty) '($construction)',
    ].join(' ').trim();
    return _buildHtmlRow('Compound', text);
  }

  TableRow? _buildAntonymRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('Antonym', headword.antonym);
  }

  TableRow? _buildSynonymRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('Synonym', headword.synonym);
  }

  TableRow? _buildVariantRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('Variant', headword.variant);
  }

  TableRow? _buildCommentaryRow(DpdHeadwordWithRoot headword) {
    final commentary = headword.commentary;
    if (commentary == null || commentary.isEmpty || commentary == '-')
      return null;
    return _buildHtmlRow('Commentary', commentary);
  }

  TableRow? _buildNotesRow(DpdHeadwordWithRoot headword) {
    return _buildHtmlRow('Notes', headword.notes);
  }

  TableRow? _buildCognateRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('English Cognate', headword.cognate);
  }

  TableRow? _buildLinkRow(DpdHeadwordWithRoot headword) {
    final link = headword.link;
    if (link == null || link.isEmpty) return null;
    return _buildRow(
      'Web Link',
      Html(
        data: '<a href="$link" target="_blank">$link</a>',
        style: {
          "a": Style(
            color: Colors.blue,
            textDecoration: TextDecoration.underline,
          ),
        },
      ),
    );
  }

  TableRow? _buildNonIaRow(DpdHeadwordWithRoot headword) {
    return _buildTextRow('Non IA', headword.nonIa);
  }

  TableRow? _buildSanskritRow(DpdHeadwordWithRoot headword) {
    final sanskrit = headword.sanskrit;
    if (sanskrit == null || sanskrit.isEmpty) return null;
    return _buildRow(
      'Sanskrit',
      Text(sanskrit, style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }

  TableRow? _buildSanskritRootDetailsRow(DpdHeadwordWithRoot headword) {
    final root = headword.root;
    if (root == null) return null;
    final sr = root.sanskritRoot;
    if (sr == null || sr.isEmpty || sr == '-') return null;
    final parts = [
      sr,
      if (root.sanskritRootClass != null && root.sanskritRootClass!.isNotEmpty)
        root.sanskritRootClass,
      if (root.sanskritRootMeaning != null &&
          root.sanskritRootMeaning!.isNotEmpty)
        '(${root.sanskritRootMeaning})',
    ];
    final details = parts.join(' ').trim();
    if (details.isEmpty) return null;
    return _buildRow(
      'Sanskrit Root',
      Text(details, style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}
