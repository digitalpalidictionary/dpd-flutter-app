import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';

import '../database/database.dart';

/// Default for DBs that predate the schema-version mechanism.
/// Matches the app's schemaVersion at the time this check was introduced.
const _fallbackDbSchemaVersion = 2;

enum DbStatus {
  noDatabase,
  ready,
  checking,
  downloading,
  extracting,
  error,
}

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

class DatabaseUpdateService {
  final Dio _dio;

  DatabaseUpdateService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<bool> databaseExists() async {
    final dbFile = await resolveDbPath();
    return dbFile.existsSync();
  }

  Future<ReleaseInfo?> fetchLatestRelease() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://api.github.com/repos/digitalpalidictionary/dpd-db/releases',
        queryParameters: {'per_page': 10},
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
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

    try {
      // Download zip with progress
      await _dio.download(
        release.downloadUrl,
        tempZip.path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 30),
        ),
      );

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
      if (tempZip.existsSync()) await tempZip.delete();
      if (tempDb.existsSync()) await tempDb.delete();
    }
  }

  /// Returns true when the on-device DB is compatible with the current app.
  /// Uses raw SQL so it works even when Drift table definitions have changed.
  Future<bool> isSchemaCompatible(AppDatabase db) async {
    try {
      final result = await db.customSelect(
        "SELECT value FROM db_info WHERE key = 'db_schema_version'",
      ).getSingleOrNull();
      final version =
          int.tryParse(result?.data['value'] as String? ?? '') ??
              _fallbackDbSchemaVersion;
      return version >= AppDatabase.requiredDbSchemaVersion;
    } catch (_) {
      // db_info table missing or unreadable — assume incompatible.
      return false;
    }
  }

  String formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }
}
