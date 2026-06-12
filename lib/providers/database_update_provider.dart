import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/database_update_service.dart';
import '../services/foreground_download_service.dart';
import 'autocomplete_provider.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

const _installedTagKey = 'dpd_installed_release_tag';

String _errorMessage(Object e) {
  final s = e.toString();
  if (s.startsWith('Exception: ')) return s.substring('Exception: '.length);
  return s;
}

class AppForegroundDownloadController implements ForegroundDownloadController {
  const AppForegroundDownloadController();

  @override
  Future<void> startDbDownload() {
    return ForegroundDownloadService.startDbDownload();
  }

  @override
  Future<void> stop() {
    return ForegroundDownloadService.stop();
  }

  @override
  Future<void> updateProgress(double progress) {
    return ForegroundDownloadService.updateProgress(progress);
  }
}

final databaseUpdateServiceProvider = Provider<DatabaseUpdateService>((ref) {
  return DatabaseUpdateService(
    foregroundController: const AppForegroundDownloadController(),
  );
});

class DbUpdateState {
  final DbStatus status;
  final double progress;
  final String? errorMessage;
  final ReleaseInfo? releaseInfo;
  final String? localVersion;
  final bool hasLocalDatabase;
  final bool shouldPromptForDownload;
  final String? statusLabel;

  /// True once the DB update cycle is fully finished — no background check or
  /// download can still start. The app-update gate waits for this so the APK
  /// download never runs concurrently with a DB download (they would share a
  /// single foreground notification).
  final bool updateCycleComplete;

  const DbUpdateState({
    this.status = DbStatus.checking,
    this.progress = 0,
    this.errorMessage,
    this.releaseInfo,
    this.localVersion,
    this.hasLocalDatabase = false,
    this.shouldPromptForDownload = false,
    this.statusLabel,
    this.updateCycleComplete = false,
  });

  DbUpdateState copyWith({
    DbStatus? status,
    double? progress,
    String? errorMessage,
    ReleaseInfo? releaseInfo,
    String? localVersion,
    bool? hasLocalDatabase,
    bool? shouldPromptForDownload,
    String? statusLabel,
    bool? updateCycleComplete,
    bool clearStatusLabel = false,
    bool clearErrorMessage = false,
  }) {
    return DbUpdateState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      releaseInfo: releaseInfo ?? this.releaseInfo,
      localVersion: localVersion ?? this.localVersion,
      hasLocalDatabase: hasLocalDatabase ?? this.hasLocalDatabase,
      shouldPromptForDownload:
          shouldPromptForDownload ?? this.shouldPromptForDownload,
      statusLabel: clearStatusLabel ? null : (statusLabel ?? this.statusLabel),
      updateCycleComplete: updateCycleComplete ?? this.updateCycleComplete,
    );
  }
}

class DbUpdateNotifier extends StateNotifier<DbUpdateState> {
  final Ref _ref;
  final DatabaseUpdateService _service;

  DbUpdateNotifier(this._ref)
    : _service = _ref.read(databaseUpdateServiceProvider),
      super(const DbUpdateState());

  String? get _installedTag =>
      _ref.read(sharedPreferencesProvider).getString(_installedTagKey);

  Future<void> _saveInstalledTag(String tag) async {
    await _ref.read(sharedPreferencesProvider).setString(_installedTagKey, tag);
  }

  Future<void> checkForUpdates() async {
    final exists = await _service.databaseExists();

    if (!exists) {
      // First install — blocking flow
      state = state.copyWith(status: DbStatus.checking);

      ReleaseInfo? release;
      try {
        release = await _service.fetchLatestRelease().timeout(
          const Duration(seconds: 30),
        );
      } catch (e) {
        state = const DbUpdateState(
          status: DbStatus.error,
          errorMessage:
              'Could not reach the server.\nCheck your connection and try again.',
        );
        return;
      }
      if (release == null) {
        state = const DbUpdateState(
          status: DbStatus.error,
          errorMessage: 'No database release found.\nPlease try again later.',
        );
        return;
      }
      state = DbUpdateState(
        status: DbStatus.noDatabase,
        releaseInfo: release,
        shouldPromptForDownload: true,
      );
      return;
    }

    // DB exists — distinguish schema metadata issues from an unusable DB.
    bool compatible;
    bool usable;
    final db = _ref.read(databaseProvider);
    try {
      compatible = await _service.isSchemaCompatible(db);
      usable = compatible || await _service.isDatabaseUsable(db);
    } catch (_) {
      compatible = false;
      usable = false;
    }

    if (!compatible) {
      if (usable) {
        String? localVersion;
        try {
          final dao = _ref.read(daoProvider);
          localVersion = await dao
              .getDbValue('dpd_release_version')
              .timeout(const Duration(seconds: 5));
        } catch (_) {}

        state = DbUpdateState(
          status: DbStatus.ready,
          hasLocalDatabase: true,
          localVersion: localVersion,
        );

        if (!kDebugMode) {
          _backgroundCheck(localVersion);
        } else {
          state = state.copyWith(updateCycleComplete: true);
        }
        return;
      }

      // DB file exists but is unreadable or incompatible — must download a
      // matching replacement before any queries can run.
      _ref.invalidate(databaseProvider);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      state = state.copyWith(status: DbStatus.checking);

      ReleaseInfo? release;
      try {
        release = await _service.fetchLatestRelease().timeout(
          const Duration(seconds: 30),
        );
      } catch (e) {
        state = const DbUpdateState(
          status: DbStatus.error,
          errorMessage:
              'Database update required but could not reach the server.\n'
              'Check your connection and try again.',
        );
        return;
      }
      if (release == null) {
        state = const DbUpdateState(
          status: DbStatus.error,
          errorMessage:
              'Database update required but no release found.\n'
              'Please try again later.',
        );
        return;
      }
      state = DbUpdateState(
        status: DbStatus.noDatabase,
        releaseInfo: release,
        shouldPromptForDownload: true,
      );
      return;
    }

    // Schema OK — go straight to ready, then check in background
    String? localVersion;
    try {
      final dao = _ref.read(daoProvider);
      localVersion = await dao
          .getDbValue('dpd_release_version')
          .timeout(const Duration(seconds: 5));
    } catch (_) {}

    state = DbUpdateState(
      status: DbStatus.ready,
      hasLocalDatabase: true,
      localVersion: localVersion,
    );

    // Skip background updates in debug — DB is pushed manually via `just push-mobile-db`.
    if (!kDebugMode) {
      _backgroundCheck(localVersion);
    } else {
      state = state.copyWith(updateCycleComplete: true);
    }
  }

