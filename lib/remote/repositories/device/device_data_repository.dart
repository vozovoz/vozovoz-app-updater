import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_platform_interface.dart';

part "device_data_repository_impl.dart";

abstract class DeviceDataRepository {
  factory DeviceDataRepository() = DeviceDataRepositoryImpl;

  /// Информация об устройстве: `manufacturer`, `brand`, `model`, `device`,
  /// `systemVersion` (+ `sdkInt` на Android, `systemName` на iOS).
  /// Пустая карта, если нативная сторона недоступна.
  Future<Map<String, dynamic>> fetchDeviceInfo();
}
