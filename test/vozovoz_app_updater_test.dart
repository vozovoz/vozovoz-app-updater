import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vozovoz_app_updater/remote/data/app_update_result.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/app_update_info_dto.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/object_response.dart';
import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_method_channel.dart';
import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_platform_interface.dart';
import 'package:vozovoz_app_updater/vozovoz_app_updater.dart';

class MockVozovozAppUpdaterPlatform
    with MockPlatformInterfaceMixin
    implements VozovozAppUpdaterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<ObjectResponse<AppUpdateInfoDto, dynamic>>
      checkUpdateGoogleService() => Future.value(
            const ObjectResponse<AppUpdateInfoDto, dynamic>.error(),
          );

  @override
  Future<void> completeFlexibleUpdate() =>
      Future.delayed(const Duration(seconds: 5));

  @override
  Future<AppUpdateResult> performImmediateUpdate() =>
      Future.value(AppUpdateResult.userDeniedUpdate);

  @override
  Future<AppUpdateResult> startFlexibleUpdate() =>
      Future.value(AppUpdateResult.userDeniedUpdate);

  @override
  Future<ObjectResponse<Map<String, dynamic>, String>> getPackageDetail() {
    // TODO: implement getPackageDetail
    throw UnimplementedError();
  }

  @override
  Future<ObjectResponse<Map<String, dynamic>, String>> getDeviceInfo() {
    // TODO: implement getDeviceInfo
    throw UnimplementedError();
  }
}

void main() {
  final VozovozAppUpdaterPlatform initialPlatform =
      VozovozAppUpdaterPlatform.instance;

  test('$MethodChannelVozovozAppUpdater is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVozovozAppUpdater>());
  });

  test('getPlatformVersion', () async {
    VozovozAppUpdater vozovozAppUpdaterPlugin = VozovozAppUpdater.instance;
    MockVozovozAppUpdaterPlatform fakePlatform =
        MockVozovozAppUpdaterPlatform();
    VozovozAppUpdaterPlatform.instance = fakePlatform;

    expect(await vozovozAppUpdaterPlugin.getPlatformVersion(), '42');
  });
}
