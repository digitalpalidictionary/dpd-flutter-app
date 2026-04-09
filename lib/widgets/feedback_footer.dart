import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_update_provider.dart';
import '../theme/dpd_colors.dart';
import '../widgets/feedback_form_sheet.dart';

class FeedbackFooter extends ConsumerWidget {
  const FeedbackFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final dbVersion = ref.watch(dbUpdateProvider).localVersion;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SelectionContainer.disabled(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showFeedbackFormSheet(context, dbVersion: dbVersion),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4 + bottomPadding),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: DpdColors.grayTransparent, width: 2),
              borderRadius: DpdColors.borderRadius,
            ),
            child: Center(
              child: Text(
                'Having a problem? Click here to report it',
                style: TextStyle(
                  fontSize: 12.8,
                  color: DpdColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
