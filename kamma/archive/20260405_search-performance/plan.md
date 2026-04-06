# Plan: Search Performance Optimization

**Spec:** [./spec.md](./spec.md)
**Status:** Complete

## Phase 1: Setup & Baseline Measurement
- [x] Add timing instrumentation to search pipeline (debug-only)
  - [x] Instrument DAO layer queries (exact, partial, fuzzy) in `lib/database/dao.dart`
  - [x] Instrument search providers in `lib/providers/search_provider.dart`
  - [x] Instrument result rendering in `lib/screens/search_screen.dart`
- [x] Create benchmark test script
  - [x] Define test queries: exact match, partial match, fuzzy match, no results
  - [x] Measure: query time, render time, total time, memory
  - [x] Output results in a readable format (console table)
- [x] Run baseline benchmarks and record results
- [x] **Phase 1 Checkpoint:** Review baseline measurements with user

## Phase 2: Benchmark Optimization Approaches
### Approach A: Query Optimization (WINNER)
- [x] Analyze current DAO queries for inefficiencies
- [x] Add missing SQLite indexes
  - [x] Added `PRIMARY KEY (lookup_key)` to mobile_exporter.py
  - [x] Added `idx_lookup_key` index to existing share/dpd-mobile.db
- [x] Optimize LIKE patterns → replaced with range queries (`>=` and `<`)
  - [x] `searchPartial`: LIKE → range query
  - [x] `searchFuzzy`: LIKE → range query
- [x] Benchmark Approach A and record results

### Other Approaches (Skipped — Approach A sufficient)
- [x] Approach B (Sequential Tier Loading): Not needed — query optimization already delivers results < 1ms
- [x] Approach C (Rendering Optimization): Not needed — query time was the bottleneck
- [x] Approach D (Combined): Superseded by A alone
- [x] Approach E (Caching): Not needed — sub-millisecond queries make caching unnecessary

- [x] **Phase 2 Checkpoint:** Benchmark comparison presented, Approach A selected

## Phase 3: Implement Fastest Approach
- [x] Implement the winning optimization(s) based on benchmark results
- [x] Ensure all tiers still produce correct results
- [x] Maintain backward compatibility
- [x] Debug instrumentation kept behind `enableSearchTiming` flag (disabled by default)
- [x] Run flutter analyze — no issues
- [x] **Phase 3 Checkpoint:** Verified by user — "passed with flying colours. approved"

## Phase 4: Final Verification & Cleanup
- [x] Run final benchmarks comparing before/after
  - Exact: ~133ms → ~50μs (2,600x faster)
  - Partial: 15-182ms → 200-250μs (96-99% faster)
  - Fuzzy: 175-226ms → 75-90μs (100% faster)
- [x] Verify all success criteria from spec are met
- [x] Update `tech.md` if implementation changed any technical assumptions
- [ ] Clean up any temporary code or debug flags
- [ ] Prepare commit message following project conventions
- [ ] **Thread Complete:** Mark ready for `/kamma:3-review`
