# Spec: Home Screen Improvements

## Overview
Replace the blank "Type a Pāḷi word to begin" empty state with a useful home screen
showing a Word of the Day and recent search history.

## What it should do
1. Word of the Day
   - Pick one headword with ebt_count > 0 using today's date as a deterministic seed
   - Same word for every user on the same day; changes at midnight
   - Shows: lemma1, pos, meaning1 (truncated at ~80 chars)
   - Tapping opens the entry screen for that headword

2. Recent Searches
   - Show last 10 searches from history as tappable chips
   - Tapping a chip sets the search field and fires the search
   - Only shown if history is non-empty; no empty placeholder

3. Header tap to home
   - Tapping the DPD logo or "Digital Pāḷi Dictionary" title clears the search
     and returns to the home content view

## Assumptions & uncertainties
- ebt_count > 0 pool contains thousands of words — ORDER BY id + OFFSET is
  fine for local SQLite at this scale
- Drift's join query supports LIMIT+OFFSET (confirmed from existing usage)
- DpdHeadwordWithRoot is sufficient for the card display (no additional rootCount needed)
- History chips navigate the same way as tapping an autocomplete suggestion

## Constraints
- No hardcoded colors — use colorScheme only
- No HTML widgets for DPD content
- No comments unless non-obvious

## How we'll know it's done
- Opening app with empty query shows Word of the Day card + recent chips
- Tapping word card opens correct entry
- Tapping a chip searches that word
- Tapping logo/title when a search is active clears and returns to home
- Different date seed produces a different word (manual check)

## What's not included
- Server-curated word selection
- Sutta quote of the day
- Browse A–Z
- Favorites / bookmarks
