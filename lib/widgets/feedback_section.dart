import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/dpd_colors.dart';
import '../utils/feedback_urls.dart';
import 'entry_content.dart';

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({
    super.key,
    required this.headwordId,
    required this.lemma1,
  });

  final int headwordId;
  final String lemma1;

  String get _addWordUrl => buildAddWordUrl();

  String get _correctMistakeUrl =>
      buildMistakeUrl(word: lemma1, headwordId: headwordId);

  static const _docsUrl = 'https://digitalpalidictionary.github.io/';

  static const _getInvolvedUrl =
      'mailto:digitalpalidictionary@gmail.com?subject=I%20want%20to%20help!&body=Please%20let%20me%20know%20how%20I%20can%20get%20involved%20with%20the%20development%20of%20DPD.';

  static const _mailingListUrl = 'https://forms.gle/gJ7ouhJriYREPm1s8';

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return DpdSectionContainer(
      child: Padding(
        padding: DpdColors.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontSize: 13),
                children: [
                  const TextSpan(text: 'ID '),
                  TextSpan(
                    text: '$headwordId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digital Pāḷi Dictionary is a work in progress, made available for testing and feedback purposes.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            _FeedbackLink(
              linkText: 'Add a missing word',
              description:
                  '. Please use this online form to add missing words, especially from Vinaya, commentaries, and other later texts.',
              onTap: () => _openUrl(_addWordUrl),
            ),
            const SizedBox(height: 8),
            _FeedbackLink(
              linkText: 'Correct a mistake',
              description:
                  '. Did you spot a mistake in the dictionary? Have something to add? Please report it. It generally takes less than a minute and your corrections and suggestions help to improve the quality of this dictionary for everyone who uses it.',
              onTap: () => _openUrl(_correctMistakeUrl),
            ),
            const SizedBox(height: 8),
            _FeedbackLink(
              linkText: 'Read the docs',
              description:
                  '. Get more detailed information about installation on your devices, upgrades, advanced settings and features.',
              onTap: () => _openUrl(_docsUrl),
            ),
            const SizedBox(height: 8),
            _FeedbackLink(
              linkText: 'Get involved',
              description:
                  '. If you\'re a Pāḷi specialist or a coder, or would like to contribute to the project in any way, please get in touch.',
              onTap: () => _openUrl(_getInvolvedUrl),
            ),
            const SizedBox(height: 8),
            _FeedbackLink(
              linkText: 'Join the mailing list',
              description:
                  '. Get notified of updates and new features as soon as they become available.',
              onTap: () => _openUrl(_mailingListUrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackLink extends StatelessWidget {
  const _FeedbackLink({
    required this.linkText,
    required this.description,
    required this.onTap,
  });

  final String linkText;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.copyWith(fontSize: 13);
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                linkText,
                style: TextStyle(
                  fontSize: 13,
                  color: DpdColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          TextSpan(text: description),
        ],
      ),
    );
  }
}