  Future<void> _initialDownload(ReleaseInfo release) async {
    state = state.copyWith(
      status: DbStatus.downloading,
      progress: 0,
      shouldPromptForDownload: false,
      clearStatusLabel: true,
    );

    try {
      await _service.downloadAndInstall(
        release: release,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
        onStatusLabel: (label) {
          if (label.isEmpty) {
            state = state.copyWith(clearStatusLabel: true);
          } else if (label == 'Extracting…') {
            state = state.copyWith(
              status: DbStatus.extracting,
              clearStatusLabel: true,
            );
          } else {
            state = state.copyWith(statusLabel: label);
          }
        },
        closeDb: () async {
          _ref.invalidate(databaseProvider);
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        reopenDb: () async {
          _ref.read(databaseProvider);
        },
      );

      await _saveInstalledTag(release.tagName);

      final dao = _ref.read(daoProvider);
      final newVersion = await dao.getDbValue('dpd_release_version');

      state = DbUpdateState(
        status: DbStatus.ready,
        hasLocalDatabase: true,
        localVersion: newVersion,
        releaseInfo: release,
        updateCycleComplete: true,
      );
    } on DownloadCancelledException {
      state = DbUpdateState(
        status: DbStatus.noDatabase,
        releaseInfo: release,
        shouldPromptForDownload: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: DbStatus.error,
        errorMessage: _errorMessage(e),
        clearStatusLabel: true,
      );
    }
  }

  Future<void> _backgroundCheck(String? localVersion) async {
    ReleaseInfo? release;
    try {
      release = await _service.fetchLatestRelease().timeout(
        const Duration(seconds: 30),
      );
    } catch (_) {
      state = state.copyWith(updateCycleComplete: true);
      return;
    }

    if (release == null) {
      state = state.copyWith(updateCycleComplete: true);
      return;
    }

    final installedTag = _installedTag;
    if (installedTag == release.tagName) {
      state = state.copyWith(releaseInfo: release, updateCycleComplete: true);
      return;
    }

    // Skip download on mobile data if WiFi-only is enabled
    final wifiOnly = _ref.read(settingsProvider).wifiOnlyUpdates;
    if (wifiOnly) {
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.contains(ConnectivityResult.wifi)) {
        state = state.copyWith(updateCycleComplete: true);
        return;
      }
    }

    await _backgroundDownload(release);
  }

  Future<void> _backgroundDownload(ReleaseInfo release) async {
    state = state.copyWith(
      status: DbStatus.downloading,
      releaseInfo: release,
      progress: 0,
      clearStatusLabel: true,
    );

    try {
      await _service.downloadAndInstall(
        release: release,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
        onStatusLabel: (label) {
          if (label.isEmpty) {
            state = state.copyWith(clearStatusLabel: true);
          } else if (label == 'Extracting…') {
            state = state.copyWith(
              status: DbStatus.extracting,
              clearStatusLabel: true,
            );
          } else {
            state = state.copyWith(statusLabel: label);
          }
        },
        closeDb: () async {
          _ref.invalidate(databaseProvider);
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        reopenDb: () async {
          _ref.read(databaseProvider);
          _ref.invalidate(searchIndexProvider);
          _ref.invalidate(compoundFamilyKeysProvider);
          _ref.invalidate(idiomKeysProvider);
        },
      );

      await _saveInstalledTag(release.tagName);

      final dao = _ref.read(daoProvider);
      final newVersion = await dao.getDbValue('dpd_release_version');

      state = DbUpdateState(
        status: DbStatus.ready,
        hasLocalDatabase: true,
        localVersion: newVersion,
        releaseInfo: release,
        updateCycleComplete: true,
      );
    } on DownloadCancelledException {
      // Background download cancelled — stay ready with existing DB.
      state = state.copyWith(
        status: DbStatus.ready,
        clearStatusLabel: true,
        clearErrorMessage: true,
        updateCycleComplete: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: DbStatus.ready,
        errorMessage: _errorMessage(e),
        clearStatusLabel: true,
        updateCycleComplete: true,
      );
    }
  }

  void cancelDownload() {
    _service.cancelDownload();
  }

  void dismissInitialDownloadPrompt() {
    if (!state.shouldPromptForDownload) return;
    state = state.copyWith(shouldPromptForDownload: false);
  }

  Future<void> startInitialDownload() async {
    final release = state.releaseInfo;
    if (release == null) return;
    await _initialDownload(release);
  }

  Future<void> manualCheckForUpdates() async {
    if (kDebugMode) return;
    if (!state.hasLocalDatabase) return;
    final localVersion = state.localVersion;
    await _backgroundCheck(localVersion);
  }
}

final dbUpdateProvider = StateNotifierProvider<DbUpdateNotifier, DbUpdateState>(
  (ref) {
    return DbUpdateNotifier(ref);
  },
);
