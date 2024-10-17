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
      final result = await methodChannel.invokeMethod('checkForUpdate');
      final appUpdateInfo =
          AppUpdateInfoDto.fromMap(Map<String, dynamic>.from(result));
      return ObjectResponse<AppUpdateInfoDto, dynamic>.success(
          data: appUpdateInfo);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return const ObjectResponse<AppUpdateInfoDto, dynamic>.error();
    }
  }

  @override
  Future<AppUpdateResult> performImmediateUpdate() async {
    try {
      await methodChannel.invokeMethod('performImmediateUpdate');
      return AppUpdateResult.success;
    } on PlatformException catch (e) {
      if (e.code == _kUserDeniedUpdate) {
        return AppUpdateResult.userDeniedUpdate;
      }
      return AppUpdateResult.inAppUpdateFailed;
    }
  }

  @override
  Future<AppUpdateResult> startFlexibleUpdate() async {
    try {
      await methodChannel.invokeMethod('startFlexibleUpdate');
      return AppUpdateResult.success;
    } on PlatformException catch (e) {
      if (e.code == _kUserDeniedUpdate) {
        return AppUpdateResult.userDeniedUpdate;
      }
      return AppUpdateResult.inAppUpdateFailed;
    }
  }

  @override
  Future<void> completeFlexibleUpdate() async {
    return await methodChannel.invokeMethod('completeFlexibleUpdate');
  }

  @override
  Future<ObjectResponse<Map<String, dynamic>, String>>
      getPackageDetail() async {
    try {
      final result = await methodChannel.invokeMethod('getPackageDetail');
      final castedData = Map<String, dynamic>.from(result);
      return ObjectResponse<Map<String, dynamic>, String>.success(
          data: castedData);
    } catch (e) {
      return const ObjectResponse<Map<String, dynamic>, String>.error();
    }
  }

  @override
  Future<ObjectResponse<Map<String, dynamic>, String>> getDeviceInfo() async {
    try {
      final result = await methodChannel.invokeMethod('getDeviceInfo');
      final castedData = Map<String, dynamic>.from(result);
      return ObjectResponse<Map<String, dynamic>, String>.success(
          data: castedData);
    } catch (e) {
      return const ObjectResponse<Map<String, dynamic>, String>.error();
    }
  }
}
