import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database.dart';
import '../database/dpd_headword_extensions.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../theme/dpd_colors.dart';
import '../utils/text_filters.dart';

class DpdFooter extends StatelessWidget {
  const DpdFooter({
    super.key,
    required this.messagePrefix,
    required this.linkText,
    required this.urlBuilder,
  });

  final String messagePrefix;
  final String linkText;
  final String Function() urlBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: DpdColors.primary, width: 1)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () async {
            await launchUrl(
              Uri.parse(urlBuilder()),
              mode: LaunchMode.platformDefault,
            );
          },
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 12.8, color: Colors.grey),
              children: [
                TextSpan(text: '$messagePrefix '),
                TextSpan(
                  text: linkText,
                  style: TextStyle(
                    color: DpdColors.primaryText,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<(String, String)> buildFamilyRows(DpdHeadwordWithRoot h) => [
  if (h.familyRoot != null && h.familyRoot!.isNotEmpty)
    ('Root family', h.familyRoot!),
  if (h.familyWord != null && h.familyWord!.isNotEmpty)
    ('Word family', h.familyWord!),
  if (h.familyCompound != null && h.familyCompound!.isNotEmpty)
    ('Compound members', h.familyCompound!),
  if (h.familyIdioms != null && h.familyIdioms!.isNotEmpty)
    ('Idioms', h.familyIdioms!),
  if (h.familySet != null && h.familySet!.isNotEmpty)
    ('Thematic sets', h.familySet!),
  if (h.antonym != null && h.antonym!.isNotEmpty) ('Antonyms', h.antonym!),
  if (h.synonym != null && h.synonym!.isNotEmpty) ('Synonyms', h.synonym!),
  if (h.variant != null && h.variant!.isNotEmpty) ('Variants', h.variant!),
];

String posGrammarLine(DpdHeadwordWithRoot h) {
  final parts = [
    h.pos,
    h.grammar,
  ].whereType<String>().where((s) => s.isNotEmpty);
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
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: DpdColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              softWrap: false,
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class EntryExampleBlock extends ConsumerWidget {
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(
          data: n(example),
          shrinkWrap: true,
          style: {
            'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            'p': Style(margin: Margins.zero),
          },
        ),
        if (sutta != null || source != null) ...[
          Html(
            data:
                '<p class="sutta">${[source, sutta].whereType<String>().map(n).join(' ')}</p>',
            style: {
              'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              'p.sutta': Style(
                color: DpdColors.primaryText,
                fontStyle: FontStyle.italic,
                fontSize: FontSize(theme.textTheme.bodySmall?.fontSize ?? 12.0),
                margin: Margins.zero,
                padding: HtmlPaddings.only(bottom: 3),
              ),
              'a.sutta_link': Style(
                color: DpdColors.primaryText,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                textDecoration: TextDecoration.none,
              ),
            },
            onLinkTap: (url, attributes, element) async {
              if (url != null) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class EntrySummaryBox extends ConsumerWidget {
  const EntrySummaryBox({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showApostrophe = ref.watch(
      settingsProvider.select((s) => s.showSandhiApostrophe),
    );
    final niggahitaMode = ref.watch(
      settingsProvider.select((s) => s.niggahitaMode),
    );
    final theme = Theme.of(context);
    final h = headword.headword;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    final boldStyle = baseStyle?.copyWith(fontWeight: FontWeight.w700);
    final grayStyle = baseStyle?.copyWith(
      color: Colors.grey,
    );

    String f(String? text) => filterNiggahita(
      filterApostrophe(text ?? '', show: showApostrophe),
      mode: NiggahitaFilterMode.values[niggahitaMode.index],
    );

    final hasMeaning1 = h.meaning1 != null && h.meaning1!.isNotEmpty;
    final summary = h.constructionSummary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        borderRadius: DpdColors.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            if (h.pos != null && h.pos!.isNotEmpty)
              TextSpan(text: '${f(h.pos)}. '),
            if (h.plusCase != null && h.plusCase!.isNotEmpty)
              TextSpan(text: '(${f(h.plusCase)}) '),
            if (hasMeaning1) ...[
              TextSpan(text: f(h.meaning1), style: boldStyle),
              if (h.meaningLit != null && h.meaningLit!.isNotEmpty)
                TextSpan(text: '; lit. ${f(h.meaningLit)}'),
            ] else if (h.meaning2 != null && h.meaning2!.isNotEmpty) ...[
              if (h.meaning2!.contains('; lit.'))
                TextSpan(text: f(h.meaning2))
              else if (h.meaningLit != null && h.meaningLit!.isNotEmpty)
                TextSpan(text: '${f(h.meaning2)}; lit. ${f(h.meaningLit)}')
              else
                TextSpan(text: f(h.meaning2)),
            ],
            if (summary.isNotEmpty) TextSpan(text: ' [${f(summary)}]'),
            TextSpan(text: ' ${h.degreeOfCompletion}', style: grayStyle),
          ],
        ),
      ),
    );
  }
}

/// A bordered container for entry section content, matching .dpd.content CSS.
class DpdSectionContainer extends StatelessWidget {
  const DpdSectionContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        borderRadius: DpdColors.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: child,
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
    final theme = Theme.of(context);
    final bg = isActive
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    final fg = isActive
        ? theme.colorScheme.onSecondary
        : theme.colorScheme.onPrimary;
    final shadow = isActive ? DpdColors.shadowHover : DpdColors.shadowDefault;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 1, 2),
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: bg, width: 1),
          borderRadius: DpdColors.borderRadius,
          boxShadow: shadow,
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

/// Main play button — same visual style as DpdSectionButton but with a play icon.
/// Shows active color while playing, grays out if audio fetch fails.
class DpdPlayButton extends StatefulWidget {
  const DpdPlayButton({super.key, required this.lemma, required this.gender});

  final String lemma;
  final String gender;

  @override
  State<DpdPlayButton> createState() => _DpdPlayButtonState();
}

class _DpdPlayButtonState extends State<DpdPlayButton> {
  bool _playing = false;
  bool _errored = false;

  Future<void> _play() async {
    if (_errored) return;
    setState(() => _playing = true);
    final ok = await AudioService.instance.play(widget.lemma, widget.gender);
    if (!mounted) return;
    setState(() {
      _playing = false;
      if (!ok) _errored = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg;
    final Color fg;
    final List<BoxShadow> shadow;
    if (_errored) {
      bg = theme.colorScheme.onSurface.withValues(alpha: 0.12);
      fg = theme.colorScheme.onSurface.withValues(alpha: 0.38);
      shadow = [];
    } else if (_playing) {
      bg = theme.colorScheme.secondary;
      fg = theme.colorScheme.onSecondary;
      shadow = DpdColors.shadowHover;
    } else {
      bg = theme.colorScheme.primary;
      fg = theme.colorScheme.onPrimary;
      shadow = DpdColors.shadowDefault;
    }
    return GestureDetector(
      onTap: _errored ? null : _play,
      child: Container(
        margin: const EdgeInsets.fromLTRB(1, 1, 1, 2),
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: bg, width: 1),
          borderRadius: DpdColors.borderRadius,
          boxShadow: shadow,
        ),
        child: Icon(Icons.play_arrow, color: fg, size: 18),
      ),
    );
  }
}

class EntryExampleFooter extends StatelessWidget {
  const EntryExampleFooter({
    super.key,
    required this.headwordId,
    required this.lemma1,
  });

  final int headwordId;
  final String lemma1;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final encodedLemma = Uri.encodeComponent(lemma1);

    return DpdFooter(
      messagePrefix: 'Can you think of a better example?',
      linkText: 'Add it here.',
      urlBuilder: () =>
          'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500=$headwordId%20$encodedLemma&entry.326955045=Examples&entry.1433863141=DPD+$date',
    );
  }
}
