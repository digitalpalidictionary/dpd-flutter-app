import 'package:dpd_flutter_app/utils/back_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAndroidBackAction', () {
    test('returns exitApp on non-Android platforms', () {
      final action = resolveAndroidBackAction(
        isAndroid: false,
        hasAutocompleteOverlay: true,
        hasHelpPopup: true,
        hasInfoOverlay: true,
        hasActiveInfoView: true,
        canGoBackInHistory: true,
      );

      expect(action, AndroidBackAction.exitApp);
    });

    test('dismisses overlays before navigating history', () {
      final action = resolveAndroidBackAction(
        isAndroid: true,
        hasAutocompleteOverlay: false,
        hasHelpPopup: false,
        hasInfoOverlay: false,
        hasActiveInfoView: true,
        canGoBackInHistory: true,
      );

      expect(action, AndroidBackAction.dismissOverlay);
    });

    test('navigates history when no overlays are open', () {
      final action = resolveAndroidBackAction(
        isAndroid: true,
        hasAutocompleteOverlay: false,
        hasHelpPopup: false,
        hasInfoOverlay: false,
        hasActiveInfoView: false,
        canGoBackInHistory: true,
      );

      expect(action, AndroidBackAction.navigateHistoryBack);
    });

    test('exits app when there is no history and no overlays', () {
      final action = resolveAndroidBackAction(
        isAndroid: true,
        hasAutocompleteOverlay: false,
        hasHelpPopup: false,
        hasInfoOverlay: false,
        hasActiveInfoView: false,
        canGoBackInHistory: false,
      );

      expect(action, AndroidBackAction.exitApp);
    });
  });
}
