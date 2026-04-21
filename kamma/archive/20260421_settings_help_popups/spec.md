# Settings Help Popups

## Overview
Add an information button to each setting so users can quickly see what the setting does without guessing from the label alone.

## What it should do
- Show an `i` button immediately after each setting label and before that setting's control.
- Open a non-full-screen popup when the `i` button is tapped.
- Let the popup scroll if the help content is taller than the available space.
- Explain each setting in simple non-technical English.
- Show example states when that helps make the setting clearer.
- Close the popup when the user taps outside it or presses back.

## Constraints
- Reuse the existing settings layout and theme patterns.
- Keep the explanation focused on user-visible behavior.
- Do not add UI tests.

## How we'll know it's done
- Every settings row in the settings panel has an info button.
- Each info button opens a dismissible popup instead of a full-screen screen.
- Long help content scrolls cleanly.
- Example states are shown for settings where visual comparison is useful.

## What's not included
- Reworking the settings categories or order.
- Changing the underlying setting behavior.
