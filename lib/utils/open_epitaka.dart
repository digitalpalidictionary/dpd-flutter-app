import 'package:flutter/services.dart' show PlatformException;
import 'package:url_launcher/url_launcher.dart';

import '../database/database.dart';
import '../database/sutta_info_extensions.dart';

Future<bool> _launchExternal(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// Opens [sutta] in the ePitaka app. When no app takes the link, the web link
/// opens instead: the epitaka.org page tells the reader the app is needed.
/// [launch] stands in for the system launcher in tests.
Future<void> openInEpitaka(
  SuttaInfoData sutta, {
  Future<bool> Function(Uri uri) launch = _launchExternal,
}) async {
  final appLink = sutta.epitakaLink;
  final webLink = sutta.epitakaWebLink;
  if (appLink == null || webLink == null) return;
  var opened = false;
  try {
    opened = await launch(Uri.parse(appLink));
  } on PlatformException {
    // Some systems throw, not return false, when nothing takes the link.
    opened = false;
  }
  if (!opened) await launch(Uri.parse(webLink));
}
