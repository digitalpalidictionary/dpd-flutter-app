import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';

import '../database/database.dart';

/// Default for DBs that predate the schema-version mechanism.
/// Matches the app's schemaVersion at the time this check was introduced.
const _fallbackDbSchemaVersion = 2;

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

class DatabaseUpdateService {
  final Dio _dio;

  DatabaseUpdateService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

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
  }) async {
    final dbFile = await resolveDbPath();
    final tempZip = File('${dbFile.path}.zip');
    final tempDb = File('${dbFile.path}.new');

    bool downloadSucceeded = false;
    try {
      await _downloadWithResume(tempZip, release, onProgress);
      downloadSucceeded = true;

      // Extract .db from zip
      final zipBytes = await tempZip.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      final dbEntry = archive.files.firstWhere(
        (f) => f.name.endsWith('.db') && f.isFile,
        orElse: () => throw Exception('No .db file found in zip'),
      );

      await tempDb.writeAsBytes(dbEntry.content as List<int>);

      // Close DB, atomic rename, reopen
      await closeDb();
      await tempDb.rename(dbFile.path);
      await reopenDb();
    } on FileSystemException catch (e) {
      if (e.message.contains('No space')) {
        throw Exception('Not enough storage space to download the database.');
      }
      rethrow;
    } finally {
      // Only delete tempZip on success — keep partial file for resumption on failure.
      if (downloadSucceeded && tempZip.existsSync()) await tempZip.delete();
      if (tempDb.existsSync()) await tempDb.delete();
    }
  }

  Future<void> _downloadWithResume(
    File tempZip,
    ReleaseInfo release,
    void Function(double progress) onProgress,
  ) async {
    final totalSize = release.size;
    final alreadyDownloaded = tempZip.existsSync() ? tempZip.lengthSync() : 0;

    if (alreadyDownloaded > 0 && alreadyDownloaded >= totalSize) {
      onProgress(1.0);
      return;
    }

    if (alreadyDownloaded > 0) {
      try {
        await _downloadRange(tempZip, release.downloadUrl, alreadyDownloaded, totalSize, onProgress);
        return;
      } on _RangeNotSupportedException {
        // Server doesn't support Range — delete partial file and download fresh.
        await tempZip.delete();
      }
    }

    await _dio.download(
      release.downloadUrl,
      tempZip.path,
      onReceiveProgress: (received, total) {
        final knownTotal = total > 0 ? total : totalSize;
        if (knownTotal > 0) onProgress(received / knownTotal);
      },
      options: Options(receiveTimeout: const Duration(minutes: 30)),
    );
  }

  Future<void> _downloadRange(
    File tempZip,
    String url,
    int startByte,
    int totalSize,
    void Function(double progress) onProgress,
  ) async {
    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Range': 'bytes=$startByte-'},
        receiveTimeout: const Duration(minutes: 30),
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

  String formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }
}
