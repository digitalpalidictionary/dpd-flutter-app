import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/settings_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/text_filters.dart';

class WordCard extends ConsumerWidget {
  const WordCard({super.key, required this.headword, required this.onTap});

  final DpdHeadwordWithRoot headword;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final niggahitaMode = ref.watch(
      settingsProvider.select((s) => s.niggahitaMode),
    );
    final filterMode = NiggahitaFilterMode.values[niggahitaMode.index];
    String n(String t) => filterNiggahita(t, mode: filterMode);
    final theme = Theme.of(context);
    final meaning = n(headword.meaning1 ?? headword.meaningLit ?? '');
    final pos = n(headword.pos ?? '');
    final grammar = n(headword.grammar ?? '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
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
                      text: n(headword.lemma1),
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
