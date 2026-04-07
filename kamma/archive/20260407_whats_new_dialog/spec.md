# Spec: What's New Dialog After Update

## Overview
On first launch after an app update, show a "What's changed" dialog with the
GitHub release notes for the current version.

## What it should do
- On startup, compare the running version against the last-seen version stored
  in SharedPreferences.
- If the running version is newer, fetch the release notes for the current
  version tag from GitHub and show a dialog with the tag name, the release
  notes, and a single "OK" button.
- After showing, store the current version as the new last-seen version so the
  dialog only appears once per update.

## Constraints
- No new dependencies (SharedPreferences already used via settings_provider).
- If the fetch fails, skip silently — do not block startup.
- Fetch reuses the existing AppUpdateService / Dio setup.
- Plain Text in a scrollable area — no markdown renderer.

## How we'll know it's done
- On first launch after an update, the dialog appears with version tag and release notes.
- Tapping OK dismisses it and it does not appear again.
- If no update occurred, the dialog does not appear.

## What's not included
- Markdown rendering.
- Showing notes again after the user taps OK.
