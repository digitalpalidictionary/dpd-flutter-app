# Fix: Partial Results Header Flashes When No Partial Results Exist

## Overview
When the user clicks search, the "Partial Results" header/divider briefly flashes on screen even when there are no partial results to display.

## What it should do
- The "Partial Results" divider should only appear when there are actual partial results in `tier2`.
- A loading spinner for partial results should only appear while loading AND only if there are no results yet (to avoid showing a bare spinner with a header and no content).
- When there are zero partial results, nothing should display — no header, no spinner.

## Constraints
- Must not affect fuzzy results or exact results display logic.
- Must not change the loading UX when partial results DO exist.

## How we'll know it's done
- Searching a term that yields only exact results (no partials) never shows the "Partial Results" divider.
- Searching a term that yields partial results still shows the divider and results correctly.

## What's not included
- Changes to fuzzy results header behavior (it already works correctly).
- Any other search UI changes.
