import 'package:flutter/material.dart';

import '../database/database.dart';
import 'family_table.dart';

const String _feedbackFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url';

// ── Header builders ──────────────────────────────────────────────────────────
// All headers use plain Text — DefaultTextStyle.merge in the heading wrapper
// provides the bold weight; default theme color is used (no explicit color).

/// Root: "N word(s) belong to the root family √X (meaning)"
Widget buildRootFamilyHeader(FamilyRootData data) {
  final n = data.count;
  final word = n == 1 ? 'word' : 'words';
  return Text('$n $word belong to the root family √${data.rootFamily} (${data.rootMeaning})');
}

/// Word: "N words which belong to the X family"
Widget buildWordFamilyHeader(FamilyWordData data) {
  final n = data.count;
  return Text('$n words which belong to the ${data.wordFamily} family');
}

/// Compound: "N compound(s) which contain(s) X"
Widget buildCompoundFamilyHeader(FamilyCompoundData data) {
  final n = data.count;
  final compound = n == 1 ? 'compound' : 'compounds';
  final contains = n == 1 ? 'contains' : 'contain';
  return Text('$n $compound which $contains ${data.compoundFamily}');
}

/// Idiom: "N idiomatic expression(s) which contain(s) X"
Widget buildIdiomHeader(FamilyIdiomData data) {
  final n = data.count;
  final expr = n == 1 ? 'idiomatic expression' : 'idiomatic expressions';
  final contains = n == 1 ? 'contains' : 'contain';
  return Text('$n $expr which $contains ${data.idiom}');
}

/// Set: "lemma belongs to the set of X"
Widget buildSetHeader(FamilySetData data, String lemma) {
  return Text('$lemma belongs to the set of ${data.set_}');
}

// ── Footer configs ────────────────────────────────────────────────────────────

FamilyFooterConfig buildRootFamilyFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Did you spot a mistake?',
    linkText: 'Correct it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Root+Family',
  );
}

FamilyFooterConfig buildWordFamilyFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Did you spot a mistake?',
    linkText: 'Correct it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Word+Family',
  );
}

FamilyFooterConfig buildCompoundFamilyFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Did you spot a mistake?',
    linkText: 'Correct it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Compound+Family',
  );
}

FamilyFooterConfig buildIdiomFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Did you spot a mistake?',
    linkText: 'Correct it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Idioms',
  );
}

FamilyFooterConfig buildSetFooter(int headwordId, String lemma1) {
  final encoded = Uri.encodeComponent(lemma1);
  return FamilyFooterConfig(
    messagePrefix: 'Did you spot a mistake?',
    linkText: 'Correct it here',
    urlBuilder: () =>
        '$_feedbackFormUrl&entry.438735500=$headwordId%20$encoded&entry.326955045=Set',
  );
}
