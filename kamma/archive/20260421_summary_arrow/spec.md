# Spec: Summary arrow alignment

## Overview
In the summary list, when a headword has multiple items (e.g. "kamma 1", "kamma 2"),
the arrow (►) sits on the headword heading row instead of the tappable item line.

## What it should do
The ► arrow must appear next to each item line (the suffix + type + meaning line),
never next to the bare lemma heading. So for a multi-item headword, arrow shows
next to "1 <type> <meaning>", then next to "2 <type> <meaning>".

## Assumptions & uncertainties
- `splitSummaryLemma` and `shouldShowHeadwordHeading` logic is correct and does not
  need changing.
- Only the layout in `_SummaryRow.build` (headword branch) needs restructuring.
- The whole row remains tappable via the outer `InkWell`.

## Constraints
- Native Flutter widgets only.
- Theme colors preserved (no hardcoded colors).
- Behavior for non-headword entries unchanged.

## How we'll know it's done
- For a headword with multiple items, arrow aligns with the item line, not the
  lemma heading.
- `flutter analyze lib/widgets/summary_section.dart` clean.

## What's not included
- Refactoring `shouldShowHeadwordHeading` or related helpers.
- Changes to non-headword entries.

## Files
- `lib/widgets/summary_section.dart`
