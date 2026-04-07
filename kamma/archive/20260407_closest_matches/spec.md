# Closest Matches on No Results

## Overview
When a search returns no results across all tiers (exact, partial, fuzzy, root, dict, secondary), show a list of clickable closest-matching words instead of just "No results for X".

## What it should do
- When no results are found, query the lookup table for words similar to the search term
- Use two strategies: (1) progressively shorter prefix matches on lookup_key, and (2) fuzzy_key prefix trimming for diacritics-insensitive matching
- Display up to 10 closest matches as tappable chips, sorted in Pāḷi alphabetical order
- Tapping a match triggers a new search for that word (same as autocomplete selection)
- Still show "No results for X" as a header above the suggestions

## Constraints
- Must not slow down normal search — only runs when all result tiers are empty
- Query runs against the existing `lookup` table (no new tables or indexes)
- Native Flutter widgets only (no HTML)
- Use theme colors, not hardcoded colors
- Results sorted by Pāḷi alphabetical order using existing `paliSortKey`

## How we'll know it's done
- Searching for a misspelled Pali word (e.g. "dhama" instead of "dhamma") shows closest matches
- Tapping a suggestion searches for that word
- No performance regression on normal searches

## What's not included
- No ASCII-to-Unicode dictionary (the app already handles this via Velthuis transliteration)
- No changes to existing search tiers
