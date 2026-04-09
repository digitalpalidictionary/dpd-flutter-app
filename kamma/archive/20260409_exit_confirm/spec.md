# Exit Confirmation Dialog on Android Back Button

## Overview
When the user presses the Android back button and there is no more history to navigate,
the app currently exits immediately. This thread adds a confirmation dialog ("Would you
really like to exit?") before the app closes.

## What It Should Do
- When the Android back button is pressed and the action resolves to `exitApp`
  (no overlays, no history), show an AlertDialog asking the user to confirm exit.
- The dialog has two actions: "Cancel" (dismiss the dialog, stay in app) and "Exit"
  (close the app via `SystemNavigator.pop()`).
- On all other back-press actions (dismiss overlay, navigate history), behavior is
  unchanged.

## Constraints
- Keep the change minimal: only touch `search_screen.dart`.
- Reuse the existing `AlertDialog` pattern already used in `history_panel.dart`.
- Do not add new files, utilities, or abstractions.
- Android only — non-Android builds are unaffected.

## How We'll Know It's Done
- Pressing back with history present: navigates back (unchanged).
- Pressing back with an overlay open: dismisses overlay (unchanged).
- Pressing back when no history and no overlay: shows confirmation dialog.
  - Tapping "Exit" closes the app.
  - Tapping "Cancel" dismisses the dialog and returns to the app.

## What's Not Included
- iOS or desktop exit dialogs.
- "Double-tap to exit" pattern.
- Any UI changes beyond the dialog itself.
