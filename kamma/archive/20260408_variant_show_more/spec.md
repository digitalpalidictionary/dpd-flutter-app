# Variant Readings "Show More" Collapse

## Overview
Long variant reading lists should be collapsed by default to avoid overwhelming the screen.

## What it should do
- Count the total number of data rows in the variant table (excluding the header row and separator rows).
- If there are more than 10 data rows, only show the first 10 rows plus a "show more (N remaining)" link at the bottom.
- Tapping "show more" expands to reveal all rows. The link text changes to "show less".
- Tapping "show less" collapses back to the first 10 rows.
- If there are 10 or fewer rows, show everything as before — no collapse UI.

## Constraints
- Only the `_VariantTable` widget changes. No model or provider changes needed.
- Use theme colors, not hardcoded colors.

## How we'll know it's done
- Variant cards with <=10 rows display identically to before.
- Variant cards with >10 rows show only 10 rows + "show more" link.
- Expanding/collapsing works correctly and preserves table formatting.

## What's not included
- No changes to other secondary result cards.
- No persistence of expanded/collapsed state across navigation.
