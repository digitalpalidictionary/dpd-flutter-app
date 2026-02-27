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
Mirrors the DPD webapp/GoldenDict entry structure with button-driven expandable sections:
- **Summary box** — pos, meaning, literal meaning, construction (always visible, cyan left border)
- **Audio** — Pronunciation playback (conditional, male/female variants)
- **Sutta Info** — CST code, Sutta Central references, BJT references, external links
- **Grammar** — Full morphological detail table (root, base, construction, compound type, derivative, phonetic changes, cognates, etc.)
- **Example(s)** — Up to 2 example sentences with sutta source citations
- **Conjugation / Declension** — Pre-rendered HTML inflection tables with grayed-out unattested forms
- **Root Family** — Words derived from the same root
- **Word Family** — Words in the same word family
- **Compound Family/Families** — Compound groupings containing the word
- **Idioms** — Idiomatic expressions containing the word
- **Set(s)** — Thematic set memberships
- **Frequency** — Corpus occurrence heatmap across multiple collections
- **Feedback** — Link to report errors/omissions

### Settings
- Dark/light/system theme
- Font toggle: Sans-serif (Inter) / Serif (Noto Serif)
- Font size adjustment
- Default section open/closed preferences
- Database version info and update management

### Platform Integration
- Android ACTION_PROCESS_TEXT intent — "Look up in DPD" in text selection popup
- First-launch database download with progress indicator
- Monthly update check via GitHub Releases API

## Design Reference

The **DPD webapp dictionary middle pane** is the primary visual reference:
- Primary color: Cyan `hsl(198, 100%, 50%)` / `#00BFFF`
- Default font: Inter (sans-serif)
- Button-driven expandable sections with toggle visibility
- 2px solid primary-color borders, 7px border-radius
- Shadow elevation on buttons
- Dark mode support with inverted background, same primary accent

## Platform Target

- Android (primary)
- Chromebook (via Play Store)
- iOS (stretch goal)
