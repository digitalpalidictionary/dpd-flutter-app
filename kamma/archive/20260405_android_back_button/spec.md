# Thread: Android Back Button Navigation

## Overview
The DPD Flutter app currently has no Android back button handling. When users press the Android back button, the app quits immediately instead of providing helpful navigation behavior.

## What it should do
When the user presses the Android back button, it should clear all active UI state before allowing the app to exit:
- Clear the current search query
- Remove any open overlays (autocomplete dropdown, velthuis help, info popup)
- Close active info content views (bibliography, thanks)
- Reset the search state
- Return focus to the search field

This mirrors what the X (clear) button does for search state. The back button extends this to also close overlays and info content views.

If no active state remains (no query, no overlays, no open panels), the back button should allow the default Android behavior (which may exit the app).

## Constraints
- Must work on Android only (iOS behavior is out of scope; non-Android platforms must keep current behavior)
- Should use Flutter's `PopScope` widget to intercept back button presses
- Must not interfere with modal sheets (settings/history overlays on mobile) which already have their own dismiss behavior
- X button behavior must remain unchanged — back button shares the outcome, not the code path
- Should follow existing code patterns and use the existing `_onClear()` method as part of the clear sequence

## What counts as active state (intercepts back before exit)
- Search query is non-empty
- Autocomplete dropdown is visible
- Velthuis help overlay is visible
- Info popup overlay is visible
- Active info content view is open (bibliography or thanks)

## How we'll know it's done
- Pressing Android back button with any active state clears that state
- Pressing Android back button with no active state allows app to exit normally
- No regressions to existing functionality (X button, double-tap word search, modal sheets, etc.)
- Non-Android platforms behave identically to before

## What's not included
- iOS back button behavior (handled by system gestures)
- Search history navigation (going back through previous searches)
- Navigation between EntryScreen/RootScreen routes (those routes are currently unused)
- Settings/history side panels on Android (those are modal sheets with their own back handling)
