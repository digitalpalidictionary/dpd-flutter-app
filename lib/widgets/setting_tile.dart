import 'package:flutter/material.dart';

import 'settings_help_dialog.dart';

/// A settings row that reflows instead of colliding when the system font is
/// large.
///
/// The label and its control share a line while they fit, and the control drops
/// to its own line once they do not. The decision is made by [Wrap] measuring
/// the laid-out widths, so no text-scale threshold is involved and the
/// normal-scale arrangement is simply what fitting produces.
///
/// [ListTile] is kept for its padding, minimum height and subtitle typography,
/// but its `trailing` slot is left empty on purpose: with no trailing, the
/// `title` slot spans the full content width, which puts a right-aligned
/// control on the same x as a real `trailing` would sit.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.title,
    this.topic,
    this.leading,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final SettingHelpTopic? topic;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final topic = this.topic;

    // MainAxisSize.min matters: a max-size row would claim the whole width and
    // push the control onto a second line at every text scale.
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(title)),
        if (topic != null) ...[
          const SizedBox(width: 4),
          SettingHelpButton(topic: topic),
        ],
      ],
    );

    return ListTile(
      leading: leading,
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [label, ?trailing],
      ),
      subtitle: subtitle,
    );
  }
}
