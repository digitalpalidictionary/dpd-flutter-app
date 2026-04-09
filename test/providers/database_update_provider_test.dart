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

  // ---------------------------------------------------------------------------
  // Existing flow tests
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Cancel flow
  // ---------------------------------------------------------------------------

  test('cancel during initial download returns to noDatabase/prompt state', () async {
    final service = _FakeDatabaseUpdateService(
      databaseExistsResult: false,
      latestRelease: const ReleaseInfo(
        tagName: 'v1.2.3',
        downloadUrl: 'https://example.com/dpd-mobile-db.zip',
        size: 42,
      ),
      throwOnDownload: const DownloadCancelledException(),
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseUpdateServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(dbUpdateProvider.notifier).checkForUpdates();
    await container.read(dbUpdateProvider.notifier).startInitialDownload();

    final state = container.read(dbUpdateProvider);
    expect(state.status, DbStatus.noDatabase);
    expect(state.shouldPromptForDownload, true);
    expect(state.releaseInfo?.tagName, 'v1.2.3');
    expect(state.errorMessage, isNull);
  });

  // Background download cancel path cannot be unit-tested here:
  // _backgroundCheck() is a no-op in kDebugMode (always true in tests),
  // so _backgroundDownload() never runs via checkForUpdates(). Integration
  // testing or DI for kDebugMode would be needed to cover this path.

  // ---------------------------------------------------------------------------
  // Stall detection
  // ---------------------------------------------------------------------------

  test('stall error surfaces a user-friendly stall message', () async {
    final service = _FakeDatabaseUpdateService(
      databaseExistsResult: false,
      latestRelease: const ReleaseInfo(
        tagName: 'v1.2.3',
        downloadUrl: 'https://example.com/dpd-mobile-db.zip',
        size: 42,
      ),
      throwOnDownload: Exception(
        'Download stalled — no data received for 60 seconds.\n'
        'Check your connection and try again.',
      ),
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseUpdateServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(dbUpdateProvider.notifier).checkForUpdates();
    await container.read(dbUpdateProvider.notifier).startInitialDownload();

    final state = container.read(dbUpdateProvider);
    expect(state.status, DbStatus.error);
    expect(state.errorMessage, contains('stalled'));
  });

  // ---------------------------------------------------------------------------
  // Corrupt zip
  // ---------------------------------------------------------------------------

  test('corrupt zip produces single user-facing error, not a silent re-download', () async {
    final service = _FakeDatabaseUpdateService(
      databaseExistsResult: false,
      latestRelease: const ReleaseInfo(
        tagName: 'v1.2.3',
        downloadUrl: 'https://example.com/dpd-mobile-db.zip',
        size: 42,
      ),
      throwOnDownload: Exception('Downloaded file was corrupt. Please try again.'),
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseUpdateServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(dbUpdateProvider.notifier).checkForUpdates();
    await container.read(dbUpdateProvider.notifier).startInitialDownload();

    final state = container.read(dbUpdateProvider);
    expect(state.status, DbStatus.error);
    expect(state.errorMessage, contains('corrupt'));
    expect(service.downloadCalls, 1);
  });

  // ---------------------------------------------------------------------------
  // Status label
  // ---------------------------------------------------------------------------

  test('Restarting label appears in state; Extracting triggers DbStatus.extracting', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = _FakeDao(database);
    final labels = <String>[];
    final statuses = <DbStatus>[];
    final completer = Completer<void>();
    final service = _FakeDatabaseUpdateService(
      databaseExistsResult: false,
      latestRelease: const ReleaseInfo(
        tagName: 'v1.2.3',
        downloadUrl: 'https://example.com/dpd-mobile-db.zip',
        size: 42,
      ),
      downloadCompleter: completer,
      emitStatusLabels: ['Restarting download…', 'Extracting…'],
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseUpdateServiceProvider.overrideWithValue(service),
        daoProvider.overrideWithValue(dao),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    container.listen(dbUpdateProvider, (_, s) {
      if (s.statusLabel != null) labels.add(s.statusLabel!);
      statuses.add(s.status);
    });

    await container.read(dbUpdateProvider.notifier).checkForUpdates();
    completer.complete();
    await container.read(dbUpdateProvider.notifier).startInitialDownload();

    expect(labels, contains('Restarting download…'));
    expect(statuses, contains(DbStatus.extracting));
  });
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeDatabaseUpdateService extends DatabaseUpdateService {
  _FakeDatabaseUpdateService({
    required this.databaseExistsResult,
    this.latestRelease,
    this.downloadCompleter,
    this.throwOnDownload,
    this.emitStatusLabels = const [],
  });

  final bool databaseExistsResult;
  final ReleaseInfo? latestRelease;
  final Completer<void>? downloadCompleter;
  final Object? throwOnDownload;
  final List<String> emitStatusLabels;
  int downloadCalls = 0;

  @override
  Future<bool> databaseExists() async => databaseExistsResult;

  @override
  Future<ReleaseInfo?> fetchLatestRelease() async => latestRelease;

  @override
  Future<bool> isSchemaCompatible(AppDatabase db) async => true;

  @override
  Future<bool> isDatabaseUsable(AppDatabase db) async => true;

  @override
  Future<void> downloadAndInstall({
    required ReleaseInfo release,
    required void Function(double progress) onProgress,
    required Future<void> Function() closeDb,
    required Future<void> Function() reopenDb,
    void Function(String label)? onStatusLabel,
  }) async {
    downloadCalls += 1;
    if (throwOnDownload != null) {
      throw throwOnDownload!;
    }
    if (downloadCompleter != null) {
      await downloadCompleter!.future;
    }
    for (final label in emitStatusLabels) {
      onStatusLabel?.call(label);
    }
  }
}

class _FakeDao extends DpdDao {
  _FakeDao(super.db);

  @override
  Future<String?> getDbValue(String key) async => 'v1.2.3';
}
