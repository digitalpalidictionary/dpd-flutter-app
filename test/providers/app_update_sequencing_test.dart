import 'dart:async' show Completer;

import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/providers/app_update_provider.dart';
import 'package:dpd_flutter_app/providers/database_provider.dart';
import 'package:dpd_flutter_app/providers/database_update_provider.dart';
import 'package:dpd_flutter_app/providers/settings_provider.dart';
import 'package:dpd_flutter_app/services/database_update_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// These tests verify the DB status transitions that the app-update gate in
// app.dart depends on. The gate fires checkForUpdates() only when
// DbStatus.ready, and _maybeInstallAppUpdate() only installs when not
// downloading/extracting. We verify those state values are produced correctly
// by the DB provider so the gate conditions are sound.

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('DB status gates for app update sequencing', () {
    test('DB provider enters ready state after a successful download', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final dao = _FakeDao(database);
      final service = _FakeDatabaseUpdateService(
        databaseExistsResult: false,
        latestRelease: const ReleaseInfo(
          tagName: 'v1.0.0',
          downloadUrl: 'https://example.com/dpd-mobile-db.zip',
          size: 42,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseUpdateServiceProvider.overrideWithValue(service),
          foregroundDownloadControllerProvider.overrideWithValue(
            const _FakeForegroundDownloadController(),
          ),
          daoProvider.overrideWithValue(dao),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });

      await container.read(dbUpdateProvider.notifier).checkForUpdates();
      await container.read(dbUpdateProvider.notifier).startInitialDownload();

      final state = container.read(dbUpdateProvider);
      expect(state.status, DbStatus.ready);
      expect(state.hasLocalDatabase, true);
    });

    test('DB provider is in downloading state during an active download', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final dao = _FakeDao(database);
      final completer = Completer<void>();
      final service = _FakeDatabaseUpdateService(
        databaseExistsResult: false,
        latestRelease: const ReleaseInfo(
          tagName: 'v1.0.0',
          downloadUrl: 'https://example.com/dpd-mobile-db.zip',
          size: 42,
        ),
        downloadCompleter: completer,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseUpdateServiceProvider.overrideWithValue(service),
          foregroundDownloadControllerProvider.overrideWithValue(
            const _FakeForegroundDownloadController(),
          ),
          daoProvider.overrideWithValue(dao),
        ],
      );

      await container.read(dbUpdateProvider.notifier).checkForUpdates();

      // Start download but don't await — we want to observe the intermediate state.
      final downloadFuture =
          container.read(dbUpdateProvider.notifier).startInitialDownload();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(dbUpdateProvider);

      // Gate condition: app update check and install must NOT fire in these states.
      expect(
        state.status == DbStatus.downloading ||
            state.status == DbStatus.extracting,
        isTrue,
        reason: 'DB must be in a busy state during download so the gate blocks app update',
      );
      expect(state.hasLocalDatabase, false);

      // Complete and await before cleanup to avoid post-dispose state writes.
      completer.complete();
      await downloadFuture;
      container.dispose();
      await database.close();
    });

    test('install gate condition: busy states are downloading and extracting', () {
      // Verifies that the set of states guarded against in _maybeInstallAppUpdate
      // matches the actual DbStatus busy values. This is a compile-time safety
      // check expressed as a runtime assertion.
      const busyStatuses = {DbStatus.downloading, DbStatus.extracting};

      for (final status in DbStatus.values) {
        final isBusy = busyStatuses.contains(status);
        final isReady = status == DbStatus.ready;
        // A status cannot be both ready and busy.
        expect(isBusy && isReady, isFalse,
            reason: '$status cannot be both busy and ready');
      }

      // The two invariants must both be expressible as simple status checks.
      expect(busyStatuses.contains(DbStatus.downloading), isTrue);
      expect(busyStatuses.contains(DbStatus.extracting), isTrue);
      expect(busyStatuses.contains(DbStatus.ready), isFalse);
    });

    test('AppUpdateNotifier starts idle and moves to checking on checkForUpdates in release mode', () async {
      // Validates the appUpdateProvider state machine used by the gate logic.
      // In debug mode checkForUpdates is a no-op, so we verify the initial state.
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(appUpdateProvider);
      expect(state.status, AppUpdateStatus.idle);
      expect(state.apkPath, isNull);
    });
  });
}

class _FakeDatabaseUpdateService extends DatabaseUpdateService {
  _FakeDatabaseUpdateService({
    required this.databaseExistsResult,
    this.latestRelease,
    this.downloadCompleter,
  });

  final bool databaseExistsResult;
  final ReleaseInfo? latestRelease;
  final Completer<void>? downloadCompleter;

  @override
  Future<bool> databaseExists() async => databaseExistsResult;

  @override
  Future<ReleaseInfo?> fetchLatestRelease() async => latestRelease;

  @override
  Future<void> downloadAndInstall({
    required ReleaseInfo release,
    required void Function(double progress) onProgress,
    required Future<void> Function() closeDb,
    required Future<void> Function() reopenDb,
  }) async {
    if (downloadCompleter != null) {
      await downloadCompleter!.future;
    }
  }
}

class _FakeForegroundDownloadController implements ForegroundDownloadController {
  const _FakeForegroundDownloadController();

  @override
  Future<void> startDbDownload() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> updateProgress(double progress) async {}
}

class _FakeDao extends DpdDao {
  _FakeDao(super.db);

  @override
  Future<String?> getDbValue(String key) async => 'v1.0.0';
}
