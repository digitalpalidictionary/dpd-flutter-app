# s.4nt.org Link in Sutta Info

## Overview

The DPD website and GoldenDict exporter both show an "s.4nt.org" link in the sutta info's "Websites using Sutta Central" table (alongside The Buddha's Words, Dhamma.gift, SC Express, SC Voice). The Flutter app's sutta tab is missing this row. Add it, computed the same way the Python exporter computes it.

## What it should do

- Add an `s.4nt.org` link row to the existing "Websites using Sutta Central" table in `lib/widgets/sutta_info_section.dart`, directly after the "SC Voice" row.
- The link must be computed with the exact same rules as `SuttaInfo.s_4nt_link` in `../dpd-db/db/models.py` (lines 920-955), since there is no raw DB column for it — the website/goldendict exporters compute it too.
- Row only appears when the computed link is non-null (same gating pattern as the other rows in that table, via `_notEmpty`/`buildKvLinkRow`).

## Algorithm (ported from `../dpd-db/db/models.py`)

Given `scCode` and its derived `sc_book_code` (already available in the app as `_scBookCode`):

- No `scCode` or no book code → no link.
- Book code (trailing hyphens stripped, lowercased) `dn` or `mn` → `https://s.4nt.org/{book}/{code}/index.html` (one page per sutta, `code` = lowercased `scCode`).
- Book code `sn` or `an` → one page per saṃyutta/nipāta:
  - Extract the leading number from `code` (e.g. `sn12` from `sn12.83`); if it doesn't match, no link.
  - Bare nipāta-only code (e.g. `an5` with nothing after) → `https://s.4nt.org/{book}/{book}{n}/index.html`, no fragment.
  - Otherwise → same URL + `#{fragment}`, where `fragment` is normally `code` but overridden for 24 sc_codes listed in `_S4NT_ANCHOR_OVERRIDES` (peyyala-compressed sutta runs where the site groups several DPD rows under one anchor).
- Book code is one of the 20 KN book codes (`kp, dhp, ud, iti, snp, vv, pv, thag, thig, ja, mnd, cnd, ps, ne, pe, cp, bv, mil, tha-ap, thi-ap`) → `https://s.4nt.org/kn/{book}/index.html#{fragment}`, same override map (21 DHP vagga-range entries here).
- Anything else → no link.

The override map is 45 entries total (2 AN, 26 DHP, 17 SN) and must be copied verbatim from `_S4NT_ANCHOR_OVERRIDES` in `models.py` — it was derived by cross-checking every sc_code in dpd.db against the site's real anchor ids, not guessed.

## Constraints

- Pure Dart port, no new dependency, no raw DB column — mirrors how `scVoiceLink`/`scExpressLink`/`tbw` etc. are already computed getters in `lib/database/sutta_info_extensions.dart`.
- Reuse the existing `_scBookCode` getter rather than duplicating book-code extraction.
- No UI test (project convention: no UI tests, only data-logic tests).
