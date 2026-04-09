import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';

import '../database/database.dart';

/// Default for DBs that predate the schema-version mechanism.
/// Matches the app's schemaVersion at the time this check was introduced.
const _fallbackDbSchemaVersion = 2;

const _stallTimeout = Duration(seconds: 60);
const _stallPollInterval = Duration(seconds: 5);
const _receiveTimeout = Duration(minutes: 5);

enum DbStatus { noDatabase, ready, checking, downloading, extracting, error }

class ReleaseInfo {
  final String tagName;
  final String downloadUrl;
  final int size;

  const ReleaseInfo({
    required this.tagName,
    required this.downloadUrl,
    required this.size,
  });
}

class _RangeNotSupportedException implements Exception {}

class DownloadCancelledException implements Exception {
  final String? reason;
  const DownloadCancelledException([this.reason]);
}

abstract class ForegroundDownloadController {
  Future<void> startDbDownload();
  Future<void> updateProgress(double progress);
  Future<void> stop();
}

class _NoOpForegroundController implements ForegroundDownloadController {
  @override
  Future<void> startDbDownload() async {}
  @override
  Future<void> updateProgress(double progress) async {}
  @override
  Future<void> stop() async {}
}

class DatabaseUpdateService {
  final Dio _dio;
  final ForegroundDownloadController _foregroundController;
  CancelToken? _activeCancelToken;

  DatabaseUpdateService({
    Dio? dio,
    ForegroundDownloadController? foregroundController,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(seconds: 30),
             ),
           ),
       _foregroundController =
           foregroundController ?? _NoOpForegroundController();

  void cancelDownload() {
    _activeCancelToken?.cancel('user');
  }

  Future<bool> databaseExists() async {
    final dbFile = await resolveDbPath();
    return dbFile.existsSync();
  }

  Future<ReleaseInfo?> fetchLatestRelease() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://api.github.com/repos/digitalpalidictionary/dpd-db/releases',
        queryParameters: {'per_page': 10},
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      final releases = response.data;
      if (releases == null || releases.isEmpty) return null;

