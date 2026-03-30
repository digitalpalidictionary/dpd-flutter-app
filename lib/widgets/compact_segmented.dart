import 'package:flutter/material.dart';

/// A compact SegmentedButton suitable for use as a ListTile trailing widget.
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
    return SegmentedButton<T>(
      segments: segments,
      selected: {selected},
      onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
      ),
      showSelectedIcon: false,
    );
  }
}
