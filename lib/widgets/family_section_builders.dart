import 'package:flutter/material.dart';

import '../database/database.dart';
import '../theme/dpd_colors.dart';
import 'family_table.dart';

const String _feedbackFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url';

// ── Header builders ──────────────────────────────────────────────────────────

/// Root: "**N** word(s) belong to the root family **√X** (meaning)"
Widget buildRootFamilyHeader(FamilyRootData data) {
  final n = data.count;
  final word = n == 1 ? 'word' : 'words';
  return RichText(
    text: TextSpan(
      style: TextStyle(
        color: DpdColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      children: [
        TextSpan(text: '$n '),
        TextSpan(text: '$word belong to the root family '),
        TextSpan(text: '√${data.rootFamily} '),
        TextSpan(
          text: '(${data.rootMeaning})',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    ),
  );
}

/// Word: "**N** words which belong to the **X** family"
Widget buildWordFamilyHeader(FamilyWordData data) {
  final n = data.count;
  return RichText(
    text: TextSpan(
      style: TextStyle(
        color: DpdColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      children: [
        TextSpan(text: '$n '),
        TextSpan(
          text: 'words which belong to the ',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
        TextSpan(text: '${data.wordFamily} '),
        TextSpan(
          text: 'family',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    ),
  );
}

/// Compound: "**N** compound(s) which contain(s) **X**"
Widget buildCompoundFamilyHeader(FamilyCompoundData data) {
  final n = data.count;
  final compound = n == 1 ? 'compound' : 'compounds';
  final contains = n == 1 ? 'contains' : 'contain';
  return RichText(
    text: TextSpan(
      style: TextStyle(
        color: DpdColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      children: [
        TextSpan(text: '$n '),
        TextSpan(
          text: '$compound which $contains ',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
        TextSpan(text: data.compoundFamily),
      ],
    ),
  );
}

/// Idiom: "**N** idiomatic expression(s) which contain(s) **X**"
Widget buildIdiomHeader(FamilyIdiomData data) {
  final n = data.count;
  final expr = n == 1 ? 'idiomatic expression' : 'idiomatic expressions';
  final contains = n == 1 ? 'contains' : 'contain';
  return RichText(
    text: TextSpan(
      style: TextStyle(
        color: DpdColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      children: [
        TextSpan(text: '$n '),
        TextSpan(
          text: '$expr which $contains ',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
        TextSpan(text: data.idiom),
      ],
    ),
  );
}

/// Set: "**lemma** belongs to the set of **X**"
Widget buildSetHeader(FamilySetData data, String lemma) {
  return RichText(
    text: TextSpan(
      style: TextStyle(
        color: DpdColors.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      children: [
        TextSpan(text: lemma),
        TextSpan(
          text: ' belongs to the set of ',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
        TextSpan(text: data.set_),
      ],
    ),
  );
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
