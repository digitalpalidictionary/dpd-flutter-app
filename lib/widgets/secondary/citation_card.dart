import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/citation_provider.dart';
import 'secondary_card.dart';

const _docsUrl = 'https://digitalpalidictionary.github.io/how_to_cite/';

class CitationCard extends ConsumerWidget {
  const CitationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    final citation = ref.watch(citationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DpdSecondaryCard(
          title: 'How to Cite DPD',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DPD is revised every month. Always cite the version you used.',
                style: bodyStyle,
              ),
              const SizedBox(height: 12),
              citation.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => Text(
                  'The citation is unavailable — the database may need updating.',
                  style: bodyStyle,
                ),
                data: (text) => text == null || text.isEmpty
                    ? Text(
                        'The citation is unavailable — the database may need updating.',
                        style: bodyStyle,
                      )
                    : _CitationText(text: text, style: bodyStyle),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(_docsUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.description_outlined, size: 16),
            label: const Text('Citing a single entry, and Chicago/MLA/APA forms'),
          ),
        ),
      ],
    );
  }
}

class _CitationText extends StatelessWidget {
  const _CitationText({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SelectableText(text, style: style)),
        IconButton(
          tooltip: 'Copy citation',
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Citation copied')),
            );
          },
        ),
      ],
    );
  }
}
