import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vozovoz_app_updater/remote/data/app_update_result.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/app_update_info_dto.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/object_response.dart';

import 'vozovoz_app_updater_method_channel.dart';

abstract class VozovozAppUpdaterPlatform extends PlatformInterface {
  /// Constructs a VozovozAppUpdaterPlatform.
  VozovozAppUpdaterPlatform() : super(token: _token);

  static final Object _token = Object();

  static VozovozAppUpdaterPlatform _instance = MethodChannelVozovozAppUpdater();

  /// The default instance of [VozovozAppUpdaterPlatform] to use.
  ///
  /// Defaults to [MethodChannelVozovozAppUpdater].
  static VozovozAppUpdaterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VozovozAppUpdaterPlatform] when
  /// they register themselves.
  static set instance(VozovozAppUpdaterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<ObjectResponse<AppUpdateInfoDto, dynamic>> checkUpdateGoogleService() {
    throw UnimplementedError(
        'checkUpdateGoogleService() has not been implemented.');
  }

  /// Принудительное  обновление
  /// не пускает в приложение
  /// работает только на  Android
  Future<AppUpdateResult> performImmediateUpdate() {
    throw UnimplementedError(
        'performImmediateUpdate() has not been implemented.');
  }

  /// гибкое обновление
  /// разрешает пользователю сервфить прилку пока качается обнова
  /// работает только на  Android
  Future<AppUpdateResult> startFlexibleUpdate() {
    throw UnimplementedError('startFlexibleUpdate() has not been implemented.');
  }

  /// после того как скачается обновление [startFlexibleUpdate]
  /// перезапускает приложение для применения обновы
  /// работает только на  Android
  Future<void> completeFlexibleUpdate() {
    throw UnimplementedError(
        'completeFlexibleUpdate() has not been implemented.');
  }

  Future<ObjectResponse<Map<String, dynamic>, String>> getPackageDetail() {
    throw UnimplementedError('getPackageDetail() has not been implemented.');
  }

  Future<ObjectResponse<Map<String, dynamic>, String>> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }
}
