# DPD Flutter TODO


## Performance
- Root family table slow for large families (e.g. √kar ~1000 entries): `IntrinsicColumnWidth()` on 3 of 4 columns forces O(n) layout passes; all rows rendered eagerly with no virtualization. Fix: replace with fixed/flex widths and/or switch to `ListView.builder`.

## Postponed
- Implement audio playback service and UI buttons

## Review
- simplify everything that can be simplified without losing any functionality
- Accessibility audit and keyboard refinements
- Review use of different text display widgets across different button sections, and sync
- Review different design patterns used in different button sections
- Remove all html widgets
