# Back Button History Navigation

## Overview
Change the Android Back button to navigate search history (same as the back arrow in the toolbar) instead of clearing the screen.

## What it should do
- Android Back button navigates to the previous search in history (identical to the back arrow button)
- When there's no more history to go back through AND no active overlays/popups, the system back exits the app normally
- Active overlays (Velthuis help popup, info overlay) should still be dismissed by back before history navigation kicks in
- The back arrow button in the toolbar continues to work exactly as before

## Constraints
- Only affects Android (the `Platform.isAndroid` guard stays)
- Must not break the existing back arrow button behavior
- Must not break overlay/popup dismissal on back press

## How we'll know it's done
- Pressing Android Back after searching multiple terms steps back through each previous search
- When history is exhausted, pressing Back exits the app
- Pressing Back while an overlay is open dismisses the overlay first
- Back arrow button in toolbar still works identically

## What's not included
- No changes to forward navigation
- No changes to history provider logic
- No iOS-specific changes
