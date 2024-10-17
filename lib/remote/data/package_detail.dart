import 'package:version/version.dart';

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
      appName: json['appName'] ?? '',
      packageName: json['packageName'] ?? '',
      versionString: json['version'] ?? '0.0.0',
      buildNumber: json['buildNumber'] ?? '',
    );
  }

  final String appName;
  final String packageName;
  final String versionString;
  final String buildNumber;
  final String buildSignature;

  Version get version => Version.parse(versionString);

  bool get isNotEmpty =>
      appName.isNotEmpty && packageName.isNotEmpty && buildNumber.isNotEmpty;
}
