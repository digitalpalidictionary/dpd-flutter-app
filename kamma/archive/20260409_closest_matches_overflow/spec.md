# Fix: Closest matches overflow

## Overview
The "Closest matches" suggestions use `ActionChip` widgets inside a `Wrap`, causing horizontal overflow on narrow screens. Replace with a simple vertical list of plain text items that are naturally tap-searchable via the existing `TapSearchWrapper`.

## What it should do
- Display closest matches as a vertical list of plain `Text` widgets (one per line)
- Each match is clickable via the app's existing tap-to-search mechanism (single or double-tap per user setting)
- "No results for ..." and "Closest matches:" are left-aligned headings, each on its own line
- No `ActionChip`, no special widget — just plain text
- No horizontal overflow

## Constraints
- Must remain inside `TapSearchWrapper` (already is via `_buildBody`)
- Must use theme colors, not hardcoded
- No new widgets needed

## How we'll know it's done
- No overflow on narrow screens
- Tapping a closest match triggers a search (same as tapping any word elsewhere)
- Headings are left-aligned and visually coherent

## What's not included
- No changes to closest match logic/provider
- No changes to TapSearchWrapper
