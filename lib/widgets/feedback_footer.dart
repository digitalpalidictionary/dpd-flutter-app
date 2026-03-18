import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/database_update_provider.dart';
import '../theme/dpd_colors.dart';
import '../utils/app_feedback_url.dart';

class FeedbackFooter extends ConsumerWidget {
  const FeedbackFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final dbVersion = ref.watch(dbUpdateProvider).localVersion;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4 + bottomPadding),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: DpdColors.grayTransparent, width: 2),
        borderRadius: DpdColors.borderRadius,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SelectionContainer.disabled(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final url = await buildFeedbackUrl(dbVersion: dbVersion);
              await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
            },
            child: Center(child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 12.8, color: DpdColors.gray),
                children: [
                  const TextSpan(text: 'Having a problem? Report it '),
                  TextSpan(
                    text: 'here',
                    style: TextStyle(
                      color: DpdColors.primaryText,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
