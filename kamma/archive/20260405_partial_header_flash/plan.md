# Plan: Fix Partial Results Header Flash

## Phase 1: Fix the divider logic
- [x] Task 1.1: Update `showPartialDivider` to only be true when `tier2.isNotEmpty`
- [x] Task 1.2: Adjust spinner to only show when `showPartialDivider && widget.partialLoading`
- [x] Task 1.3: Verify the fix — no header/spinner appears when tier2 is empty
