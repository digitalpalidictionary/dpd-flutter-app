## Overview
Adjust the sūriya dark palette in the DPD Flutter app to better match
the warmth and saturation balance of the Anki DPD card theme.

## What it should do
Update `suriyaDark` in `lib/theme/schemes/suriya.dart` so that:
- Background (`dark`, `darkShade`) is deeper and more saturated warm-black
- Body text (`light`, `lightShade`) is warm cream rather than near-neutral grey
- Primary highlight is more vivid and brighter golden
- Deep accent (`primaryAlt`) is richer/more saturated amber
- `suriyaLight` is NOT touched
- All other palettes (tina, purana, dhuma, kapila) are NOT touched

## Assumptions & uncertainties
- Only `suriyaDark` needs changes — confirmed by user
- `light`/`lightShade` in dark palette = body text/surface on dark bg, safe to saturate
- No Flutter tests exist for theme colours (visual-only verification)
- Changes are purely cosmetic — no logic or layout impact

## Constraints
- Stay within the same H=38–46 (golden amber) hue family
- Do not change `suriyaLight`
- Do not touch accent colours — they're already well-balanced
- Do not touch freq colours (separate concern)

## How we'll know it's done
- App runs in dark mode with sūriya theme showing warm cream text on deep warm-black bg
- Primary gold is visibly more vivid than before
- User confirms it looks right

## What's not included
- Light mode changes
- Changes to any other theme
- Accent colour tuning
