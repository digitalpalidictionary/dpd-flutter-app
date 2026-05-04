## Architecture Decisions
- Mirror Python exactly. `isNipata` getter symmetrical with `isSamyutta` in shape.
- Add the AN nipāta branch in `scVaggaLink` BEFORE the generic `sc_vagga` slug logic.
- Reuse `_multiLinkRow` with a single `('SC Nipāta Card', s.scVaggaLink)` entry.

## Phase 1 — isNipata + scVaggaLink

- [x] Add `isNipata` getter to `SuttaInfoExtensions` in `lib/database/sutta_info_extensions.dart`.
  → verify: guards match Python; "." or "-" in dpd_code → false; name contains "nipāta" → true.

- [x] Add AN nipāta branch in `scVaggaLink` (after SN saṃyutta block, before generic sc_vagga block).
  → verify: AN1 → `https://suttacentral.net/pitaka/sutta/numbered/an/an1`.

## Phase 2 — Button label + SC link

- [x] Update `entry_sections_mixin.dart` button label: add `isNipata` between `isVagga` and 'sutta'.
  → verify: order is `isSamyutta ? 'saṃyutta' : isVagga ? 'vagga' : isNipata ? 'nipāta' : 'sutta'`.

- [x] Update `sutta_info_section.dart` Links row: insert nipāta branch between saṃyutta and default.
  → verify: ordering matches webapp template.

## Phase 3 — Verification

- [x] Run `flutter analyze` — zero new warnings.
  → verify: command exits 0.
