import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/database_update_service.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

const _installedTagKey = 'dpd_installed_release_tag';

class DbUpdateState {
  final DbStatus status;
  final double progress;
  final String? errorMessage;
  final ReleaseInfo? releaseInfo;
  final String? localVersion;

  const DbUpdateState({
    this.status = DbStatus.checking,
    this.progress = 0,
    this.errorMessage,
    this.releaseInfo,
    this.localVersion,
  });

  DbUpdateState copyWith({
    DbStatus? status,
    double? progress,
    String? errorMessage,
    ReleaseInfo? releaseInfo,
    String? localVersion,
  }) {
    return DbUpdateState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      localVersion: localVersion ?? this.localVersion,
    );
  }
}

class DbUpdateNotifier extends StateNotifier<DbUpdateState> {
  final Ref _ref;
  final DatabaseUpdateService _service;

  DbUpdateNotifier(this._ref)
      : _service = DatabaseUpdateService(),
        super(const DbUpdateState());

  String? get _installedTag =>
      _ref.read(sharedPreferencesProvider).getString(_installedTagKey);

  Future<void> _saveInstalledTag(String tag) async {
    await _ref.read(sharedPreferencesProvider).setString(_installedTagKey, tag);
  }

  Future<void> checkForUpdates() async {
    state = state.copyWith(status: DbStatus.checking);

    try {
      final exists = await _service.databaseExists();

      if (!exists) {
        ReleaseInfo? release;
        try {
          release = await _service.fetchLatestRelease().timeout(
            const Duration(seconds: 10),
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
        state = DbUpdateState(status: DbStatus.noDatabase, releaseInfo: release);
        await startDownload();
        return;
      }

      // Use stored installed tag for comparison — not the DB's internal version
      final installedTag = _installedTag;

      // Read DB version for display only
      final dao = _ref.read(daoProvider);
      final localVersion = await dao
          .getDbValue('dpd_release_version')
          .timeout(const Duration(seconds: 5));

      ReleaseInfo? release;
      try {
        release = await _service.fetchLatestRelease().timeout(
          const Duration(seconds: 10),
        );
      } catch (e) {
        state = DbUpdateState(status: DbStatus.upToDate, localVersion: localVersion);
        return;
      }

      if (release == null) {
        state = DbUpdateState(status: DbStatus.upToDate, localVersion: localVersion);
        return;
      }

      if (installedTag == release.tagName) {
        state = DbUpdateState(
          status: DbStatus.upToDate,
          localVersion: localVersion,
          releaseInfo: release,
        );
      } else {
        state = DbUpdateState(
          status: DbStatus.updateAvailable,
          localVersion: localVersion,
          releaseInfo: release,
        );
        await startDownload();
      }
    } catch (e) {
      state = DbUpdateState(status: DbStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> startDownload() async {
    final release = state.releaseInfo;
    if (release == null) return;

    state = state.copyWith(status: DbStatus.downloading, progress: 0);

    try {
      await _service.downloadAndInstall(
        release: release,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
        closeDb: () async {
          _ref.invalidate(databaseProvider);
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        reopenDb: () async {
          _ref.read(databaseProvider);
        },
      );

      state = state.copyWith(status: DbStatus.extracting);

      await _saveInstalledTag(release.tagName);

      final dao = _ref.read(daoProvider);
      final newVersion = await dao.getDbValue('dpd_release_version');

      state = DbUpdateState(
        status: DbStatus.upToDate,
        localVersion: newVersion,
        releaseInfo: release,
      );
    } catch (e) {
      state = state.copyWith(
        status: DbStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final dbUpdateProvider =
    StateNotifierProvider<DbUpdateNotifier, DbUpdateState>((ref) {
  return DbUpdateNotifier(ref);
});
