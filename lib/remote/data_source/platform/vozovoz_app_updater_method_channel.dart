import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vozovoz_app_updater/remote/data/app_update_result.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/app_update_info_dto.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/object_response.dart';

import 'vozovoz_app_updater_platform_interface.dart';

const String _kUserDeniedUpdate = 'USER_DENIED_UPDATE';

/// An implementation of [VozovozAppUpdaterPlatform] that uses method channels.
class MethodChannelVozovozAppUpdater extends VozovozAppUpdaterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vozovoz_app_updater');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<ObjectResponse<AppUpdateInfoDto, dynamic>>
      checkUpdateGoogleService() async {
    try {
      final result = await methodChannel.invokeMapMethod<String, dynamic>(
        'checkForUpdate',
      );
      if (result == null) {
        return const ObjectResponse<AppUpdateInfoDto, dynamic>.error();
      }
      return ObjectResponse<AppUpdateInfoDto, dynamic>.success(
        data: AppUpdateInfoDto.fromMap(result),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('checkUpdateGoogleService failed: $e');
      }
      return ObjectResponse<AppUpdateInfoDto, dynamic>.error(error: e);
    }
  }

  @override
  Future<AppUpdateResult> performImmediateUpdate() {
    return _invokeUpdateFlow('performImmediateUpdate');
  }

  @override
  Future<AppUpdateResult> startFlexibleUpdate() {
    return _invokeUpdateFlow('startFlexibleUpdate');
  }

  /// Общая обработка нативных flow обновления.
  ///
  /// Помимо [PlatformException] ловим и [MissingPluginException]: на iOS и в
  /// unit-тестах эти методы не реализованы, а `MissingPluginException` не
  /// наследуется от `PlatformException` и раньше улетал наружу неперехваченным.
  Future<AppUpdateResult> _invokeUpdateFlow(String method) async {
    try {
      await methodChannel.invokeMethod<void>(method);
      return AppUpdateResult.success;
    } on PlatformException catch (e) {
      if (e.code == _kUserDeniedUpdate) {
        return AppUpdateResult.userDeniedUpdate;
      }
      return AppUpdateResult.inAppUpdateFailed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$method failed: $e');
      }
      return AppUpdateResult.inAppUpdateFailed;
    }
  }

  @override
  Future<void> completeFlexibleUpdate() async {
    try {
      await methodChannel.invokeMethod<void>('completeFlexibleUpdate');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('completeFlexibleUpdate failed: $e');
      }
    }
  }

  @override
  Future<ObjectResponse<Map<String, dynamic>, String>> getPackageDetail() {
    return _invokeMapMethod('getPackageDetail');
  }

  @override
  Future<ObjectResponse<Map<String, dynamic>, String>> getDeviceInfo() {
    return _invokeMapMethod('getDeviceInfo');
  }

  Future<ObjectResponse<Map<String, dynamic>, String>> _invokeMapMethod(
    String method,
  ) async {
    try {
      final result =
          await methodChannel.invokeMapMethod<String, dynamic>(method);
      if (result == null) {
        return ObjectResponse<Map<String, dynamic>, String>.error(
          error: '$method returned null',
        );
      }
      return ObjectResponse<Map<String, dynamic>, String>.success(data: result);
    } catch (e) {
      return ObjectResponse<Map<String, dynamic>, String>.error(
        error: e.toString(),
      );
    }
  }
}
