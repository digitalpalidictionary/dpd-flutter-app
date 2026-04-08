enum AndroidBackAction {
  dismissOverlay,
  navigateHistoryBack,
  exitApp,
}

AndroidBackAction resolveAndroidBackAction({
  required bool isAndroid,
  required bool hasAutocompleteOverlay,
  required bool hasHelpPopup,
  required bool hasInfoOverlay,
  required bool hasActiveInfoView,
  required bool canGoBackInHistory,
}) {
  if (!isAndroid) return AndroidBackAction.exitApp;

  if (hasAutocompleteOverlay ||
      hasHelpPopup ||
      hasInfoOverlay ||
      hasActiveInfoView) {
    return AndroidBackAction.dismissOverlay;
  }

  if (canGoBackInHistory) {
    return AndroidBackAction.navigateHistoryBack;
  }

  return AndroidBackAction.exitApp;
}
