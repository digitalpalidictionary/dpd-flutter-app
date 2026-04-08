# Plan: Back Button History Navigation

## Phase 1: Implement Back Button History Navigation

- [x] Task 1.1: Refactor `_hasActiveBackInterceptState()` to return true when there are overlays, popups, OR history to go back through
- [x] Task 1.2: Refactor `onPopInvokedWithResult` to handle back presses in priority order:
  1. Dismiss overlays/popups first (info overlay, Velthuis help)
  2. Navigate history back (same logic as the back arrow button)
  3. Only allow app exit when none of the above apply
- [x] Task 1.3: Verification — confirm back arrow button in toolbar still works identically (no changes to that code path)
