import 'package:flutter/material.dart';

import '../database/database.dart';
import 'family_table.dart';

const String _feedbackFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url';

// ── Header builders ──────────────────────────────────────────────────────────
// Each builder returns a RichText with only count and name bolded,
// matching the webapp's <b>count</b> text <b>name</b> pattern.

Widget _richHeader(
  BuildContext context,
  List<InlineSpan> spans, {
  VoidCallback? onJumpTop,
}) {
  final base = Theme.of(context).textTheme.bodyMedium;
  return RichText(
    text: TextSpan(
      style: base,
      children: [
        ...spans,
        if (onJumpTop != null)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: onJumpTop,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  ' ⤴ ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

TextSpan _bold(String text, TextStyle? base) =>
    TextSpan(text: text, style: base?.copyWith(fontWeight: FontWeight.w700));

TextSpan _normal(String text) => TextSpan(text: text);

/// Root: "(bold N) word(s) belong to the root family (bold X) (meaning)"
Widget buildRootFamilyHeader(BuildContext context, FamilyRootData data) {
  final n = data.count;
  final word = n == 1 ? 'word' : 'words';
  final base = Theme.of(context).textTheme.bodyMedium;
  return _richHeader(context, [
    _bold('$n', base),
    _normal(' $word belong to the root family '),
    _bold(data.rootFamily, base),
    _normal(' (${data.rootMeaning})'),
  ]);
}

/// Word: "(bold N) words which belong to the (bold X) family"
Widget buildWordFamilyHeader(BuildContext context, FamilyWordData data) {
  final base = Theme.of(context).textTheme.bodyMedium;
  return _richHeader(context, [
    _bold('${data.count}', base),
    _normal(' words which belong to the '),
    _bold(data.wordFamily, base),
    _normal(' family'),
  ]);
}

/// Compound: "(bold N) compound(s) which contain(s) (bold X)"
Widget buildCompoundFamilyHeader(
  BuildContext context,
  FamilyCompoundData data, {
  VoidCallback? onJumpTop,
}) {
  final n = data.count;
  final compound = n == 1 ? 'compound' : 'compounds';
  final contains = n == 1 ? 'contains' : 'contain';
  final base = Theme.of(context).textTheme.bodyMedium;
  return _richHeader(
    context,
    [
      _bold('$n', base),
      _normal(' $compound which $contains '),
      _bold(data.compoundFamily, base),
    ],
    onJumpTop: onJumpTop,
  );
}

/// Idiom: "(bold N) idiomatic expression(s) which contain(s) (bold X)"
Widget buildIdiomHeader(
  BuildContext context,
  FamilyIdiomData data, {
  VoidCallback? onJumpTop,
}) {
  final n = data.count;
  final expr = n == 1 ? 'idiomatic expression' : 'idiomatic expressions';
  final contains = n == 1 ? 'contains' : 'contain';
  final base = Theme.of(context).textTheme.bodyMedium;
  return _richHeader(
    context,
    [
      _bold('$n', base),
      _normal(' $expr which $contains '),
      _bold(data.idiom, base),
    ],
    onJumpTop: onJumpTop,
  );
}

/// Set: "(bold lemma) belongs to the set of (bold X)"
Widget buildSetHeader(
  BuildContext context,
  FamilySetData data,
  String lemma, {
  VoidCallback? onJumpTop,
}) {
  final base = Theme.of(context).textTheme.bodyMedium;
  return _richHeader(
    context,
    [
      _bold(lemma, base),
      _normal(' belongs to the set of '),
      _bold(data.set_, base),
    ],
    onJumpTop: onJumpTop,
  );
}

// ── Footer configs ────────────────────────────────────────────────────────────

FamilyFooterConfig buildRootFamilyFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Something out of place?',
    linkText: 'Report it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Root+Family',
  );
}

FamilyFooterConfig buildWordFamilyFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Something out of place?',
    linkText: 'Report it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Word+Family',
  );
}

FamilyFooterConfig buildCompoundFamilyFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Spot a mistake?',
    linkText: 'Fix it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Compound+Family',
  );
}

FamilyFooterConfig buildIdiomFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Please add more idioms',
    linkText: 'here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Idioms',
  );
}

FamilyFooterConfig buildSetFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Spot a mistake?',
    linkText: 'Fix it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Set',
  );
}
