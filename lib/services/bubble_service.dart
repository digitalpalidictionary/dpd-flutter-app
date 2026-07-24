import 'package:flutter/services.dart';

/// Client for the Android accessibility floating-bubble service.
/// Backed by the native `net.dpdict.app/bubble` MethodChannel in MainActivity.
class BubbleService {
  static const _channel = MethodChannel('net.dpdict.app/bubble');

  /// Whether the DPD accessibility service is currently enabled in Android.
  static Future<bool> isEnabled() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('isEnabled');
      return enabled ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Whether the user has turned the bubble on (persisted natively). Reflects
  /// the toggle position even before the accessibility service is enabled.
  static Future<bool> isBubbleOn() async {
    try {
      final on = await _channel.invokeMethod<bool>('isBubbleOn');
      return on ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens Android's accessibility settings page so the user can enable DPD.
  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Shows the floating bubble, optionally styling it with the current theme's
  /// primary (circle) and on-primary (label) colours as ARGB ints. Returns
  /// false if the service isn't running.
  static Future<bool> showBubble({int? bgArgb, int? textArgb}) async {
    try {
      final args = <String, int>{};
      if (bgArgb != null) args['bg'] = bgArgb;
      if (textArgb != null) args['text'] = textArgb;
      final shown = await _channel.invokeMethod<bool>(
        'showBubble',
        args.isEmpty ? null : args,
      );
      return shown ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Recolours the bubble to the current theme (used when the theme changes
  /// while the bubble is already showing).
  static Future<void> setBubbleColors(int bgArgb, int textArgb) async {
    try {
      await _channel.invokeMethod('setBubbleColor', {
        'bg': bgArgb,
        'text': textArgb,
      });
    } catch (_) {}
  }

  /// Hides the floating bubble.
  static Future<void> hideBubble() async {
    try {
      await _channel.invokeMethod('hideBubble');
    } catch (_) {}
  }
}
