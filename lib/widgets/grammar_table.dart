import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../providers/internet_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/date_utils.dart';
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

    final hasInternet = ref.watch(hasInternetProvider).valueOrNull ?? true;

    final rows = [
      _buildLemmaRow(headword, n),
      _buildLemmaTradRow(headword, n),
      _buildLemmaIpaRow(headword, hasInternet),
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
          'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500=$encodedLemma&entry.326955045=Grammar&entry.1433863141=${dpdAppLabel()}',
    );
  }

  TableRow? _buildLemmaRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final lemma = headword.headword.lemmaClean;
    if (lemma.isEmpty) return null;
    return buildKvTextRow('Lemma', lemma, filter: n);
  }

  TableRow? _buildLemmaTradRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final lemmaTrad = headword.headword.lemmaTradClean;
    if (lemmaTrad.isEmpty) return null;
    if (lemmaTrad == headword.headword.lemmaClean) return null;
    return buildKvTextRow('Traditional Lemma', lemmaTrad, filter: n);
  }

  TableRow? _buildLemmaIpaRow(DpdHeadwordWithRoot headword, bool hasInternet) {
    final ipa = headword.headword.lemmaIpa;
    if (ipa == null || ipa.isEmpty) return null;
    return buildKvRow(
      'IPA',
      _IpaRowContent(ipa: ipa, lemma: headword.headword.lemma1, hasInternet: hasInternet),
    );
  }

  TableRow? _buildGrammarRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final grammar = headword.headword.grammarLine;
    if (grammar.isEmpty) return null;
    return buildKvTextRow('Grammar', grammar, filter: n);
  }

  TableRow? _buildFamilyRootRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvTextRow('Root Family', headword.familyRoot, filter: n);
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
    return buildKvTextRow('Root', details, filter: n);
  }

  TableRow? _buildRootInCompsRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final root = headword.root;
    if (root == null) return null;
    final inComps = root.rootInComps;
    if (inComps.isEmpty) return null;
    return buildKvTextRow('√ In Sandhi', inComps, filter: n);
  }

  TableRow? _buildBaseRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvTextRow('Base', headword.rootBase, filter: n);
  }

  TableRow? _buildConstructionRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvHtmlRow('Construction', headword.headword.cleanConstruction(), filter: n);
  }

  TableRow? _buildDerivativeRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final suffix = headword.suffix;
    if (suffix == null || suffix.isEmpty) return null;
    return buildKvTextRow('Derivative', '($suffix)', filter: n);
  }

  TableRow? _buildPhoneticRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvHtmlRow('Phonetic Change', headword.phonetic, filter: n);
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
    return buildKvHtmlRow('Compound', text, filter: n);
  }

  TableRow? _buildAntonymRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvTextRow('Antonym', headword.antonym, filter: n);
  }

  TableRow? _buildSynonymRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvTextRow('Synonym', headword.synonym, filter: n);
  }

  TableRow? _buildVariantRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvTextRow('Variant', headword.variant, filter: n);
  }

  TableRow? _buildCommentaryRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final commentary = headword.commentary;
    if (commentary == null || commentary.isEmpty || commentary == '-') {
      return null;
    }
    return buildKvHtmlRow('Commentary', commentary, filter: n);
  }

  TableRow? _buildNotesRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvHtmlRow('Notes', headword.notes, filter: n);
  }

  TableRow? _buildCognateRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    return buildKvTextRow('English Cognate', headword.cognate, filter: n);
  }

  TableRow? _buildLinkRow(DpdHeadwordWithRoot headword) {
    final link = headword.link;
    if (link == null || link.isEmpty) return null;
    return buildKvRow(
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
    return buildKvTextRow('Non IA', headword.nonIa, filter: n);
  }

  TableRow? _buildSanskritRow(DpdHeadwordWithRoot headword, String Function(String) n) {
    final sanskrit = headword.sanskrit;
    if (sanskrit == null || sanskrit.isEmpty) return null;
    return buildKvRow(
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
    return buildKvRow(
      'Sanskrit Root',
      Text(n(details), style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}

class _IpaRowContent extends StatelessWidget {
  const _IpaRowContent({
    required this.ipa,
    required this.lemma,
    required this.hasInternet,
  });

  final String ipa;
  final String lemma;
  final bool hasInternet;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text('/$ipa/'),
        if (hasInternet) ...[
          DpdPlayButton(lemma: lemma, gender: 'male1', compact: true),
          DpdPlayButton(lemma: lemma, gender: 'male2', compact: true),
          DpdPlayButton(lemma: lemma, gender: 'female1', compact: true),
        ],
      ],
    );
  }
}

