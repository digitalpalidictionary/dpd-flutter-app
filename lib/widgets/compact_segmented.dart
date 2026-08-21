import 'package:flutter/material.dart';

/// A row of segments styled as one pill.
///
/// Scrolls horizontally when the segments need more width than they are given,
/// so it must be placed somewhere with a bounded width — inside a `Row` or a
/// horizontal list it will assert rather than overflow.
class CompactSegmented<T> extends StatelessWidget {
  const CompactSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<ButtonSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge!;

    // Scrolls sideways rather than overflowing when the segments need more width
    // than the row can give. SingleChildScrollView takes its child's own width
    // while the child fits, so nothing changes until it stops fitting.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < segments.length; i++) ...[
                  if (i > 0)
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colorScheme.outline,
                    ),
                  _buildSegment(segments[i], colorScheme, textStyle),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(
    ButtonSegment<T> segment,
    ColorScheme colorScheme,
    TextStyle textStyle,
  ) {
    final isSelected = segment.value == selected;

    return GestureDetector(
      onTap: enabled && !isSelected ? () => onChanged(segment.value) : null,
      child: ColoredBox(
        color: isSelected
            ? colorScheme.secondaryContainer
            : colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: DefaultTextStyle(
            style: textStyle.copyWith(
              color: isSelected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            child: segment.label ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
