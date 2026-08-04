part of 'updater_repository.dart';

class UpdaterRepositoryImpl implements UpdaterRepository {
  final RemoteStoreDataSource _remoteStoreDataSource = RemoteStoreDataSource();

  /// Идём через `instance`, а не через `MethodChannelVozovozAppUpdater()`
  /// напрямую: иначе подмена платформы (в том числе в тестах) не работает.
  VozovozAppUpdaterPlatform get _platform => VozovozAppUpdaterPlatform.instance;

  @override
  Future<UpdateAvailability> checkUpdate(
    String applicationId,
    Version currentVersion,
    AppInstallationSource source,
  ) async {
    switch (source) {
      case AppInstallationSource.googlePlay:
        return checkGooglePlay(applicationId, currentVersion);
      case AppInstallationSource.rustore:
        return checkRustoreVersion();
      case AppInstallationSource.appstore:
        return checkIosUpdate(applicationId, currentVersion);
      case AppInstallationSource.debug:
        return UpdateAvailability.unknown;
    }
  }

  Future<UpdateAvailability> checkGooglePlay(
    String applicationId,
    Version currentVersion,
  ) async {
    final googleServiceResult = await checkAndroidUpdateFromGoogleService();
    if (googleServiceResult != UpdateAvailability.unknown) {
      return googleServiceResult;
    }
    final playStoreResult = await checkAndroidUpdateFromPlayStore(
      applicationId,
      currentVersion,
    );
    return playStoreResult;
  }

  Future<UpdateAvailability> checkAndroidUpdateFromGoogleService() async {
    final result = await _platform.checkUpdateGoogleService();
    if (result.isSuccessful) {
      final info = result.data!;
      return info.updateAvailability;
    }
    return UpdateAvailability.unknown;
  }

  Future<UpdateAvailability> checkAndroidUpdateFromPlayStore(
    String applicationId,
    Version currentVersion,
  ) async {
    final result =
        await _remoteStoreDataSource.fetchPlayStoreVersion(applicationId);
    if (result.isSuccessful && result.data != null) {
      final version = result.data!;
      if (version.compareTo(currentVersion) > 0) {
        return UpdateAvailability.updateAvailable;
      } else {
        return UpdateAvailability.updateNotAvailable;
      }
    } else {
      return UpdateAvailability.unknown;
    }
  }

  Future<UpdateAvailability> checkIosUpdate(
    String applicationId,
    Version currentVersion,
  ) async {
    final result =
        await _remoteStoreDataSource.fetchItunesVersion(applicationId);
    if (result.isSuccessful && result.data != null) {
      final itunesVersion = result.data!;
      if (itunesVersion.compareTo(currentVersion) > 0) {
        return UpdateAvailability.updateAvailable;
      } else {
        return UpdateAvailability.updateNotAvailable;
      }
    } else {
      return UpdateAvailability.unknown;
    }
  }

  Future<UpdateAvailability> checkRustoreVersion() async {
    final result = await _remoteStoreDataSource.fetchRustroreUpdate();
    if (result.isError) {
      // Ошибка обращения к RuStore — это не «обновлений нет».
      return UpdateAvailability.unknown;
    }
    if (result.data == true) {
      return UpdateAvailability.updateAvailableRustore;
    }
    return UpdateAvailability.updateNotAvailable;
  }

  @override
  Future<void> completeFlexibleUpdate() {
    return _platform.completeFlexibleUpdate();
  }

  @override
  Future<AppUpdateResult> performImmediateUpdate() {
    return _platform.performImmediateUpdate();
  }

  @override
  Future<AppUpdateResult> startFlexibleUpdate() {
    return _platform.startFlexibleUpdate();
  }

  @override
  Future<AppUpdateResult> performRustoreImmediateUpdate() async {
    final result = await _remoteStoreDataSource.rustorePerformImmediateUpdate();
    if (!result.isSuccessful) {
      return AppUpdateResult.inAppUpdateFailed;
    }
    switch (result.data) {
      case ACTIVITY_RESULT_OK:
        return AppUpdateResult.success;
      // Раньше отмена пользователем возвращалась как success, из-за чего
      // вызывающий код считал, что приложение обновилось.
      case ACTIVITY_RESULT_CANCELED:
        return AppUpdateResult.userDeniedUpdate;
      default:
        return AppUpdateResult.inAppUpdateFailed;
    }
  }
}
