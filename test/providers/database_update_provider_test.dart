import 'dart:async';

import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/providers/database_provider.dart';
import 'package:dpd_flutter_app/providers/database_update_provider.dart';
import 'package:dpd_flutter_app/providers/settings_provider.dart';
import 'package:dpd_flutter_app/services/database_update_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test(
    'first install waits for explicit confirmation before downloading',
    () async {
      final service = _FakeDatabaseUpdateService(
        databaseExistsResult: false,
        latestRelease: const ReleaseInfo(
          tagName: 'v1.2.3',
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
        ],
      );
      addTearDown(container.dispose);

      await container.read(dbUpdateProvider.notifier).checkForUpdates();

      final state = container.read(dbUpdateProvider);
      expect(state.status, DbStatus.noDatabase);
      expect(state.releaseInfo?.tagName, 'v1.2.3');
      expect(state.shouldPromptForDownload, true);
      expect(service.downloadCalls, 0);
    },
  );

  test('explicit start begins the initial download flow', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = _FakeDao(database);
    final completer = Completer<void>();
    final service = _FakeDatabaseUpdateService(
      databaseExistsResult: false,
      latestRelease: const ReleaseInfo(
        tagName: 'v1.2.3',
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
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    await container.read(dbUpdateProvider.notifier).checkForUpdates();

    final downloadFuture = container
        .read(dbUpdateProvider.notifier)
        .startInitialDownload();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(dbUpdateProvider);
    expect(state.status, DbStatus.downloading);
    expect(state.shouldPromptForDownload, false);
    expect(service.downloadCalls, 1);

    completer.complete();
    await downloadFuture;
  });

  test(
    'dismissing the prompt leaves first install blocked without downloading',
    () async {
      final service = _FakeDatabaseUpdateService(
        databaseExistsResult: false,
        latestRelease: const ReleaseInfo(
          tagName: 'v1.2.3',
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
        ],
      );
      addTearDown(container.dispose);

      await container.read(dbUpdateProvider.notifier).checkForUpdates();
      container.read(dbUpdateProvider.notifier).dismissInitialDownloadPrompt();

      final state = container.read(dbUpdateProvider);
      expect(state.status, DbStatus.noDatabase);
      expect(state.shouldPromptForDownload, false);
      expect(service.downloadCalls, 0);
    },
  );
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
  int downloadCalls = 0;

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
    downloadCalls += 1;
    if (downloadCompleter != null) {
      await downloadCompleter!.future;
    }
  }
}

class _FakeForegroundDownloadController
    implements ForegroundDownloadController {
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
  Future<String?> getDbValue(String key) async => 'v1.2.3';
}
