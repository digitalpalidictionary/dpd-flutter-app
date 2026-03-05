# Plan: Summary Section

## Phase 1: Data & Provider Layer
- [x] Task: Create summary data model (bf81530)
  - [x] Define a SummaryEntry class (type, label, meaning, targetId)
  - [x] Support all result types: headword, root, see, grammar, spelling, variant, etc.
- [x] Task: Build summary provider (eef9114)
  - [x] Create a Riverpod provider that derives summary entries from exact search results
  - [x] Include all lookup categories (headwords, roots, see, grammar, spelling, variants, etc.)
  - [x] Reactively depend on the search query and settings toggle
- [x] Task: Add showSummary setting to settings provider (already existed)
  - [x] Ensure showSummary is persisted via shared_preferences
  - [x] Ensure toggling reactively updates any consumers

## Phase 2: UI Implementation
- [x] Task: Build SummarySection widget (5fe3e5d)
  - [x] Render one-line summary entries matching webapp format (label, type, meaning, ► link)
  - [x] Conditionally display based on showSummary setting
  - [x] Hide when no exact matches exist
- [x] Task: Implement scroll-to-entry on summary tap (5fe3e5d)
  - [x] Assign keys/anchors to each entry in the results list
  - [x] Smooth-scroll to the target entry when a summary link is tapped
- [x] Task: Add showSummary toggle to settings screen (5fe3e5d)
  - [x] Wire toggle to the settings provider for real-time reactive update
- [ ] Task: Conductor - User Manual Verification 'Complete Feature' (Protocol in workflow.md)
