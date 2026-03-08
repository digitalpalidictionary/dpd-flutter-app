import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/frequency_data.dart';
import '../theme/dpd_colors.dart';
import '../utils/date_utils.dart';
import 'entry_content.dart';
import 'frequency_table.dart';

class FrequencySection extends StatelessWidget {
  const FrequencySection({
    super.key,
    required this.data,
    required this.headwordId,
    required this.lemma1,
  });

  final FrequencyData data;
  final int headwordId;
  final String lemma1;

  @override
  Widget build(BuildContext context) {
    return DpdSectionContainer(
      child: Padding(
        padding: DpdColors.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeading(context),
            if (!data.isNoExactMatches) ...[
              const SizedBox(height: 5),
              FrequencyTable(data: data),
              const SizedBox(height: 8),
              _buildCorpusLegend(context),
              const SizedBox(height: 8),
              _buildExplanationLink(context),
            ] else ...[
              const SizedBox(height: 5),
              const Text(
                'It probably only occurs in compounds. Or perhaps there is an error.',
              ),
            ],
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(BuildContext context) {
    final heading = data.freqHeading;

    final parts = <InlineSpan>[];
    final boldRegex = RegExp(r'<b>(.*?)</b>');
    var lastEnd = 0;

    for (final match in boldRegex.allMatches(heading)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(text: heading.substring(lastEnd, match.start)));
      }
      parts.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < heading.length) {
      parts.add(TextSpan(text: heading.substring(lastEnd)));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DpdColors.primary, width: 1)),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: parts,
        ),
      ),
    );
  }

  Widget _buildCorpusLegend(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    final boldStyle = style.copyWith(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _legendLine(
          'CST',
          'Chaṭṭha Saṅgāyana Tipiṭaka (Myanmar)',
          style,
          boldStyle,
        ),
        _legendLine(
          'BJT',
          'Buddha Jayanti Tipiṭaka (Sri Lanka)',
          style,
          boldStyle,
        ),
        _legendLine(
          'SYA',
          'Syāmaraṭṭha 1927 Royal Edition (Thailand)',
          style,
          boldStyle,
        ),
        _legendLine(
          'MST',
          'Mahāsaṅgīti Tipiṭaka (Sutta Central)',
          style,
          boldStyle,
        ),
      ],
    );
  }

  Widget _legendLine(
    String abbrev,
    String fullName,
    TextStyle style,
    TextStyle boldStyle,
  ) {
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: abbrev, style: boldStyle),
          TextSpan(text: ': $fullName'),
        ],
      ),
    );
  }

  Widget _buildExplanationLink(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          const TextSpan(
            text:
                'For a detailed explanation of how this word frequency chart is calculated, '
                "it's accuracies and inaccuracies, please refer to ",
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => launchUrl(
                Uri.parse(
                  'https://digitalpalidictionary.github.io/features/frequency/',
                ),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                'this webpage',
                style: TextStyle(
                  color: DpdColors.primaryText,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final encodedLemma = Uri.encodeComponent(lemma1);

    return DpdFooter(
      messagePrefix: 'If something looks out of place,',
      linkText: 'log it here.',
      urlBuilder: () =>
          'https://docs.google.com/forms/d/e/1FAIpQLSf9boBe7k5tCwq7LdWgBHHGIPVc4ROO5yjVDo1X5LDAxkmGWQ/viewform?usp=pp_url&entry.438735500=$headwordId%20$encodedLemma&entry.326955045=Frequency&entry.1433863141=${dpdAppLabel()}',
    );
  }
}
