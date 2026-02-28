# Plan: Match App Styles with the DPD Webapp

## Phase 1: Theme Foundation [checkpoint: fbc348e]

- [x] Task: Define DPD color constants matching webapp CSS variables (primary, primary-alt, primary-text, light, dark, grays, shadows) 7212126
- [x] Task: Configure Flutter theme with DPD colors for both light and dark modes, replacing Material 3 auto-generated palette 2fdbd17
- [x] Task: Set up typography theme with Inter defaults (line-height 150%, h3 at 130%, button text at 80%, bold weight 700) 52a3b99
- [x] Task: Conductor - User Manual Verification 'Theme Foundation' (Protocol in workflow.md) fbc348e

## Phase 2: Component Styling [checkpoint: 55ea921]

- [x] Task: Standardize all border-radius values to 7px across the app (inputs, cards, containers, bottom sheets) 36a0098
- [x] Task: Style entry containers with 2px solid primary border, 7px radius, 3px 7px padding 285923c
- [x] Task: Style section toggle buttons to match webapp (filled cyan background, 1px border, 7px radius, 80% font, 2px 5px padding, shadow, dark text, active state with primary-alt) 6052088
- [x] Task: Style button box as flex-wrap horizontal row with flex-start justify and correct margins 12a83e3
- [x] Task: Style word cards in search results to match webapp summary appearance 197b5d0
- [x] Task: Conductor - User Manual Verification 'Component Styling' (Protocol in workflow.md) 55ea921

## Phase 3: Tables & Dark Mode [checkpoint: 0f3b708]

- [x] Task: Style inflection tables matching webapp (7px corner radius, 1px gray cell borders, primary header borders, centered text, 5px cell padding) 7b7c22f
- [x] Task: Style frequency heatmap tables with 10-level cyan gradient colors matching webapp 8e1b3a9
- [x] Task: Style grammar/sutta-info tables (no borders, primary-text header color, bold headers, nowrap) 31a2964
- [x] Task: Implement dark mode with exact webapp colors (dark background, light text, gray-transparent borders, primary accent unchanged) a26b4d9
- [x] Task: Conductor - User Manual Verification 'Tables & Dark Mode' (Protocol in workflow.md) 0f3b708

## Phase 4: Final Polish [checkpoint: a48b0a1]

- [x] Task: Style search input to match webapp (primary border, 7px radius, correct padding and focus states) b9c2cab
- [x] Task: Refactor entry hierarchy to sibling-based (Lemma > Summary Box > Buttons > Sections) and align all remaining spacing 292d9b6
- [x] Task: Verify visual parity by comparing app screenshots side-by-side with webapp on same entries a48b0a1
- [x] Task: Conductor - User Manual Verification 'Final Polish' (Protocol in workflow.md) a48b0a1
