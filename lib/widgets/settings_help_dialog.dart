import 'package:flutter/material.dart';

import '../theme/dpd_colors.dart';

class SettingHelpTopic {
  const SettingHelpTopic({required this.title, required this.description});

  final String title;
  final String description;
}

Future<void> showSettingHelpDialog(
  BuildContext context, {
  required SettingHelpTopic topic,
}) {
  final screenSize = MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colorScheme = theme.colorScheme;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: DpdColors.borderRadius),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: screenSize.height * 0.72,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 1.5),
              borderRadius: DpdColors.borderRadius,
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic.title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Text(
                      topic.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class SettingHelpButton extends StatelessWidget {
  const SettingHelpButton({super.key, required this.topic});

  final SettingHelpTopic topic;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showSettingHelpDialog(context, topic: topic),
      icon: const Icon(Icons.info_outline, size: 18),
      tooltip: 'About ${topic.title}',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: 18,
      padding: EdgeInsets.zero,
    );
  }
}
