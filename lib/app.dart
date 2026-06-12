import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show AppExitType;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'providers/app_update_provider.dart';
import 'services/app_update_service.dart';
import 'providers/autocomplete_provider.dart';
import 'providers/database_provider.dart';
import 'providers/database_update_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/download_screen.dart';
import 'screens/entry_screen.dart';
import 'screens/root_screen.dart';
import 'screens/search_screen.dart';
import 'services/database_update_service.dart';
import 'services/intent_service.dart';
import 'theme/dpd_palette.dart';
import 'theme/dpd_scheme.dart';

SwitchThemeData _buildSwitchTheme(DpdPalette palette) => SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return palette.dark;
    return null;
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return palette.primary;
    return null;
  }),
);

class DpdApp extends ConsumerStatefulWidget {
  const DpdApp({super.key});

  @override
  ConsumerState<DpdApp> createState() => _DpdAppState();
}

class _DpdAppState extends ConsumerState<DpdApp> {
  final _navKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _intentSub;
  StreamSubscription<String>? _lookupSub;
  ProviderSubscription<DbUpdateState>? _dbUpdateSub;
  ProviderSubscription<DbUpdateState>? _appUpdateGateSub;
  bool _firstFrameReleased = false;
  bool _appUpdateChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.deferFirstFrame();
    _dbUpdateSub = ref.listenManual<DbUpdateState>(dbUpdateProvider, (
      previous,
      next,
    ) {
      if (_shouldReleaseFirstFrame(next)) {
        _releaseFirstFrame();
      }
    });
    ref.read(dbUpdateProvider.notifier).checkForUpdates();

    if (!Platform.isLinux) {
      _intentSub = IntentService.intentStream.listen((text) {
        _navKey.currentState?.popUntil((route) => route.isFirst);
        ref.read(externalSearchHandlerProvider).apply(text);
      });
    }

    if (Platform.isLinux) {
      debugPrint('[DPD] app.dart: subscribing to lookupStream');
      _lookupSub = IntentService.lookupStream.listen((text) {
        debugPrint('[DPD] app.dart: lookupStream received: "$text"');
        _navKey.currentState?.popUntil((route) => route.isFirst);
        ref.read(externalSearchHandlerProvider).apply(text);
      });

      final hotkey = ref.read(settingsProvider).lookupHotkey;
      debugPrint('[DPD] app.dart: saved lookupHotkey: "$hotkey"');
      if (hotkey.isNotEmpty) {
        IntentService.bindHotkey(hotkey);
      }
    }
  }

  bool _shouldReleaseFirstFrame(DbUpdateState state) {
    return state.hasLocalDatabase ||
        state.status == DbStatus.noDatabase ||
        state.status == DbStatus.downloading ||
        state.status == DbStatus.extracting ||
        state.status == DbStatus.error;
  }

  void _releaseFirstFrame() {
    if (_firstFrameReleased) return;
    _firstFrameReleased = true;
    WidgetsBinding.instance.allowFirstFrame();

    // Only fire app update check once the DB update cycle is fully complete —
    // never while a background DB download could still start or be running.
    // Otherwise both downloads run at once and fight over the single
    // foreground notification.
    _appUpdateGateSub = ref.listenManual<DbUpdateState>(dbUpdateProvider, (
      previous,
      next,
    ) {
      if (!_appUpdateChecked &&
          next.status == DbStatus.ready &&
          next.updateCycleComplete) {
        _appUpdateChecked = true;
        _appUpdateGateSub?.close();
        _appUpdateGateSub = null;
        ref.read(appUpdateProvider.notifier).checkForUpdates();
      }
    }, fireImmediately: true);
  }

  void _exitApp() {
    _intentSub?.cancel();
    _lookupSub?.cancel();
    ServicesBinding.instance.exitApplication(AppExitType.cancelable);
  }

  @override
  void dispose() {
    _dbUpdateSub?.close();
    _appUpdateGateSub?.close();
    if (!_firstFrameReleased) {
      WidgetsBinding.instance.allowFirstFrame();
    }
    _intentSub?.cancel();
    _lookupSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    final palettes = palettesFor(settings.colourScheme);
    final lightPalette = palettes.light;
    final darkPalette = palettes.dark;

    final lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPalette.primary,
      onPrimary: lightPalette.dark,
      secondary: lightPalette.primaryAlt,
      onSecondary: lightPalette.light,
      secondaryContainer: lightPalette.primary,
      onSecondaryContainer: lightPalette.dark,
      surface: lightPalette.light,
      onSurface: lightPalette.dark,
      surfaceContainerHighest: lightPalette.lightShade,
      outline: lightPalette.gray,
      outlineVariant: lightPalette.grayLight,
      error: Colors.red,
      onError: Colors.white,
    );

    final darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkPalette.primary,
      onPrimary: darkPalette.dark,
      secondary: darkPalette.primaryAlt,
      onSecondary: darkPalette.light,
      secondaryContainer: darkPalette.primary,
      onSecondaryContainer: darkPalette.dark,
      surface: darkPalette.dark,
      onSurface: darkPalette.light,
      surfaceContainerHighest: darkPalette.darkShade,
      outline: darkPalette.gray,
      outlineVariant: darkPalette.grayDark,
      error: Colors.red,
      onError: Colors.white,
    );

    TextTheme buildTextTheme(TextTheme base) {
      final themed = settings.useSerifFont
          ? GoogleFonts.notoSerifTextTheme(base)
          : GoogleFonts.interTextTheme(base);
      const baseSize = 14.0;
      return themed.copyWith(
        titleLarge: themed.titleLarge?.copyWith(
          fontSize: baseSize * 1.3,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: themed.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: themed.bodyMedium?.copyWith(height: 1.5),
        bodySmall: themed.bodySmall?.copyWith(height: 1.5),
        labelSmall: themed.labelSmall?.copyWith(fontSize: baseSize * 0.8),
        labelMedium: themed.labelMedium?.copyWith(fontSize: baseSize * 0.8),
      );
    }

    final isDesktop =
        Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        if (isDesktop)
          const SingleActivator(LogicalKeyboardKey.keyQ, control: true):
              _exitApp,
        if (Platform.isMacOS)
          const SingleActivator(LogicalKeyboardKey.keyQ, meta: true): _exitApp,
      },
      child: Focus(
        autofocus: true,
        child: MaterialApp(
          navigatorKey: _navKey,
          title: 'DPD',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: lightScheme,
            scaffoldBackgroundColor: lightPalette.light,
            textTheme: buildTextTheme(
              ThemeData(colorScheme: lightScheme).textTheme,
            ),
            switchTheme: _buildSwitchTheme(lightPalette),
            extensions: [lightPalette],
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            scaffoldBackgroundColor: darkPalette.dark,
            textTheme: buildTextTheme(
              ThemeData.dark().copyWith(colorScheme: darkScheme).textTheme,
            ),
            switchTheme: _buildSwitchTheme(darkPalette),
            extensions: [darkPalette],
            useMaterial3: true,
          ),
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const _DbGate());
      case '/entry':
        final id = settings.arguments as int?;
        if (id == null) return null;
        return MaterialPageRoute(builder: (_) => EntryScreen(headwordId: id));
      case '/root':
        final rootKey = settings.arguments as String?;
        if (rootKey == null) return null;
        return MaterialPageRoute(builder: (_) => RootScreen(rootKey: rootKey));
      default:
        return null;
    }
  }
}

