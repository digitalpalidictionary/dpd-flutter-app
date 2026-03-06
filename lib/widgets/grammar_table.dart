import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/text_filters.dart';
import 'entry_content.dart';

class GrammarTable extends ConsumerWidget {
  final DpdHeadwordWithRoot headword;

  const GrammarTable({super.key, required this.headword});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final niggahitaMode = ref.watch(
      settingsProvider.select((s) => s.niggahitaMode),
    );
    final showApostrophe = ref.watch(
      settingsProvider.select((s) => s.showSandhiApostrophe),
    );
    final filterMode = NiggahitaFilterMode.values[niggahitaMode.index];
    String n(String t) => filterNiggahita(
      filterApostrophe(t, show: showApostrophe),
      mode: filterMode,
    );

    final rows = [
      _buildLemmaRow(headword, n),
      _buildLemmaTradRow(headword, n),
      _buildLemmaIpaRow(headword),
      _buildGrammarRow(headword, n),
      _buildFamilyRootRow(headword, n),
      _buildRootDetailsRow(headword, n),
      _buildRootInCompsRow(headword, n),
      _buildBaseRow(headword, n),
      _buildConstructionRow(headword, n),
      _buildDerivativeRow(headword, n),
      _buildPhoneticRow(headword, n),
      _buildCompoundRow(headword, n),
      _buildAntonymRow(headword, n),
      _buildSynonymRow(headword, n),
      _buildVariantRow(headword, n),
      _buildCommentaryRow(headword, n),
      _buildNotesRow(headword, n),
      _buildCognateRow(headword, n),
      _buildLinkRow(headword),
      _buildNonIaRow(headword, n),
      _buildSanskritRow(headword, n),
      _buildSanskritRootDetailsRow(headword, n),
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
    final encodedLemma = Uri.encodeComponent(headword.lemma1);
    return DpdFooter(
      messagePrefix: 'Did you spot a mistake?',
      linkText: 'Correct it here',
      urlBuilder: () =>
          'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500=$encodedLemma&entry.326955045=Grammar',
    );
  }

  TableRow _buildRow(String label, Widget content) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5.0, bottom: 2.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: DpdColors.primaryText,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 2.0), child: content),
      ],
    );
  }

  TableRow? _buildTextRow(String label, String? text, [String Function(String)? f]) {
    if (text == null || text.isEmpty) return null;
    final display = f != null ? f(text) : text;
    return _buildRow(label, Text(display));
  }

  TableRow? _buildHtmlRow(String label, String? htmlData, [String Function(String)? f]) {
    if (htmlData == null || htmlData.isEmpty) return null;
    final data = f != null ? f(htmlData) : htmlData;
    return _buildRow(
      label,
      Html(
        data: data,
        style: {
          "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        },
      ),
    );
  }

  TableRow? _buildLemmaRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final lemma = headword.headword.lemmaClean;
    if (lemma.isEmpty) return null;
    return _buildTextRow('Lemma', lemma, n);
  }

  TableRow? _buildLemmaTradRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final lemmaTrad = headword.headword.lemmaTradClean;
    if (lemmaTrad.isEmpty) return null;
    return _buildTextRow('Traditional Lemma', lemmaTrad, n);
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

  TableRow? _buildGrammarRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final grammar = headword.headword.grammarLine;
    if (grammar.isEmpty) return null;
    return _buildTextRow('Grammar', grammar, n);
  }

  TableRow? _buildFamilyRootRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildTextRow('Root Family', headword.familyRoot, n);
  }

  TableRow? _buildRootDetailsRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final root = headword.root;
    if (root == null) return null;
    final parts = [
      if (root.root.isNotEmpty) root.root,
      root.rootGroup.toString(),
      if (root.rootSign.isNotEmpty) root.rootSign,
      if (root.rootMeaning.isNotEmpty) '(${root.rootMeaning})',
    ];
    final details = parts.join(' ').trim();
    if (details.isEmpty) return null;
    return _buildTextRow('Root', details, n);
  }

  TableRow? _buildRootInCompsRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final root = headword.root;
    if (root == null) return null;
    final inComps = root.rootInComps;
    if (inComps.isEmpty) return null;
    return _buildTextRow('√ In Sandhi', inComps, n);
  }

  TableRow? _buildBaseRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildTextRow('Base', headword.rootBase, n);
  }

  TableRow? _buildConstructionRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildHtmlRow('Construction', headword.headword.cleanConstruction(), n);
  }

  TableRow? _buildDerivativeRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final suffix = headword.suffix;
    if (suffix == null || suffix.isEmpty) return null;
    return _buildTextRow('Derivative', '($suffix)', n);
  }

  TableRow? _buildPhoneticRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildHtmlRow('Phonetic Change', headword.phonetic, n);
  }

  TableRow? _buildCompoundRow(DpdHeadwordWithRoot headword, String Function(String) n) {
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
    return _buildHtmlRow('Compound', text, n);
  }

  TableRow? _buildAntonymRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildTextRow('Antonym', headword.antonym, n);
  }

  TableRow? _buildSynonymRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildTextRow('Synonym', headword.synonym, n);
  }

  TableRow? _buildVariantRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildTextRow('Variant', headword.variant, n);
  }

  TableRow? _buildCommentaryRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final commentary = headword.commentary;
    if (commentary == null || commentary.isEmpty || commentary == '-') {
      return null;
    }
    return _buildHtmlRow('Commentary', commentary, n);
  }

  TableRow? _buildNotesRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildHtmlRow('Notes', headword.notes, n);
  }

  TableRow? _buildCognateRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildTextRow('English Cognate', headword.cognate, n);
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

  TableRow? _buildNonIaRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return _buildTextRow('Non IA', headword.nonIa, n);
  }

  TableRow? _buildSanskritRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final sanskrit = headword.sanskrit;
    if (sanskrit == null || sanskrit.isEmpty) return null;
    return _buildRow(
      'Sanskrit',
      Text(n(sanskrit), style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }

  TableRow? _buildSanskritRootDetailsRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final root = headword.root;
    if (root == null) return null;
    final sr = root.sanskritRoot;
    if (sr.isEmpty || sr == '-') return null;
    final parts = [
      sr,
      if (root.sanskritRootClass.isNotEmpty) root.sanskritRootClass,
      if (root.sanskritRootMeaning.isNotEmpty) '(${root.sanskritRootMeaning})',
    ];
    final details = parts.join(' ').trim();
    if (details.isEmpty) return null;
    return _buildRow(
      'Sanskrit Root',
      Text(n(details), style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}
