import 'package:flutter/material.dart';

import '../database/database.dart';

import '../theme/dpd_colors.dart';

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.headword, required this.onTap});

  final DpdHeadword headword;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meaning = headword.meaning1 ?? headword.meaningLit ?? '';
    final pos = headword.pos ?? '';
    final grammar = headword.grammar ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.brightness == Brightness.light
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 2,
            ),
            borderRadius: DpdColors.borderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: headword.lemma1,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (pos.isNotEmpty) ...[
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: pos,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: DpdColors.primaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (grammar.isNotEmpty) ...[
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: grammar,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (meaning.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  meaning,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
