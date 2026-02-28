import 'package:flutter/services.dart';

/// Handles Android ACTION_PROCESS_TEXT intents.
///
/// When the user selects text in any app and chooses "Look up in DPD",
/// Android delivers the selected text via this channel.
class IntentService {
  static const _channel = MethodChannel('net.dpdict.app/intent');

  /// Returns the text delivered via ACTION_PROCESS_TEXT, or null if the app
  /// was launched normally (not via text selection intent).
  static Future<String?> getProcessTextExtra() async {
    try {
      final text = await _channel.invokeMethod<String>('getProcessText');
      return text?.trim().isEmpty == true ? null : text?.trim();
    } on MissingPluginException {
      // Not on Android or MainActivity not wired — ignore
      return null;
    } catch (_) {
      return null;
    }
  }
}
