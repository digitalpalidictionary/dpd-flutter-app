## Overview
Mirror the recent dpd-db `is_nipata` change in the Flutter app. AN nipāta entries (AN1–AN11) currently show a "vagga" button — they should show "nipāta" instead, and their SC link should target the AN nipāta card.

Reference: dpd-db commit 10fc6760 "#236 nipāta: add AN nipāta support to SuttaInfo sc_vagga_link and templates".

## What it should do
- `SuttaInfoExtensions.isNipata` returns true when:
  - `dpd_sutta` or `dpd_sutta_var` contains "nipāta", AND
  - `dpd_code` has no "." or "-"
- `scVaggaLink` for AN entries with `isNipata` returns `https://suttacentral.net/pitaka/sutta/numbered/an/an{N}` (extracted from `AN{N}` dpd_code).
- Sutta-section toggle button label resolution becomes: saṃyutta → vagga → nipāta → sutta.
- In `SuttaInfoSection`, when `isNipata` and `scVaggaLink != null`, the "Links" row shows `SC Nipāta Card`.

## Assumptions & uncertainties
- Field-hide guards (Vagga/Sutta rows in CST/SC/BJT tables) do not need `!isNipata` — the Python webapp omits this guard too because those fields are blank for AN nipāta rows.
- Order: `is_samyutta` → `is_vagga` → `is_nipata` → fallback.
- Nipāta shows SC card link only (no Pāḷi/English translation links), matching saṃyutta pattern.

## Constraints
- Keep `isNipata` consistent with Python: same string-matching, same dpd_code guards.
- Do not touch unrelated logic.

## How we'll know it's done
- AN1–AN11 entries show button label "nipāta" and "SC Nipāta Card" link to the correct SC URL.
- SN/MN/DN entries are unaffected.
- AN suttas with dotted/hyphenated dpd_code still show "sutta".

## What's not included
- Field-hide guards (`!isNipata` in CST/SC/BJT vagga/sutta rows) — fields are blank.
- Backend DB rebuild.
