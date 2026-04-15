# Spec: Remove showExactResults Setting

## Overview
Remove the `showExactResults` setting from the app entirely. There is never a valid reason to hide exact search results — if a user searched for a term and it matched exactly, they always want to see it. The setting adds confusion and complexity with zero benefit.

## What it should do
- Exact DPD headword results are always shown unconditionally.
- Exact dict results are always shown unconditionally.
- The "Exact results" Show/Hide tile is removed from the settings panel.
- No trace of `showExactResults` remains in Settings, SettingsNotifier, preferences loading, copyWith, ==, hashCode, or the search screen.

## Assumptions & uncertainties
- The `visibleDictExact` gating on `showExactResults` in `search_screen.dart` must also be removed (dict exact results were equally affected).
- Deleting the SharedPreferences key `show_exact_results` from device storage is NOT needed — the key simply becomes orphaned and ignored on existing installs. No migration required.
- No tests reference `showExactResults` directly.

## Constraints
- Do not alter partial or fuzzy filtering logic.
- Do not change any other settings.
- No new abstractions or helpers.

## How we'll know it's done
- `grep -r showExactResults lib/` returns no results.
- The settings panel no longer shows an "Exact results" row.
- Exact results always appear in search regardless of any stored preference.

## What's not included
- Fixing partial/fuzzy filtering for secondary/root results (separate concern).
- Migrating or clearing the orphaned SharedPreferences key `show_exact_results`.
