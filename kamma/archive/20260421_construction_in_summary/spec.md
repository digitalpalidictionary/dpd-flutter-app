# Spec: Construction in summary toggle

## Overview
Add a setting to show or hide the word construction (e.g., `[anu + √sar + a]`) in the summary
section at the top of search results.

## What it should do
- A new setting "Construction in summary" appears in the Settings panel above the "Grammar button"
  row (in the same divider section).
- Toggle has two options: "Show" (default) and "Hide".
- When set to "Hide", the `[construction]` portion is omitted from every summary row meaning;
  the rest of the meaning text still appears normally.
- Setting persists across sessions via SharedPreferences.

## Assumptions & uncertainties
- "Construction" = `headword.constructionSummary`, rendered as `[anu + √sar + a]` by
  `_buildHeadwordSummaryMeaning` in `summary_provider.dart:188`.
- The setting only affects the Summary section, not the full entry card.
- Default is `true` (Show).

## Constraints
- No hardcoded colours. Use theme values.
- Follow existing `CompactSegmented` pattern used by every other bool setting.
- Do not alter any other summary behaviour (meaning display, row tap, etc.).

## How we'll know it's done
- Toggle appears in settings, above "Grammar button", labelled "Construction in summary".
- Switching to "Hide" removes the `[…]` bracket from summary meanings immediately.
- Switching back to "Show" restores it.
- Setting survives an app restart.

## What's not included
- Hiding construction from the full entry card grammar table.
- Any change to partial/fuzzy result rows (they have no construction).
