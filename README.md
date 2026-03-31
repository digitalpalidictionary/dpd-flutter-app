# DPD Flutter App

Native offline Flutter app for the [Digital Pali Dictionary](https://dpdict.net).

Beta testing instructions: [`BETA_TESTER.md`](BETA_TESTER.md)

## Features

- Offline dictionary lookup via local SQLite database
- Full-text search with Pāḷi-aware collation and Velthuis transliteration
- Android text selection integration — select any word in any app → "Look up in DPD"
- Entry sections: grammar, examples, inflection/conjugation/declension tables, word families (root, word, compound, idioms, sets), frequency heatmap, notes, feedback
- Material 3 UI with dark/light theme
- Webapp-parity styling matching the DPD webapp dictionary pane

## Tech Stack

- **Flutter/Dart** — latest stable
- **Drift** — type-safe SQLite ORM with code generation
- **Riverpod** — reactive state management
- **flutter_html** — render pre-built HTML content
- **url_launcher** — external links (sutta references, feedback forms)

## Development

### Prerequisites
- Flutter 3.29+
- Android SDK (for device/emulator testing)
- Sibling `dpd-db` repo at `../dpd-db/`

### Setup

```bash
flutter pub get
dart run build_runner build
ln -sf /path/to/dpd-db/dpd.db assets/db/dpd.db
flutter run
```

The app uses the full `dpd.db` in debug mode (via hardcoded dev path).
In production it downloads `mobile.db` from GitHub Releases.

### Code Generation

After changing `lib/database/tables.dart` or any Riverpod provider:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Spec-Driven Development

This project uses Conductor for spec-driven development. Tracks, specs, and plans live in `conductor/`.

```bash
conductor/
├── product.md              # Product vision and goals
├── product-guidelines.md   # Visual identity and UX guidelines
├── tech-stack.md           # Packages and platform targets
├── tracks.md               # Master track list
├── tracks/                 # Active tracks
└── archive/                # Completed tracks
```

## Bundle ID

`net.dpdict.app`
