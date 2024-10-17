import 'package:vozovoz_app_updater/remote/data/install_status.dart';
import 'package:vozovoz_app_updater/remote/data/update_availability.dart';

class AppUpdateInfoDto {
  AppUpdateInfoDto({
    required this.updateAvailability,
    required this.immediateUpdateAllowed,
    required this.flexibleUpdateAllowed,
    required this.availableVersionCode,
    required this.installStatus,
    required this.packageName,
    required this.clientVersionStalenessDays,
    required this.updatePriority,
  });

  factory AppUpdateInfoDto.fromMap(Map<String, dynamic> json) {
    return AppUpdateInfoDto(
      updateAvailability: UpdateAvailability.values
          .firstWhere((element) => element.index == json['updateAvailability']),
      immediateUpdateAllowed: json['immediateAllowed'],
      flexibleUpdateAllowed: json['flexibleAllowed'],
      availableVersionCode: json['availableVersionCode'],
      installStatus: InstallStatus.values
          .firstWhere((element) => element.value == json['installStatus']),
      packageName: json['packageName'],
      clientVersionStalenessDays: json['clientVersionStalenessDays'],
      updatePriority: json['updatePriority'],
    );
  }

  final UpdateAvailability updateAvailability;
  final bool immediateUpdateAllowed;
  final bool flexibleUpdateAllowed;
  final int? availableVersionCode;
  final InstallStatus installStatus;
  final String packageName;
  final int updatePriority;
  final int? clientVersionStalenessDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUpdateInfoDto &&
          runtimeType == other.runtimeType &&
          updateAvailability == other.updateAvailability &&
          immediateUpdateAllowed == other.immediateUpdateAllowed &&
          flexibleUpdateAllowed == other.flexibleUpdateAllowed &&
          availableVersionCode == other.availableVersionCode &&
          installStatus == other.installStatus &&
          packageName == other.packageName &&
          clientVersionStalenessDays == other.clientVersionStalenessDays &&
          updatePriority == other.updatePriority;

  @override
  int get hashCode =>
      updateAvailability.hashCode ^
      immediateUpdateAllowed.hashCode ^
      flexibleUpdateAllowed.hashCode ^
      availableVersionCode.hashCode ^
      installStatus.hashCode ^
      packageName.hashCode ^
      clientVersionStalenessDays.hashCode ^
      updatePriority.hashCode;

  @override
  String toString() =>
      'InAppUpdateState{updateAvailability: $updateAvailability, '
      'immediateUpdateAllowed: $immediateUpdateAllowed, '
      'flexibleUpdateAllowed: $flexibleUpdateAllowed, '
      'availableVersionCode: $availableVersionCode, '
      'installStatus: $installStatus, '
      'packageName: $packageName, '
      'clientVersionStalenessDays: $clientVersionStalenessDays, '
      'updatePriority: $updatePriority}';
}
