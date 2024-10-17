import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_method_channel.dart';

void main() {
  MethodChannelVozovozAppUpdater platform = MethodChannelVozovozAppUpdater();
  const MethodChannel channel = MethodChannel('vozovoz_app_updater');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (message) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (message) async {
      return null;
    });
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
