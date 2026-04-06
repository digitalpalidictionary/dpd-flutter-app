# Settings Panel Performance Fix

## Overview
Replace the heavy `SegmentedButton` (Material 3) wrapper `CompactSegmented` with a
lightweight custom segmented control. This is the root cause of the ~4 second delay
when opening settings on Android.

## What it should do
- Open the settings panel near-instantly (under 500ms)
- Look visually identical to the current segmented controls
- Work everywhere `CompactSegmented` is used (settings_panel.dart, dict_settings_widget.dart)

## Constraints
- Use theme colors from `Theme.of(context).colorScheme`, never hardcoded
- Keep the same public API: `CompactSegmented<T>(segments, selected, onChanged)`
- Simple, not over-engineered — a stateless row of tappable containers

## How we'll know it's done
- Settings opens fast on Android
- All toggles still work correctly
- Visual appearance matches current design

## What's not included
- No changes to settings layout or features
- No changes to dict settings or providers
