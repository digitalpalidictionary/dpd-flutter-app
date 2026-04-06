# Spec: Search Performance Optimization

**Thread ID:** 20260405_search-performance  
**GitHub Issue:** [#3](https://github.com/digitalpalidictionary/dpd-flutter-app/issues/3)  
**Type:** Performance Optimization  
**Priority:** High

## Overview

Currently, search results take 3-4 seconds to appear. This is too slow for a dictionary app where users expect near-instant feedback. This thread will benchmark multiple optimization approaches and implement the fastest combination.

## What It Should Do

### Primary Goals
- **Exact matches**: As fast as possible, prioritized above all else
- **Partial matches**: Fast, but secondary to exact
- **Fuzzy matches**: Fast, but lowest priority
- Overall: First results visible to user in < 500ms

### Approach: Benchmark Multiple Options
We will create and test several optimization strategies, measure each, and implement the fastest:

1. **Query optimization only**: Better SQL, added indexes, optimized LIKE patterns
2. **Sequential tier loading**: Exact → partial → fuzzy (display each as ready)
3. **Rendering optimization only**: Faster widget construction, lazy section loading
4. **Query + rendering combined**: Best of both worlds
5. **Aggressive caching**: Cache recent results, pre-compute common queries

Each approach will be benchmarked with:
- Query execution time (ms)
- Time to first render (ms)
- Time to all results rendered (ms)
- Memory usage impact

### Technical Areas to Explore
- Database query optimization in `lib/database/dao.dart`
- Adding missing SQLite indexes
- Sequential vs parallel tier execution
- Widget construction optimization
- ListView performance (current `cacheExtent: 5000` may be excessive)
- Lazy loading of entry sections (grammar, inflections, etc.)
- Result caching strategies

## Constraints

- Must maintain backward compatibility with existing database schema
- Cannot change the Lookup table structure (used by mobile exporter)
- Must work with current Drift/SQLite setup
- First priority: Android performance
- Must not break existing search functionality

## How We'll Know It's Done

### Success Criteria
- [ ] Benchmark results documented with before/after measurements
- [ ] Fastest approach implemented and verified
- [ ] All existing tests pass
- [ ] Manual testing confirms results quality is unchanged
- [ ] No performance regression on edge cases

### Measurement
- Add timing instrumentation to search pipeline (debug-only)
- Test with realistic queries (short, long, exact, partial, fuzzy)
- Use Dart DevTools performance profiling
- Target database: current dpd-mobile.db

## What's Not Included

- Changes to database schema or mobile exporter
- Modifications to autocomplete functionality (separate concern)
- UI/UX redesign of search screen layout
- Changes to display modes (classic/compact)
- Network-related optimizations (this is local-only)
