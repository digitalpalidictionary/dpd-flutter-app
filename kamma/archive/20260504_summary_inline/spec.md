---
# Spec: Inline summary rows for unnumbered headwords

## Overview
Change the Summary section so single-lemma headwords render on one line, while numbered variant groups (kāraṇā 1, kāraṇā 2, …) keep the existing two-line stacked layout.

## What it should do
- A headword whose results group has only ONE entry (plain word like `dhammavicara`, or numbered like `kāraṇā 2` when only one variant appears in results) renders inline: `label typeLabel meaning ►`
- A headword group with MORE THAN ONE entry sharing the same bare lemma (kāraṇā 1 + kāraṇā 2 both in results) keeps the current behavior: heading line + info row(s) below.

## Affected files
- `lib/widgets/summary_section.dart`

## How we'll know it's done
- `dhammavicara` → one inline row
- `kāraṇaṃ` (declension returning only `kāraṇā 2`) → one inline row
- `kāraṇā` (exact search returning `kāraṇā 1` + `kāraṇā 2`) → grouped with heading

## Not included
- Restyling colors, fonts, or spacing
- Changes to root / secondary entry rendering
