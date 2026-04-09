# Plan: Exit Confirmation Dialog

## Phase 1 — Intercept and confirm exit

### Task 1.1 — Always intercept back press on Android [x]
File: `lib/screens/search_screen.dart`

Change `_hasActiveBackInterceptState()` so it always returns `true` on Android,
causing `canPop: false` at all times on Android. This routes the `exitApp` case
through `_handleAndroidBackPress()`.

Before:
```dart
bool _hasActiveBackInterceptState() {
  return _androidBackAction() != AndroidBackAction.exitApp;
}
```

After:
```dart
bool _hasActiveBackInterceptState() {
  return Platform.isAndroid || _androidBackAction() != AndroidBackAction.exitApp;
}
```

### Task 1.2 — Show confirmation dialog for exitApp [x]
File: `lib/screens/search_screen.dart`

Handle `AndroidBackAction.exitApp` in `_handleAndroidBackPress()` by showing an
AlertDialog. On confirm, call `SystemNavigator.pop()`.

Add a `BuildContext context` parameter to `_handleAndroidBackPress` and pass
`context` from the `PopScope.onPopInvokedWithResult` callback.

### Task 1.3 — Verification [x]
- Run `flutter analyze` and confirm no errors in changed files.
- Confirm `_hasActiveBackInterceptState()` still returns false on non-Android.
