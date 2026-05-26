# Spec: Sans/Serif labels in their own fonts

## Overview
In Settings → Font, the toggle has two buttons: "Sans" and "Serif". Right now both labels render in whichever font is currently selected (Inter or Noto Serif), so a user reading "Serif" while sans is active sees "Serif" written in sans. The labels should always show in their own font so the contrast is visible at a glance.

## What it should do
- The "Sans" button label is always rendered in the sans font (Inter, via `GoogleFonts.inter`).
- The "Serif" button label is always rendered in the serif font (Noto Serif, via `GoogleFonts.notoSerif`).
- The selected state, sizing, color, and segmented behavior remain unchanged.

## Assumptions & uncertainties
- The two fonts are already in use in `lib/app.dart:179-196`: `GoogleFonts.interTextTheme` (sans) and `GoogleFonts.notoSerifTextTheme` (serif). I'll use `GoogleFonts.inter()` and `GoogleFonts.notoSerif()` to get matching `TextStyle`s for individual labels.
- `CompactSegmented` accepts a Widget as the segment label, so a `Text` with an explicit `style` will pass through the segmented control without breaking the existing layout. To be confirmed — if it forces its own style, I'll need to use the segment's `style` builder instead.

## Constraints
- Only the Font setting's two labels are affected. No other settings labels change.
- No new dependencies; `google_fonts` is already a dep.
- No theme/colour changes.

## How we'll know it's done
- Switch the Font setting to Sans → "Serif" label still looks serif; "Sans" label looks sans.
- Switch to Serif → both labels still look like their own font (Sans still sans, Serif still serif).

## What's not included
- No change to the actual reading font behavior.
- No changes to other segmented controls.
