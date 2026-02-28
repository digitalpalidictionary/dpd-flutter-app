# DPD Flutter App

Native offline Flutter app for the [Digital Pali Dictionary](https://dpdict.net).

## Features

- Offline dictionary lookup via local SQLite database
- Full-text search with Pāḷi-aware collation
- Android text selection integration — select any word in any app → "Look up in DPD"
- Entry view: grammar, examples, inflection tables, word families
- Material 3 UI with dark/light theme

## Architecture

```
dpd-db (monthly release)
  └── scripts/build_mobile_db.py → mobile.db
        └── GitHub Releases asset
              └── App downloads on first launch
```

## Development

### Prerequisites
- Flutter 3.29+
- Android SDK (for device/emulator testing)

### Setup

```bash
# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build

# Dev: symlink the full DPD database
ln -sf /path/to/dpd-db/dpd.db assets/db/dpd.db

# Run on Android device/emulator
flutter run
```

The app uses the full `dpd.db` in debug mode (via hardcoded dev path).
In production it downloads `mobile.db` from GitHub Releases.

### Code generation

After changing `lib/database/tables.dart` or any Riverpod provider:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Building mobile.db (when ready)

```bash
python scripts/build_mobile_db.py \
  --source ../dpd-db/dpd.db \
  --output assets/db/mobile.db
```

## Bundle ID

`net.dpdict.app`
