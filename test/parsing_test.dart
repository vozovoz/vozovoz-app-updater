import 'package:flutter_test/flutter_test.dart';
import 'package:version/version.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/app_update_info_dto.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/itunes_dto.dart';
import 'package:vozovoz_app_updater/remote/util/version_parse_util.dart';
import 'package:vozovoz_app_updater/vozovoz_app_updater.dart';

void main() {
  group('UpdateAvailability.fromPlayCore', () {
    test('маппит коды Play Core, а не индексы enum', () {
      expect(UpdateAvailability.fromPlayCore(0), UpdateAvailability.unknown);
      expect(
        UpdateAvailability.fromPlayCore(1),
        UpdateAvailability.updateNotAvailable,
      );
      expect(
        UpdateAvailability.fromPlayCore(2),
        UpdateAvailability.updateAvailableGoogleService,
      );
      // Код 3 раньше по индексу превращался в updateAvailableRustore.
      expect(
        UpdateAvailability.fromPlayCore(3),
        UpdateAvailability.developerTriggeredUpdateInProgress,
      );
    });

    test('неизвестные значения дают unknown', () {
      expect(UpdateAvailability.fromPlayCore(null), UpdateAvailability.unknown);
      expect(UpdateAvailability.fromPlayCore(42), UpdateAvailability.unknown);
    });
  });

  group('InstallStatus.fromPlayCore', () {
    test('маппит известные коды', () {
      expect(InstallStatus.fromPlayCore(11), InstallStatus.downloaded);
      expect(InstallStatus.fromPlayCore(4), InstallStatus.installed);
    });

    test('не бросает на неизвестном коде', () {
      expect(InstallStatus.fromPlayCore(99), InstallStatus.unknown);
      expect(InstallStatus.fromPlayCore(null), InstallStatus.unknown);
    });
  });

  group('AppUpdateInfoDto.fromMap', () {
    test('разбирает ответ Android-плагина', () {
      final dto = AppUpdateInfoDto.fromMap(const {
        'updateAvailability': 2,
        'immediateAllowed': true,
        'flexibleAllowed': false,
        'availableVersionCode': 42,
        'installStatus': 11,
        'packageName': 'com.vozovoz.app',
        'clientVersionStalenessDays': null,
        'updatePriority': 3,
      });

      expect(dto.updateAvailability,
          UpdateAvailability.updateAvailableGoogleService);
      expect(dto.immediateUpdateAllowed, isTrue);
      expect(dto.flexibleUpdateAllowed, isFalse);
      expect(dto.availableVersionCode, 42);
      expect(dto.installStatus, InstallStatus.downloaded);
      expect(dto.clientVersionStalenessDays, isNull);
      expect(dto.updatePriority, 3);
    });

    test('переживает частично пустой ответ', () {
      final dto = AppUpdateInfoDto.fromMap(const {});
      expect(dto.updateAvailability, UpdateAvailability.unknown);
      expect(dto.installStatus, InstallStatus.unknown);
      expect(dto.packageName, '');
      expect(dto.updatePriority, 0);
    });
  });

  group('VersionParseUtil.tryParse', () {
    test('разбирает полные версии', () {
      expect(VersionParseUtil.tryParse('1.2.3'), Version(1, 2, 3));
      expect(VersionParseUtil.tryParse(' 1.2.3 '), Version(1, 2, 3));
    });

    test('дополняет сокращённые версии вместо FormatException', () {
      expect(VersionParseUtil.tryParse('1.2'), Version(1, 2, 0));
      expect(VersionParseUtil.tryParse('7'), Version(7, 0, 0));
    });

    test('возвращает null на мусоре', () {
      expect(VersionParseUtil.tryParse(''), isNull);
      expect(VersionParseUtil.tryParse(null), isNull);
      expect(VersionParseUtil.tryParse('нет версии'), isNull);
    });
  });

  group('PackageDetail', () {
    test('не бросает на некорректной версии', () {
      const detail = PackageDetail(
        appName: 'app',
        packageName: 'com.vozovoz.app',
        versionString: '1.2',
        buildNumber: '10',
      );
      expect(detail.version, Version(1, 2, 0));
      expect(const PackageDetail.empty().version, Version(0, 0, 0));
    });
  });

  group('ItunesDto.fromResponse', () {
    const payload = {
      'resultCount': 1,
      'results': [
        {'version': '2.5.0', 'wrapperType': 'software', 'userRatingCount': 10},
      ],
    };

    test('принимает уже разобранный Dio-ответ (Map)', () {
      final dto = ItunesDto.fromResponse(payload);
      expect(dto.resultCount, 1);
      expect(dto.results.single.version, '2.5.0');
    });

    test('принимает сырую строку', () {
      final dto = ItunesDto.fromResponse(
        '{"resultCount":1,"results":[{"version":"2.5.0"}]}',
      );
      expect(dto.results.single.version, '2.5.0');
    });

    test('пустой ответ App Store не роняет разбор', () {
      final dto = ItunesDto.fromResponse(const {
        'resultCount': 0,
        'results': <Object?>[],
      });
      expect(dto.results, isEmpty);
    });
  });
}
