import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';

class EmptyPrompt extends StatelessWidget {
  const EmptyPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Type a Pāḷi word to begin',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class NoResultsWithSuggestions extends ConsumerWidget {
  const NoResultsWithSuggestions({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closestAsync = ref.watch(closestMatchesProvider(query));
    final matches = closestAsync.valueOrNull ?? [];
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No results for "$query"',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (matches.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Closest matches:',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              for (final match in matches)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(match, style: theme.textTheme.bodyLarge),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
