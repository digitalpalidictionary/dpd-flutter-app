# Single-tap word search with settings toggle

## Overview
Change the default word-search gesture from double-tap to single-tap, and add a
settings option so users can choose between single-tap and double-tap.

## What it should do
- Tapping a word once selects it and immediately runs a search (new default).
- A "Word search tap" setting in the settings panel lets users pick "Single" or "Double".
- When set to "Double", behaviour is identical to today's double-tap search.
- The setting persists across app restarts.

## Constraints
- Must not break text selection / copy-paste (long-press context menu must still work).
- Must work on all screens that currently use DoubleTapSearchWrapper (search, entry, root, inflection table).
- No hardcoded colours; use theme colours.

## How we'll know it's done
- Default fresh install uses single-tap to search.
- Switching to "Double" in settings restores original double-tap behaviour.
- Long-press text selection and context menu still work in both modes.

## What's not included
- Triple-tap or other gestures.
- Any changes to the search logic itself.
