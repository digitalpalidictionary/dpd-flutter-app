import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/bubble_service.dart';
import 'dpd_logo.dart';

/// The single source of truth for whether the floating bubble is on, shared by
/// the settings toggle and the header button so they always agree. It reflects
/// the real state: the user's intent AND the accessibility permission actually
/// being granted.
final bubbleOnProvider = StateProvider<bool>((_) => false);

/// Re-reads the true bubble state from the platform into [bubbleOnProvider].
/// Call on mount and on app resume (e.g. returning from the settings page).
Future<void> refreshBubbleState(WidgetRef ref) async {
  final on = await BubbleService.isBubbleOn() && await BubbleService.isEnabled();
  ref.read(bubbleOnProvider.notifier).state = on;
}

/// Flips the bubble on/off from either control: updates the shared state and
/// applies the change (show/hide, plus the first-time consent prompt).
Future<void> setBubbleOn(BuildContext context, WidgetRef ref, bool on) async {
  ref.read(bubbleOnProvider.notifier).state = on;
  await applyBubbleToggle(context, on);
}

/// Turns the floating lookup bubble on/off. Shared by the settings toggle and
/// the header button so both drive identical behaviour. On the first enable
/// (accessibility service not yet granted) it shows a consent/disclosure prompt.
Future<void> applyBubbleToggle(BuildContext context, bool on) async {
  final primary = Theme.of(context).colorScheme.primary;
  if (on) {
    final enabled = await BubbleService.isEnabled();
    await BubbleService.showBubble(
      bgArgb: primary.toARGB32(),
      textArgb: DpdLogo.contrastOn(primary).toARGB32(),
    );
    if (!enabled && context.mounted) _showBubbleEnablePrompt(context);
  } else {
    await BubbleService.hideBubble();
  }
}

void _showBubbleEnablePrompt(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Turn on the DPD bubble'),
      content: const Text(
        'The floating bubble needs DPD switched on in your phone’s '
        'Accessibility settings. It draws a button over other apps and, when '
        'you tap it, looks up the word you’ve highlighted. It reads only that '
        'selected text, only when you tap, and sends nothing anywhere.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            BubbleService.openAccessibilitySettings();
          },
          child: const Text('Open settings'),
        ),
      ],
    ),
  );
}
