# Product Guide — DPD Flutter App

## Initial Concept

A native offline Flutter app for the Digital Pāḷi Dictionary (DPD).

## Vision

Bring the full power of the Digital Pāḷi Dictionary to mobile devices as a fast, offline-first native app. The app replicates the style and functionality of the existing DPD GoldenDict and DPD webapp exports, combining the speed and offline capability of GoldenDict with the visual design and interactive layout of the webapp dictionary pane. Feature parity with the exports will be achieved incrementally, track by track.

## Primary Goals

1. **Offline-first Pāḷi dictionary** — Fast, reliable dictionary lookup without internet, replacing GoldenDict for mobile users. Sub-100ms search response using a local SQLite database.
2. **Android system integration** — Select any Pāḷi word in any app and look it up instantly via Android's ACTION_PROCESS_TEXT text selection integration.
3. **Monthly-updated dictionary** — Keep the dictionary fresh with automated DB updates downloaded from GitHub Releases.
4. **Replicate DPD export style** — Match the visual design, layout, and interactive patterns of the DPD webapp dictionary pane and the comprehensive entry structure of the GoldenDict export. Feature parity will be added incrementally.

## Target Users

- Pāḷi students and scholars
- Buddhist monastics and practitioners reading Pāḷi texts
- Anyone using GoldenDict for Pāḷi lookup who wants a native mobile experience

## Core Features

### Search
- Live search with 300ms debounce
- Velthuis live transliteration on keystroke (aa→ā, .m→ṃ, etc.)
- Pāḷi-aware alphabetical sort order
- Results displayed as compact word cards (lemma, pos, meaning)

### Entry Display
Mirrors the DPD webapp sibling-based hierarchy (Lemma > Summary > Buttons > Sections):
- **Lemma** — Headword title (h3 equivalent), no border, bold weight 700.
- **Summary box** — pos, meaning, literal meaning (continuous paragraph, 2px blue border).
- **Buttons** — Sibling button box for section toggles (filled cyan, 9.0 radius).
- **Sections** — Separate bordered containers for expandable detail (grammar, examples, tables, etc.).

...

## Design Reference

The **DPD webapp dictionary middle pane** is the primary visual reference:
- Primary color: Cyan `hsl(198, 100%, 50%)` / `#00BFFF`.
- Default font: Inter (sans-serif) with 1.5 line height.
- Hierarchical layout with separate bordered boxes for summary and active sections.
- 2px solid primary-color borders (blue in light mode, gray-transparent in dark).
- 9.0 border-radius (optimized for visual match with 7px CSS borders).
- Shadow elevation on buttons (shadow-default / shadow-hover).
- Dark mode support with exact webapp background and text colors.

## Platform Target

- Android (primary)
- Chromebook (via Play Store)
- iOS (stretch goal)
