# Spec: Remove "Update Now" button from settings

## Overview
Remove the "Update Now" button from the settings panel. Both DB and app update checks already fire automatically on every app startup, making the button redundant. The button was confusing users (closes #4).

## What it should do
- The "Update Now" button is removed from the settings panel.
- No manual update trigger remains in the UI.
- Auto-updates on startup continue to work as before.

## Constraints
- Do not remove or break the underlying auto-update logic in `database_update_provider.dart` or `app_update_provider.dart`.
- Clean up any dead imports or state watches in `settings_panel.dart` that existed solely for the button.

## How we'll know it's done
- Settings panel no longer shows an "Update Now" button.
- No dead code (unused imports, unused watchers) left behind.
- `flutter analyze` passes with no issues.

## What's not included
- Changes to how auto-updates work.
- Any UI changes beyond removing the button.
