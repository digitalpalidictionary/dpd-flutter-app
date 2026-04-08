# Fix: square brackets and other delimiters not cleaned from tap-to-search

## Overview
When tapping a word wrapped in brackets (e.g., `[√bhid]`) or parentheses, the
delimiter characters are included in the search query, causing a failed search
like `[√bhid` instead of `√bhid`.

## What it should do
- Strip `[`, `]`, `(`, `)`, `{`, `}` from the beginning and end of tapped text
  before searching, same as other punctuation already handled.
- Existing punctuation cleaning must continue to work.

## Constraints
- Only modify `_cleanPali` in `tap_search_wrapper.dart`.

## How we'll know it's done
- Tapping `[√bhid]` searches for `√bhid`.
- Tapping `(kamma)` searches for `kamma`.
- Existing cleaning (quotes, dashes, ellipsis) still works.

## What's not included
- Changes to word-boundary logic.
- Changes to search provider or database layer.
