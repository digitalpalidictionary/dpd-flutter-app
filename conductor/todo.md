# DPD Flutter TODO

## Performance
- Root family table slow for large families (e.g. √kar ~1000 entries): `IntrinsicColumnWidth()` on 3 of 4 columns forces O(n) layout passes; all rows rendered eagerly with no virtualization. Fix: replace with fixed/flex widths and/or switch to `ListView.builder`.

## Review
- Accessibility audit and keyboard refinements
- Feature parity decision: should compact mode show frequency/feedback sections? (Currently classic-only)
