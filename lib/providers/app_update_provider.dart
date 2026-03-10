import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/app_update_service.dart';
import 'settings_provider.dart';

enum AppUpdateStatus { idle, checking, downloading, readyToInstall, error }

class AppUpdateState {
  final AppUpdateStatus status;
  final double progress;
  final String? apkPath;
  final String? latestTag;

  const AppUpdateState({
    this.status = AppUpdateStatus.idle,
    this.progress = 0,
    this.apkPath,
    this.latestTag,
  });

  AppUpdateState copyWith({
    AppUpdateStatus? status,
    double? progress,
    String? apkPath,
    String? latestTag,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      apkPath: apkPath ?? this.apkPath,
      latestTag: latestTag ?? this.latestTag,
    );
  }
}

class AppUpdateNotifier extends StateNotifier<AppUpdateState> {
  final Ref _ref;
  final AppUpdateService _service;

  AppUpdateNotifier(this._ref)
      : _service = AppUpdateService(),
        super(const AppUpdateState());

  Future<void> checkForUpdates() async {
    if (kDebugMode) return;

    state = state.copyWith(status: AppUpdateStatus.checking);

    AppReleaseInfo? release;
    try {
      release = await _service
          .fetchLatestRelease()
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      state = state.copyWith(status: AppUpdateStatus.idle);
      return;
    }

    if (release == null) {
      state = state.copyWith(status: AppUpdateStatus.idle);
      return;
    }

    final info = await PackageInfo.fromPlatform();
    final latestVersion = release.tagName.replaceFirst(RegExp(r'^v'), '');

    if (!_isNewer(latestVersion, info.version)) {
      state = state.copyWith(status: AppUpdateStatus.idle);
      return;
    }

    final wifiOnly = _ref.read(settingsProvider).wifiOnlyUpdates;
    if (wifiOnly) {
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.contains(ConnectivityResult.wifi)) {
        state = state.copyWith(
          status: AppUpdateStatus.idle,
          latestTag: release.tagName,
        );
        return;
      }
    }

    await _downloadUpdate(release);
  }

  Future<void> _downloadUpdate(AppReleaseInfo release) async {
    state = state.copyWith(
      status: AppUpdateStatus.downloading,
      latestTag: release.tagName,
      progress: 0,
    );

    try {
      final file = await _service.downloadApk(
        release: release,
        onProgress: (progress) => state = state.copyWith(progress: progress),
      );
      state = state.copyWith(
        status: AppUpdateStatus.readyToInstall,
        apkPath: file.path,
      );
    } catch (_) {
      state = state.copyWith(status: AppUpdateStatus.idle);
    }
  }

  Future<void> installUpdate() async {
    final path = state.apkPath;
    if (path == null) return;
    await OpenFilex.open(path);
  }

  void dismiss() => state = state.copyWith(status: AppUpdateStatus.idle);

  Future<void> manualCheck() async {
    state = const AppUpdateState();
    await checkForUpdates();
  }

  bool _isNewer(String latest, String current) {
    final l = latest.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final c = current.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }
}

final appUpdateProvider =
    StateNotifierProvider<AppUpdateNotifier, AppUpdateState>((ref) {
  return AppUpdateNotifier(ref);
});
