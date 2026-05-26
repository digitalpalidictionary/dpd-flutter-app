# Spec: Separate UI font size from results font size

## Overview
The Font size slider currently scales every piece of text in the app via a
global `MediaQuery(textScaler: TextScaler.linear(fontSize/16))` applied at
the app root (lib/app.dart:236-244). At 23pt this breaks the UI:
- "Digital Pāḷi Dictionary" header wraps to two lines
- Settings rows overflow
- The Settings panel and other chrome become unusable

## What it should do
- UI chrome (search-screen header, Settings panel, AppBars, dialogs,
  buttons, tooltips, footers) stays at its designed size regardless of the
  Font size slider value.
- The Font size slider scales only "results-area" content:
  - Search results (the `_buildBody` output in search_screen.dart — exact,
    partial, fuzzy, root, secondary, dict tiles, EmptyPrompt,
    NoResultsWithSuggestions, SplitResultsList)
  - EntryScreen body (lemma title + entry sections)
  - RootScreen body (root info + family tables)
- Slider range stays 12-24. The label in Settings is renamed to
  "Results font size" so its scope is clear.

## Assumptions & uncertainties
- The lemma title in EntryScreen's SliverAppBar is treated as *content*,
  not chrome — it's the entry itself. It will scale with the slider.
  Same for the root key in RootScreen's SliverAppBar.
- The bottom FeedbackFooter / DownloadFooter are UI chrome and stay fixed.
- History panel is UI chrome and stays fixed.
- The 16pt baseline matches the default Material text theme used in
  lib/app.dart's `buildTextTheme` — confirmed by the `scale = fontSize / 16`
  formula already present.

## Constraints
- Must not change any other Settings behavior.
- Must not affect system accessibility text scaling — if the user has OS-
  level scaling on, we should respect it for UI (system default) while the
  slider stacks on top for content.

## How we'll know it's done
- Set slider to 24. Open search screen: header, settings cog, search box,
  footer all look identical to 16pt.
- Type a query: result tiles are large.
- Open an entry: AppBar title + body are large; bottom footer is normal.
- Open Settings: every row reads cleanly; no two-line wrap, no overflow.
- Set slider to 12: results shrink; UI chrome stays the same.

## What's not included
- No second slider for UI size.
- No per-section font controls.
- No change to `useSerifFont`, niggahīta, theme, or any other setting.
