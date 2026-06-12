import 'dart:io' show Platform;

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void _noOpCallback() {}

class ForegroundDownloadService {
  static bool get _isAndroid => Platform.isAndroid;

  // Android sheds notification updates above 5/sec; Dio reports progress far
  // more often, so only notify when the integer percent changes.
  static int _lastPercent = -1;

  static void initialize() {
    if (!_isAndroid) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'dpd_download',
        channelName: 'Dictionary Update',
        channelDescription: 'Shown while downloading dictionary data',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startDbDownload() async {
    if (!_isAndroid) return;
    _lastPercent = -1;
    await FlutterForegroundTask.requestNotificationPermission();
    await FlutterForegroundTask.startService(
      serviceId: 1001,
      notificationTitle: 'Downloading database…',
      notificationText: 'Download in progress',
      serviceTypes: [ForegroundServiceTypes.dataSync],
      callback: _noOpCallback,
    );
  }

  static Future<void> startAppDownload() async {
    if (!_isAndroid) return;
    _lastPercent = -1;
    await FlutterForegroundTask.requestNotificationPermission();
    await FlutterForegroundTask.startService(
      serviceId: 1002,
      notificationTitle: 'Downloading app…',
      notificationText: 'Download in progress',
      serviceTypes: [ForegroundServiceTypes.dataSync],
      callback: _noOpCallback,
    );
  }

  static Future<void> updateProgress(double progress) async {
    if (!_isAndroid) return;
    final pct = (progress.clamp(0.0, 1.0) * 100).floor();
    if (pct == _lastPercent) return;
    _lastPercent = pct;
    await FlutterForegroundTask.updateService(
      notificationText: 'Downloading: $pct%',
    );
  }

  static Future<void> stop() async {
    if (!_isAndroid) return;
    await FlutterForegroundTask.stopService();
  }
}
