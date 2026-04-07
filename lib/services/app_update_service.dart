import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AppReleaseInfo {
  final String tagName;
  final String downloadUrl;
  final int size;

  const AppReleaseInfo({
    required this.tagName,
    required this.downloadUrl,
    required this.size,
  });
}

class AppUpdateService {
  final Dio _dio;

  AppUpdateService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<AppReleaseInfo?> fetchLatestRelease() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/digitalpalidictionary/dpd-flutter-app/releases/latest',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );

      final data = response.data;
      if (data == null) return null;

      final tagName = data['tag_name'] as String?;
      if (tagName == null) return null;

      final assets =
          (data['assets'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
              [];

      final apkAsset = assets.firstWhere(
        (a) => (a['name'] as String).endsWith('.apk'),
        orElse: () => <String, dynamic>{},
      );

      if (apkAsset.isEmpty) return null;

      return AppReleaseInfo(
        tagName: tagName,
        downloadUrl: apkAsset['browser_download_url'] as String,
        size: apkAsset['size'] as int,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('GitHub API rate limit exceeded. Try again later.');
      }
      throw Exception('Failed to check for app update: ${e.message}');
    }
  }

  Future<File> downloadApk({
    required AppReleaseInfo release,
    required void Function(double progress) onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final apkFile = File('${tempDir.path}/dpd-update.apk');

    await _dio.download(
      release.downloadUrl,
      apkFile.path,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
      options: Options(receiveTimeout: const Duration(minutes: 30)),
    );

    return apkFile;
  }

  Future<String?> fetchReleaseNotes(String tag) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/digitalpalidictionary/dpd-flutter-app/releases/tags/$tag',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );
      return response.data?['body'] as String?;
    } catch (_) {
      return null;
    }
  }

  String formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }
}
