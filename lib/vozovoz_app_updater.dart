import 'package:vozovoz_app_updater/remote/data/app_installation_source.dart';
import 'package:vozovoz_app_updater/remote/data/app_update_result.dart';
import 'package:vozovoz_app_updater/remote/data/package_detail.dart';
import 'package:vozovoz_app_updater/remote/data/update_availability.dart';
import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_platform_interface.dart';
import 'package:vozovoz_app_updater/remote/repositories/index.dart';

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

  Future<AppUpdateResult> performImmediateUpdate() {
    return _updaterRepository.performImmediateUpdate();
  }

  Future<AppUpdateResult> performRustoreImmediateUpdate() {
    return _updaterRepository.performRustoreImmediateUpdate();
  }
}
