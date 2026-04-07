---
name: Settings safe area fix
description: Fix settings bottom sheet being hidden by Android navigation controls
type: bug
---

## Overview
Settings bottom sheet content is hidden behind Android navigation controls.

## What it should do
The settings bottom sheet must respect Android's safe area insets so no
content is obscured by the system navigation bar (gesture bar or button bar).

## Constraints
- One-line fix preferred; no fixed pixel values
- Must adapt to gesture nav, 3-button nav, and no-nav-bar (tablet/Linux) layouts

## How we'll know it's done
On a device with Android navigation controls, the full settings panel is visible
and scrollable with nothing cut off at the bottom.

## What's not included
- Changing the settings panel layout or content
- Any other screen's SafeArea handling
