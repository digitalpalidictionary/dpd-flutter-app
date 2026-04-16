import 'package:flutter/material.dart';

import '../theme/dpd_colors.dart';

Future<void> showFeedbackBottomSheet(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DpdColors.borderRadiusValue),
      ),
    ),
    builder: builder,
  );
}

class FeedbackRequiredFieldLabel extends StatelessWidget {
  const FeedbackRequiredFieldLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '* ',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 13,
            ),
          ),
          TextSpan(
            text: 'Required field',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackQuestionCard extends StatelessWidget {
  const FeedbackQuestionCard({
    super.key,
    required this.question,
    required this.child,
    this.subText,
    this.required = false,
  });

  final String question;
  final String? subText;
  final bool required;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(DpdColors.borderRadiusValue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: question,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(
              subText!,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class FeedbackCheckboxCard extends StatelessWidget {
  const FeedbackCheckboxCard({
    super.key,
    required this.question,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.submitted,
    this.required = false,
  });

  final String question;
  final List<String> options;
  final List<String> selected;
  final void Function(String) onToggle;
  final bool submitted;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = submitted && required && selected.isEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(DpdColors.borderRadiusValue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: question,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...options.map(
            (opt) => InkWell(
              onTap: () => onToggle(opt),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: selected.contains(opt),
                      onChanged: (_) => onToggle(opt),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    Text(opt, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 4),
            Text(
              'Please select at least one option',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
