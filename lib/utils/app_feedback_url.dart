import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

const feedbackFormBaseUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSd2Agk8K2EwAv-wXxxYw4Ud6rezW96BmMf2qPhrT3-0cW-ALQ/viewform';

class FeedbackMetadata {
  const FeedbackMetadata({
    required this.platform,
    required this.deviceModel,
    required this.osVersion,
    required this.appVersion,
    this.dbVersion,
  });

  final String platform;
  final String deviceModel;
  final String osVersion;
  final String appVersion;
  final String? dbVersion;
}

Future<FeedbackMetadata> collectFeedbackMetadata({String? dbVersion}) async {
  String platform;
  String deviceModel;
  String osVersion;

  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    platform = 'Android';
    deviceModel = android.model;
    osVersion = 'Android ${android.version.release}';
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    platform = 'iOS';
    deviceModel = ios.utsname.machine;
    osVersion = 'iOS ${ios.systemVersion}';
  } else if (Platform.isLinux) {
    final linux = await deviceInfo.linuxInfo;
    platform = 'Linux';
    deviceModel = linux.prettyName;
    osVersion = 'Linux ${linux.versionId ?? ''}';
  } else if (Platform.isMacOS) {
    final macos = await deviceInfo.macOsInfo;
    platform = 'macOS';
    deviceModel = macos.model;
    osVersion = 'macOS ${macos.osRelease}';
  } else if (Platform.isWindows) {
    final windows = await deviceInfo.windowsInfo;
    platform = 'Windows';
    deviceModel = windows.productName;
    osVersion = 'Windows ${windows.displayVersion}';
  } else {
    platform = 'Unknown';
    deviceModel = 'Unknown';
    osVersion = 'Unknown';
  }

  final packageInfo = await PackageInfo.fromPlatform();
  return FeedbackMetadata(
    platform: platform,
    deviceModel: deviceModel,
    osVersion: osVersion,
    appVersion: packageInfo.version,
    dbVersion: dbVersion,
  );
}

String buildFeedbackUrlFromParams({
  required String platform,
  required String deviceModel,
  required String osVersion,
  required String appVersion,
  String? dbVersion,
  String? name,
  String? email,
  String? issueType,
  String? description,
  String? improvement,
}) {
  final params = <String, String>{
    if (name != null && name.isNotEmpty) 'entry.485428648': name,
    if (email != null && email.isNotEmpty) 'entry.1607701011': email,
    if (issueType != null && issueType.isNotEmpty) 'entry.1579150913': issueType,
    if (description != null && description.isNotEmpty) 'entry.811247772': description,
    if (improvement != null && improvement.isNotEmpty) 'entry.1696159737': improvement,
    'entry.405390413': platform,
    'entry.671095698': deviceModel,
    'entry.1162202610': osVersion,
    'entry.1433863141': appVersion,
    'entry.100565099': dbVersion ?? '',
  };

  final uri = Uri.parse(feedbackFormBaseUrl).replace(queryParameters: params);
  return uri.toString();
}

Future<String> buildFeedbackUrl({String? dbVersion}) async {
  final meta = await collectFeedbackMetadata(dbVersion: dbVersion);
  return buildFeedbackUrlFromParams(
    platform: meta.platform,
    deviceModel: meta.deviceModel,
    osVersion: meta.osVersion,
    appVersion: meta.appVersion,
    dbVersion: meta.dbVersion,
  );
}
