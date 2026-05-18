# Spec: Bold rendering in Summary for meaning_1

## Overview
Bold markup in `meaning_1` (`<b>...</b>` tags) was not rendered in the Summary section — it showed as plain text.

## What it should do
- Summary entries that use `meaning_1` render `<b>` tags as bold text
- Summary entries that fall back to `meaning_2` render as plain text (no bold parsing)
- `meaning_lit` is not shown in the summary — no change needed there

## Assumptions & uncertainties
- `meaning_1` uses `<b>...</b>` tags (confirmed by `_parseBoldSpans` in entry_content.dart)
- `meaning_2` does not need bold parsing per user's explicit instruction
- The existing `_parseBoldSpans` logic (regex `<b>(.*?)</b>`) is the correct parser to reuse

## Constraints
- No new files; inline the bold-span parser in summary_section.dart
- Touch only: summary_entry.dart, summary_provider.dart, summary_section.dart

## How we'll know it's done
- Summary shows bold for bold words in meaning_1
- No bold in meaning_2 fallback entries

## What's not included
- meaning_lit (not shown in summary)
- Any other formatting tags (italic, links)
