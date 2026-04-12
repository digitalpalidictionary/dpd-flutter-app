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
import 'theme/dpd_colors.dart';

final _switchTheme = SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return Colors.white;
    return null;
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return DpdColors.primary;
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

    // Only fire app update check once DB is fully ready — never during download/extract.
    _appUpdateGateSub = ref.listenManual<DbUpdateState>(dbUpdateProvider, (
      previous,
      next,
    ) {
      if (!_appUpdateChecked && next.status == DbStatus.ready) {
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

    final lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: DpdColors.primary,
      onPrimary: DpdColors.dark,
      secondary: DpdColors.primaryAlt,
      onSecondary: DpdColors.light,
      secondaryContainer: DpdColors.primary,
      onSecondaryContainer: DpdColors.dark,
      surface: DpdColors.light,
      onSurface: DpdColors.dark,
      surfaceContainerHighest: DpdColors.lightShade,
      outline: DpdColors.gray,
      outlineVariant: DpdColors.grayLight,
      error: Colors.red,
      onError: Colors.white,
    );

    final darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: DpdColors.primary,
      onPrimary: DpdColors.dark,
      secondary: DpdColors.primaryAlt,
      onSecondary: DpdColors.light,
      secondaryContainer: DpdColors.primary,
      onSecondaryContainer: DpdColors.dark,
      surface: DpdColors.dark,
      onSurface: DpdColors.light,
      surfaceContainerHighest: DpdColors.darkShade,
      outline: DpdColors.gray,
      outlineVariant: DpdColors.grayDark,
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
            scaffoldBackgroundColor: DpdColors.light,
            textTheme: buildTextTheme(
              ThemeData(colorScheme: lightScheme).textTheme,
            ),
            switchTheme: _switchTheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            scaffoldBackgroundColor: DpdColors.dark,
            textTheme: buildTextTheme(
              ThemeData.dark().copyWith(colorScheme: darkScheme).textTheme,
            ),
            switchTheme: _switchTheme,
            useMaterial3: true,
          ),
          builder: (context, child) {
            final scale = settings.fontSize / 16.0;
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            );
          },
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