      // Find the most recent release that contains dpd-mobile-db.zip
      for (final release in releases) {
        final data = release as Map<String, dynamic>;
        final assets = data['assets'] as List<dynamic>;

        final dbAsset = assets.cast<Map<String, dynamic>>().firstWhere(
          (a) => (a['name'] as String) == 'dpd-mobile-db.zip',
          orElse: () => <String, dynamic>{},
        );

        if (dbAsset.isNotEmpty) {
          return ReleaseInfo(
            tagName: data['tag_name'] as String,
            downloadUrl: dbAsset['browser_download_url'] as String,
            size: dbAsset['size'] as int,
          );
        }
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('GitHub API rate limit exceeded. Try again later.');
      }
      throw Exception('Failed to check for updates: ${e.message}');
    }
  }

  Future<void> downloadAndInstall({
    required ReleaseInfo release,
    required void Function(double progress) onProgress,
    required Future<void> Function() closeDb,
    required Future<void> Function() reopenDb,
    void Function(String label)? onStatusLabel,
  }) async {
    final dbFile = await resolveDbPath();
    final tempZip = File('${dbFile.path}.zip');
    final tempDb = File('${dbFile.path}.new');

    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;

    var lastProgressTime = DateTime.now();
    Timer? stallTimer;
    stallTimer = Timer.periodic(_stallPollInterval, (_) {
      if (DateTime.now().difference(lastProgressTime) > _stallTimeout) {
        cancelToken.cancel('stall');
        stallTimer?.cancel();
      }
    });

    await _foregroundController.startDbDownload();
    var clearLabelOnNextProgress = false;
    try {
      await _downloadWithResume(
        tempZip,
        release,
        (progress) {
          lastProgressTime = DateTime.now();
          if (clearLabelOnNextProgress) {
            onStatusLabel?.call('');
            clearLabelOnNextProgress = false;
          }
          onProgress(progress);
          unawaited(_foregroundController.updateProgress(progress));
        },
        cancelToken,
        () {
          onStatusLabel?.call('Restarting download…');
          clearLabelOnNextProgress = true;
        },
      );
      await _extractAndInstall(
        tempZip,
        tempDb,
        dbFile,
        closeDb: closeDb,
        reopenDb: reopenDb,
        onStatusLabel: onStatusLabel,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        final reason = cancelToken.cancelError?.message;
        if (reason == 'stall') {
          throw Exception(
            'Download stalled — no data received for 60 seconds.\n'
            'Check your connection and try again.',
          );
        }
        throw const DownloadCancelledException();
      }
      throw Exception(_friendlyDioError(e));
    } on FileSystemException catch (e) {
      if (e.message.contains('No space')) {
        throw Exception('Not enough storage space to download the database.');
      }
      rethrow;
    } finally {
      stallTimer.cancel();
      _activeCancelToken = null;
      if (tempDb.existsSync()) await tempDb.delete();
      await _foregroundController.stop();
    }
  }

  Future<void> _extractAndInstall(
    File tempZip,
    File tempDb,
    File dbFile, {
    required Future<void> Function() closeDb,
    required Future<void> Function() reopenDb,
    void Function(String label)? onStatusLabel,
  }) async {
    onStatusLabel?.call('Extracting…');
    try {
      await _extractDbFromZip(tempZip, tempDb);
    } catch (_) {
      if (tempZip.existsSync()) await tempZip.delete();
      if (tempDb.existsSync()) await tempDb.delete();
      throw Exception('Downloaded file was corrupt. Please try again.');
    }

    await closeDb();
    await tempDb.rename(dbFile.path);
    await reopenDb();

    if (tempZip.existsSync()) await tempZip.delete();
  }

  Future<void> _extractDbFromZip(File tempZip, File tempDb) async {
    final inputStream = InputFileStream(tempZip.path);
    try {
      final archive = ZipDecoder().decodeStream(inputStream);
      final dbEntry = archive.files.firstWhere(
        (f) => f.name.endsWith('.db') && f.isFile,
        orElse: () => throw Exception('No .db file found in zip'),
      );
      final outputStream = OutputFileStream(tempDb.path);
      try {
        dbEntry.writeContent(outputStream);
      } finally {
        await outputStream.close();
      }
    } finally {
      await inputStream.close();
    }
  }

  Future<void> _downloadWithResume(
    File tempZip,
    ReleaseInfo release,
    void Function(double progress) onProgress,
    CancelToken cancelToken,
    void Function()? onRestart,
  ) async {
    final totalSize = release.size;
    var alreadyDownloaded = tempZip.existsSync() ? tempZip.lengthSync() : 0;

    // Discard partial files that are larger than expected (stale/corrupt).
    if (alreadyDownloaded > 0 && alreadyDownloaded >= totalSize) {
      await tempZip.delete();
      alreadyDownloaded = 0;
    }

    if (alreadyDownloaded > 0) {
      try {
        await _downloadRange(
          tempZip,
          release.downloadUrl,
          alreadyDownloaded,
          totalSize,
          onProgress,
          cancelToken,
        );
        if (_isFileSizeValid(tempZip, totalSize)) return;
        // Resumed file is wrong size — discard and fall through to fresh download.
        await tempZip.delete();
      } on _RangeNotSupportedException {
        await tempZip.delete();
      }
      onRestart?.call();
    }

    await _freshDownload(tempZip, release, onProgress, cancelToken);
  }

  Future<void> _freshDownload(
    File tempZip,
    ReleaseInfo release,
    void Function(double progress) onProgress,
    CancelToken cancelToken,
  ) async {
    final totalSize = release.size;
    if (tempZip.existsSync()) await tempZip.delete();

    await _dio.download(
      release.downloadUrl,
      tempZip.path,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        final knownTotal = total > 0 ? total : totalSize;
        if (knownTotal > 0) onProgress(received / knownTotal);
      },
      options: Options(receiveTimeout: _receiveTimeout),
    );

    if (!_isFileSizeValid(tempZip, totalSize)) {
      await tempZip.delete();
      throw Exception(
        'Download appears incomplete. Please check your connection and try again.',
      );
    }
  }

  bool _isFileSizeValid(File file, int expectedSize) {
    return file.existsSync() && file.lengthSync() == expectedSize;
  }

  Future<void> _downloadRange(
    File tempZip,
    String url,
    int startByte,
    int totalSize,
    void Function(double progress) onProgress,
    CancelToken cancelToken,
  ) async {
    final response = await _dio.get<ResponseBody>(
      url,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Range': 'bytes=$startByte-'},
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    if (response.statusCode == 200) {
      throw _RangeNotSupportedException();
    }

    final sink = tempZip.openWrite(mode: FileMode.append);
    int receivedBytes = startByte;
    try {
      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalSize > 0) onProgress(receivedBytes / totalSize);
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  /// Returns true when the on-device DB is compatible with the current app.
  /// Uses raw SQL so it works even when Drift table definitions have changed.
  Future<bool> isSchemaCompatible(AppDatabase db) async {
    try {
      final result = await db
          .customSelect(
            "SELECT value FROM db_info WHERE key = 'db_schema_version'",
          )
          .getSingleOrNull();
      final version =
          int.tryParse(result?.data['value'] as String? ?? '') ??
          _fallbackDbSchemaVersion;
      return version >= AppDatabase.requiredDbSchemaVersion;
    } catch (_) {
      // db_info table missing or unreadable — assume incompatible.
      return false;
    }
  }

  /// Returns true when the on-device DB is readable enough for core queries.
  /// This lets the app continue offline with an older DB instead of forcing a
  /// blocking re-download on startup.
  Future<bool> isDatabaseUsable(AppDatabase db) async {
    try {
      await db.customSelect('SELECT id FROM dpd_headwords LIMIT 1').get();
      return true;
    } catch (_) {
      return false;
    }
  }

  static String formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }
}

String _friendlyDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
      return 'Connection timed out.\nCheck your connection and try again.';
    case DioExceptionType.receiveTimeout:
      return 'Download timed out.\nCheck your connection and try again.';
    case DioExceptionType.connectionError:
      return 'Could not connect to the server.\nCheck your connection and try again.';
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code != null && code >= 500) {
        return 'The server returned an error ($code).\nPlease try again later.';
      }
      return 'Download failed (error $code).\nPlease try again later.';
    case DioExceptionType.unknown:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
      return 'Download failed.\nCheck your connection and try again.';
  }
}
