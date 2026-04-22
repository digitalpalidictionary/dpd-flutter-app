# Plan — Sutta Info parity (issue dpd-db #192)

## Architecture Decisions
- Port `isVagga`, `isSamyutta`, `scVaggaLink` as getters on
  `SuttaInfoExtensions` in `lib/database/sutta_info_extensions.dart`.
- Gate rows inside `sutta_info_section.dart` using `isVagga` / `isSamyutta`
  local bools; the existing `_table` helper drops null rows.
- Do not introduce a new widget for the links row — pass computed label into `_multiLinkRow`.

## Phase 1 — Dart getters

- [x] Add `isVagga` getter
- [x] Add `isSamyutta` getter
- [x] Add `scVaggaLink` getter (port Python cached_property verbatim)
      → verify: flutter analyze passes

## Phase 2 — UI gating

- [x] Compute `isVagga` / `isSamyutta` in sutta_info_section.dart build()
- [x] CST: hide Vagga row when isSamyutta; hide Sutta row when isVagga||isSamyutta
- [x] SC: hide Vagga when isSamyutta; hide Sutta/Title/Blurb when isVagga||isSamyutta
- [x] Links row: branch on isVagga / isSamyutta / else
- [x] BJT: hide Vagga when isSamyutta; hide Sutta when isVagga||isSamyutta
- [x] DV catalogue + Parallels: hide entirely when isVagga||isSamyutta
      → verify: flutter analyze passes

## Phase 3 — Button label

- [x] entry_sections_mixin.dart: derive label from suttaInfo
      → verify: flutter analyze clean
