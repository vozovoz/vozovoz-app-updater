import 'package:version/version.dart';
import 'package:vozovoz_app_updater/remote/util/version_parse_util.dart';

class PackageDetail {
  const PackageDetail({
    required this.appName,
    required this.packageName,
    required this.versionString,
    required this.buildNumber,
    this.buildSignature = '',
  });

  const PackageDetail.empty()
      : this(
          appName: '',
          packageName: '',
          versionString: '0.0.0',
          buildNumber: '',
        );

  factory PackageDetail.fromMap(Map<String, dynamic> json) {
    return PackageDetail(
      appName: json['appName']?.toString() ?? '',
      packageName: json['packageName']?.toString() ?? '',
      versionString: json['version']?.toString() ?? '0.0.0',
      buildNumber: json['buildNumber']?.toString() ?? '',
    );
  }

  final String appName;
  final String packageName;
  final String versionString;
  final String buildNumber;
  final String buildSignature;

  /// Версия приложения. Если нативная сторона вернула что-то нечитаемое
  /// (например `1.2` или пустую строку), отдаём `0.0.0` — так проверка
  /// обновления просто покажет, что доступна более новая версия, вместо падения.
  Version get version =>
      VersionParseUtil.tryParse(versionString) ?? Version(0, 0, 0);

  bool get isNotEmpty =>
      appName.isNotEmpty && packageName.isNotEmpty && buildNumber.isNotEmpty;
}
