import 'package:vozovoz_app_updater/remote/data/app_installation_source.dart';
import 'package:vozovoz_app_updater/remote/data/app_update_result.dart';
import 'package:vozovoz_app_updater/remote/data/package_detail.dart';
import 'package:vozovoz_app_updater/remote/data/update_availability.dart';
import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_platform_interface.dart';
import 'package:vozovoz_app_updater/remote/repositories/index.dart';

// Публичный API пакета: без этих реэкспортов потребителю приходилось
// импортировать внутренние пути `remote/data/...`.
export 'package:vozovoz_app_updater/remote/data/app_installation_source.dart';
export 'package:vozovoz_app_updater/remote/data/app_update_result.dart';
export 'package:vozovoz_app_updater/remote/data/install_status.dart';
export 'package:vozovoz_app_updater/remote/data/package_detail.dart';
export 'package:vozovoz_app_updater/remote/data/update_availability.dart';

class VozovozAppUpdater {
  static VozovozAppUpdater? _instance;
  PackageDetail? _packageDetail;

  final UpdaterRepository _updaterRepository = UpdaterRepository();
  final PackageRepository _packageRepository = PackageRepository();

  VozovozAppUpdater._internal();

  static VozovozAppUpdater get instance {
    _instance ??= VozovozAppUpdater._internal();
    return _instance!;
  }

  Future<PackageDetail> getPackageDetail() async {
    if (_packageDetail?.isNotEmpty == true) {
      return _packageDetail!;
    }
    _packageDetail = await _packageRepository.fetchPackageDetail();
    return _packageDetail!;
  }

  Future<String?> getPlatformVersion() {
    return VozovozAppUpdaterPlatform.instance.getPlatformVersion();
  }

  Future<UpdateAvailability> checkUpdate(AppInstallationSource source) async {
    final packageDetail = await getPackageDetail();
    final applicationId = packageDetail.packageName;
    final version = packageDetail.version;
    return _updaterRepository.checkUpdate(
      applicationId,
      version,
      source,
    );
  }

  /// Принудительное обновление через Google Play. Только Android.
  Future<AppUpdateResult> performImmediateUpdate() {
    return _updaterRepository.performImmediateUpdate();
  }

  /// Принудительное обновление через RuStore. Только Android.
  Future<AppUpdateResult> performRustoreImmediateUpdate() {
    return _updaterRepository.performRustoreImmediateUpdate();
  }

  /// Гибкое обновление через Google Play: пользователь продолжает работать,
  /// пока обновление скачивается. Возвращается после окончания загрузки —
  /// затем нужно вызвать [completeFlexibleUpdate]. Только Android.
  Future<AppUpdateResult> startFlexibleUpdate() {
    return _updaterRepository.startFlexibleUpdate();
  }

  /// Перезапускает приложение и применяет обновление, скачанное
  /// через [startFlexibleUpdate]. Только Android.
  Future<void> completeFlexibleUpdate() {
    return _updaterRepository.completeFlexibleUpdate();
  }
}
