# Tech Stack — DPD Flutter App

## Framework

| Component | Version | Notes |
|-----------|---------|-------|
| Flutter | Latest stable | Always keep up to date with the latest stable release |
| Dart SDK | Latest stable | Matches Flutter stable channel |

## Dependencies

### Database
| Package | Purpose |
|---------|---------|
| drift | Type-safe SQLite ORM with code generation |
| drift_flutter | Flutter integration for Drift |
| sqlite3_flutter_libs | Native SQLite bindings for all platforms |

### State Management
| Package | Purpose |
|---------|---------|
| flutter_riverpod | Reactive state management |
| riverpod_annotation | Annotation-based provider code generation |

### UI
| Package | Purpose |
|---------|---------|
| google_fonts | Inter and Noto Serif font loading |
| percent_indicator | Progress bar for database download |
| cupertino_icons | iOS-style icons |
| flutter_widget_from_html | HTML rendering for external dictionary entries (Cone, CPD, etc.) via `DictHtmlCard` widget |
| html | DOM parsing for `customStylesBuilder` CSS class-to-style mapping |

### Audio
| Package | Purpose |
|---------|---------|
| audioplayers | HTTP audio streaming for word pronunciation playback |

### Networking
| Package | Purpose |
|---------|---------|
| dio | HTTP client for database download and GitHub Releases API |

### Storage & Utilities
| Package | Purpose |
|---------|---------|
| path_provider | Platform-specific file system paths |
| path | File path manipulation |
| shared_preferences | Persistent user settings |
| url_launcher | Open external links (sutta references, dpdict.net) |

## Dev Dependencies

| Package | Purpose |
|---------|---------|
| flutter_test | Flutter testing framework |
| flutter_lints | Lint rules |
| drift_dev | Drift code generation |
| build_runner | Dart code generation runner |
| riverpod_generator | Riverpod provider code generation |

## Platform Targets

| Platform | Status |
|----------|--------|
| Android | Primary |
| Chromebook | Via Play Store |
| iOS | Stretch goal |
