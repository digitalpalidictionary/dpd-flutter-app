import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../database/database.dart';
import '../theme/dpd_colors.dart';

List<(String, String)> buildGrammarRows(DpdHeadword h) => [
      if (h.pos != null && h.pos!.isNotEmpty) ('Part of speech', h.pos!),
      if (h.grammar != null && h.grammar!.isNotEmpty) ('Grammar', h.grammar!),
      if (h.derivedFrom != null && h.derivedFrom!.isNotEmpty) ('Derived from', h.derivedFrom!),
      if (h.neg != null && h.neg!.isNotEmpty) ('Negative', h.neg!),
      if (h.verb != null && h.verb!.isNotEmpty) ('Verb type', h.verb!),
      if (h.trans != null && h.trans!.isNotEmpty) ('Transitive', h.trans!),
      if (h.plusCase != null && h.plusCase!.isNotEmpty) ('Plus case', h.plusCase!),
      if (h.derivative != null && h.derivative!.isNotEmpty) ('Derivative', h.derivative!),
      if (h.stem != null && h.stem!.isNotEmpty) ('Stem', h.stem!),
      if (h.pattern != null && h.pattern!.isNotEmpty) ('Pattern', h.pattern!),
      if (h.rootKey != null && h.rootKey!.isNotEmpty) ('Root', h.rootKey!),
      if (h.rootSign != null && h.rootSign!.isNotEmpty) ('Root sign', h.rootSign!),
      if (h.rootBase != null && h.rootBase!.isNotEmpty) ('Root base', h.rootBase!),
      if (h.suffix != null && h.suffix!.isNotEmpty) ('Suffix', h.suffix!),
      if (h.compoundType != null && h.compoundType!.isNotEmpty) ('Compound type', h.compoundType!),
    ];

List<(String, String)> buildFamilyRows(DpdHeadword h) => [
      if (h.familyRoot != null && h.familyRoot!.isNotEmpty) ('Root family', h.familyRoot!),
      if (h.familyWord != null && h.familyWord!.isNotEmpty) ('Word family', h.familyWord!),
      if (h.familyCompound != null && h.familyCompound!.isNotEmpty)
        ('Compound members', h.familyCompound!),
      if (h.familyIdioms != null && h.familyIdioms!.isNotEmpty) ('Idioms', h.familyIdioms!),
      if (h.familySet != null && h.familySet!.isNotEmpty) ('Thematic sets', h.familySet!),
      if (h.antonym != null && h.antonym!.isNotEmpty) ('Antonyms', h.antonym!),
      if (h.synonym != null && h.synonym!.isNotEmpty) ('Synonyms', h.synonym!),
      if (h.variant != null && h.variant!.isNotEmpty) ('Variants', h.variant!),
    ];

String posGrammarLine(DpdHeadword h) {
  final parts = [h.pos, h.grammar].whereType<String>().where((s) => s.isNotEmpty);
  return parts.join(' · ');
}

class EntryLabelValue extends StatelessWidget {
  const EntryLabelValue({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class EntryExampleBlock extends StatelessWidget {
  const EntryExampleBlock({
    super.key,
    required this.example,
    this.sutta,
    this.source,
  });

  final String example;
  final String? sutta;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(data: example),
        if (sutta != null || source != null) ...[
          const SizedBox(height: 4),
          Text(
            [source, sutta].whereType<String>().join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class EntrySummaryBox extends StatelessWidget {
  const EntrySummaryBox({super.key, required this.headword});

  final DpdHeadword headword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headword.pos != null && headword.pos!.isNotEmpty)
            Text(
              '${headword.pos}${headword.meaning1 != null && headword.meaning1!.isNotEmpty ? ' (${headword.meaning1})' : ''}',
              style: theme.textTheme.bodyLarge,
            ),
          if (headword.meaningLit != null && headword.meaningLit!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'lit. ${headword.meaningLit}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (headword.construction != null && headword.construction!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              headword.construction!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Webapp-style section toggle button matching .dpd-button CSS class.
/// Inactive: cyan fill, dark text. Active: primary-alt fill, light text.
class DpdSectionButton extends StatelessWidget {
  const DpdSectionButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? DpdColors.primaryAlt : DpdColors.primary;
    final fg = isActive ? DpdColors.light : DpdColors.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 1, 2),
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: bg, width: 1),
          borderRadius: BorderRadius.circular(7),
          boxShadow: DpdColors.shadowDefault,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 14.0 * 0.8,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
