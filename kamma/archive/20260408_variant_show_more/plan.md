# Plan

## Phase 1: Implement collapsible variant table
- [x] Convert `_VariantTable` from `StatelessWidget` to `StatefulWidget`
- [x] Count total data rows; if >10, build only the first 10 rows when collapsed
- [x] Add a "show more (N remaining)" / "show less" toggle below the table
- [x] Style the toggle link using theme colors consistent with the app

## Phase 2: Verification
- [x] Static analysis passes
- [x] Verify variant cards with few rows still render normally
- [x] Verify long variant cards collapse and expand correctly