class _DbGate extends ConsumerStatefulWidget {
  const _DbGate();

  @override
  ConsumerState<_DbGate> createState() => _DbGateState();
}

void _showUpdateSnackBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class _DbGateState extends ConsumerState<_DbGate> {
  bool _eagerLoaded = false;
  bool _downloadPromptVisible = false;
  bool _whatsNewShown = false;
  bool _appInstallPending = false;

  void _eagerLoadProviders() {
    if (_eagerLoaded) return;
    _eagerLoaded = true;
    ref.read(databaseProvider);
    ref.read(searchIndexProvider);
    ref.read(compoundFamilyKeysProvider);
    ref.read(idiomKeysProvider);
    _checkWhatsNew();
  }

  Future<void> _maybeInstallAppUpdate() async {
    final db = ref.read(dbUpdateProvider);
    if (db.status == DbStatus.downloading || db.status == DbStatus.extracting) {
      _appInstallPending = true;
      return;
    }
    _appInstallPending = false;
    await ref.read(appUpdateProvider.notifier).installUpdate();
  }

  Future<void> _checkWhatsNew() async {
    if (_whatsNewShown) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final info = await PackageInfo.fromPlatform();
    final current = info.version;
    final lastSeen = prefs.getString('last_seen_version') ?? '';
    if (lastSeen == current) return;
    await prefs.setString('last_seen_version', current);
    if (lastSeen.isEmpty) return;
    _whatsNewShown = true;
    final notes = await AppUpdateService().fetchReleaseNotes('v$current');
    if (!mounted) return;
    await _showWhatsNewDialog(current, notes);
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(dbUpdateProvider);

    ref.listen<AppUpdateState>(appUpdateProvider, (previous, next) {
      if (next.status == AppUpdateStatus.readyToInstall &&
          previous?.status != AppUpdateStatus.readyToInstall) {
        _showUpdateSnackBar(
          context,
          'Installing app update ${next.latestTag ?? ""}…',
        );
        _maybeInstallAppUpdate();
      }

      if (next.status == AppUpdateStatus.error &&
          previous?.status != AppUpdateStatus.error) {
        _showUpdateSnackBar(context, 'App update download failed');
      }
    });

    ref.listen<DbUpdateState>(dbUpdateProvider, (previous, next) {
      if (previous == null || !next.hasLocalDatabase) return;

      if (previous.status == DbStatus.extracting &&
          next.status == DbStatus.ready) {
        _showUpdateSnackBar(
          context,
          'Database updated to ${next.localVersion ?? "latest version"}',
        );
      }

      if (next.status == DbStatus.ready && _appInstallPending) {
        _maybeInstallAppUpdate();
      }
    });

    ref.listen<DbUpdateState>(dbUpdateProvider, (previous, next) {
      if (!next.shouldPromptForDownload || _downloadPromptVisible) return;
      _downloadPromptVisible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _showInitialDownloadPrompt();
        _downloadPromptVisible = false;
      });
    });

    if (!updateState.hasLocalDatabase) {
      return const DownloadScreen();
    }

    _eagerLoadProviders();
    return const SearchScreen();
  }

  Future<void> _showWhatsNewDialog(String version, String? notes) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("What's new in v$version"),
          content: notes != null && notes.isNotEmpty
              ? SingleChildScrollView(child: Text(notes))
              : null,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInitialDownloadPrompt() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Download dictionary data?'),
          content: const Text(
            'The DPD database is required before the app can open. '
            'Download it when you are ready.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref
                    .read(dbUpdateProvider.notifier)
                    .dismissInitialDownloadPrompt();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(dbUpdateProvider.notifier).startInitialDownload();
              },
              child: const Text('Download now'),
            ),
          ],
        );
      },
    );
  }
}
