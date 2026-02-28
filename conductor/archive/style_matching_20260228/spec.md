# Spec: Match App Styles with the DPD Webapp

## Goal

Align the Flutter app's visual styling to exactly match the DPD webapp dictionary pane. The app should feel like a native mobile version of the webapp.

## Reference

- **Webapp CSS:** `/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/webapp/static/dpd.css`
- **Webapp Layout:** `/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/webapp/static/home.css`
- **Webapp Templates:** `/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/webapp/templates/`
- **GoldenDict Templates:** `/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/goldendict/templates/`
- **Product Guidelines:** `conductor/product-guidelines.md`

...

## Component Styles

### Entry Hierarchy (Sibling-based)
1. **Lemma (h3)**: No border, bold weight 700.
2. **Summary Box (.dpd.summary)**: 
   - Contains: POS, Plus Case, Meaning, Summary.
   - Border: 2px solid primary (light) / gray-transparent (dark).
   - Radius: 9.0 (visual match for 7px).
   - Padding: 3px 7px.
3. **Button Box (.button-box)**: 
   - Sibling below Summary Box.
   - Flex-wrap: wrap.
   - Margin: 2px 0px 3px 0px.
4. **Section Content (.dpd.content)**:
   - Separate bordered container per section.
   - Border: 2px solid primary (light) / gray-transparent (dark).
   - Radius: 9.0.
   - Background: surfaceContainerHighest (0.5 alpha).

### Buttons (.dpd-button)
- Background: primary
- Border: 1px solid primary
- Border-radius: 7px
- Color: dark (dark text on cyan)
- Font-size: 80%
- Font-weight: 400
- Padding: 2px 5px
- Margin: 1px 1px 2px 1px
- Shadow: shadow-default
- **Hover/Active:** background primary-alt, border primary-alt, color light, shadow shadow-hover

### Button Box
- Display: flex, flex-wrap: wrap
- Justify: flex-start
- Margin: 2px 0px 3px 0px

### Inflection Tables
- Width: 100%
- Border-radius: 7px (corners)
- Border-collapse: separate
- Cell border: 1px solid gray
- Cell padding: 5px
- Header border: 1px solid primary
- Header color: primary-text
- Header weight: 700
- Text-align: center

### Frequency Tables
- Border-radius: 7px
- Cell min-width: 30px / 2.5em
- Cell font-size: 0.8em
- Cell border: 1px solid gray-transparent
- Heatmap: gr1–gr5 dark text, gr6–gr10 light text

### Summary/Grammar Tables
- No borders
- Header color: primary-text
- Header weight: 700
- Header white-space: nowrap

## Dark Mode

- Toggle: light / dark / system
- Background: `var(--dark)` = `hsl(198, 100%, 5%)`
- Text: `var(--light)` = `hsl(198, 100%, 95%)`
- Primary accent color remains unchanged
- Search box: dark background, light text, gray-transparent border
- Borders on containers become gray-transparent in dark mode

## Current State (What Needs to Change)

| Item | Current | Target |
|------|---------|--------|
| Primary color | `#00BFFF` | `hsl(198, 100%, 50%)` — already correct |
| Font | Inter via Google Fonts | Already correct |
| Border-radius | Mixed (8px, 16px, 2px) | 7px everywhere |
| Border width | 3px left accents | 2px full or left borders |
| Button style | TextButton minimal | Filled cyan, 7px radius, shadow, 80% font |
| Dark mode | Material 3 auto | Custom colors matching webapp variables |
| Entry container | Left-border only cards | 2px full border, 7px radius |
| Button box | Vertical or mixed | Flex-wrap horizontal row |

## Scope

- Theme definition (colors, typography)
- All border radii standardized to 7px
- Button styles matching webapp
- Entry container borders matching webapp
- Dark mode colors matching webapp
- Search input styling
- Bottom sheet / entry screen styling

## Out of Scope

- Adding new sections or features
- Database changes
- New screens or navigation
- Functionality changes
