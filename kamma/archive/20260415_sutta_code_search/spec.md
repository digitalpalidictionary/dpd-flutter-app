## Overview
Sutta code searches (e.g. "mn12", "MN12", "sn3.12", "SN3.12") return no direct/exact
results — only fuzzy results. The webapp handles this correctly using case-insensitive
matching (ILIKE). The Flutter app uses case-sensitive equals().

## What it should do
- Searching "mn12", "MN12", "Mn12" etc. returns the exact match for MN12
- Searching "sn3.12", "SN3.12" returns the exact match for SN3.12
- All existing Pali word searches continue working identically

## Assumptions & uncertainties
- Pali lookup_keys are already lowercase, so COLLATE NOCASE won't change behavior
- SQLite COLLATE NOCASE covers ASCII case folding — sufficient for sutta codes

## Constraints
- Code-only fix, no DB rebuild
- Don't break existing Pali word search behavior

## How we'll know it's done
- Exact search for "mn12" returns results
- Exact search for "SN3.12" returns results
- Pali searches ("dhamma", "kamma") still work

## What's not included
- No fuzzy search changes (already works via lowercased fuzzy_key)
- No DB-side changes
