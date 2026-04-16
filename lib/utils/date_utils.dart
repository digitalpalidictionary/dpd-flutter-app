import 'dart:io';

String dpdDateStamp() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _platform() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isLinux) return 'Linux';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  return 'Unknown';
}

/// Returns a human-readable app label, e.g. "DPD Android 2026-03-08"
String dpdAppLabel() => 'DPD ${_platform()} ${dpdDateStamp()}';
