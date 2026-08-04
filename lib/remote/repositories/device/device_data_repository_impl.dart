part of 'device_data_repository.dart';

class DeviceDataRepositoryImpl implements DeviceDataRepository {
  VozovozAppUpdaterPlatform get _platform => VozovozAppUpdaterPlatform.instance;

  @override
  Future<Map<String, dynamic>> fetchDeviceInfo() async {
    final result = await _platform.getDeviceInfo();
    if (result.isSuccessful) {
      return result.data!;
    }
    return const <String, dynamic>{};
  }
}
