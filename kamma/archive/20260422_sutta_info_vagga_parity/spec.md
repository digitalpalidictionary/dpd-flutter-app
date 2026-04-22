# Spec — Sutta Info parity: vagga, saṃyutta, paṇṇāsaka, etc.

## GitHub Issue
dpd-db #192

## Overview
The DPD webapp (`dpd-db/exporter/webapp/templates/dpd_headword.html` + `db/models.py`)
was recently updated to treat DN vaggas, MN paṇṇāsakas, SN saṃyuttas and
related sutta-subdivision rows as first-class entries in the sutta info tab.
The Flutter app currently treats every sutta_info row as a regular sutta —
wrong label on the section button, shows irrelevant rows (e.g. "Sutta" for a
vagga row), and links to a sutta-level SC card that does not exist. This
thread brings behaviour parity.

## What it should do
1. Section button label: "sutta" | "vagga" | "saṃyutta" depending on row type.
2. Hide sutta-only fields for vagga rows (CST Sutta, SC Sutta/Title/Blurb, BJT Sutta).
3. Hide both sutta-only and vagga-only fields for saṃyutta rows (also CST/SC/BJT Vagga).
4. DV catalogue + Parallels sections are hidden for vagga and saṃyutta rows.
5. Links row: build a new `scVaggaLink` and show:
   - is_vagga  → "SC Vagga Card", Pāḷi Text, English Translation
   - is_samyutta → "SC Saṃyutta Card" only
   - else → existing SC Card + Pāḷi + English

## Repo context
- Widget: `lib/widgets/sutta_info_section.dart`
- Extensions: `lib/database/sutta_info_extensions.dart` (scCardLink, tbw, etc.)
- Button wiring: `lib/widgets/entry_sections_mixin.dart` (label hard-coded "sutta")
- Table: `lib/database/tables.dart` — SuttaInfo has dpdSutta, dpdSuttaVar, dpdCode,
  bookCode, cstVagga, scVagga, bjtVagga fields already present.

## Assumptions & uncertainties
- The Flutter DB is rebuilt from the dpd-db TSV, so vagga/saṃyutta rows exist
  once the user ships a new db bundle. This thread implements only the
  client-side behaviour; no schema change.
- `is_vagga` / `is_samyutta` / `scVaggaLink` are reproduced as Dart getters on
  `SuttaInfoData`, mirroring the Python `cached_property` logic verbatim
  (including the SN saṃyutta slug map and diacritic-stripping).
- No UI tests (per AGENTS.md).

## Constraints
- Native Flutter widgets only (no HTML for DPD content).
- Use existing DpdSectionButton / theme colours.
- Keep _linkRow / _multiLinkRow patterns.

## How we'll know it's done
- Entry for a vagga row shows button "vagga", no CST/SC/BJT "Sutta" rows, SC Vagga Card link.
- Entry for a saṃyutta row shows button "saṃyutta", no Vagga/Sutta rows, "SC Saṃyutta Card" link.
- Regular sutta rows behave unchanged.

## Not included
- Changing SuttaInfo schema.
- Goldendict exporter parity (separate dpd-db concern).
- Rebuilding the bundled DB.
