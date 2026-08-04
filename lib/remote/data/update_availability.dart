enum UpdateAvailability {
  unknown,
  updateNotAvailable,
  updateAvailableGoogleService,
  updateAvailableRustore,
  developerTriggeredUpdateInProgress,
  updateAvailable;

  /// Маппинг кодов `com.google.android.play.core.install.model.UpdateAvailability`.
  ///
  /// Порядок значений этого enum намеренно не совпадает с кодами Play Core,
  /// поэтому сопоставлять по `index` нельзя.
  static UpdateAvailability fromPlayCore(Object? value) {
    switch (value) {
      case 1:
        return UpdateAvailability.updateNotAvailable;
      case 2:
        return UpdateAvailability.updateAvailableGoogleService;
      case 3:
        return UpdateAvailability.developerTriggeredUpdateInProgress;
      default:
        return UpdateAvailability.unknown;
    }
  }
}
