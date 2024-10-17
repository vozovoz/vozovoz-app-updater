import 'dart:io';

import 'package:version/version.dart';
import 'package:vozovoz_app_updater/remote/data/app_update_result.dart';
import 'package:vozovoz_app_updater/remote/data_source/index.dart';
import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_method_channel.dart';

import '../../data/update_availability.dart';

part 'updater_repository_impl.dart';

abstract class UpdaterRepository {
  factory UpdaterRepository() = UpdaterRepositoryImpl;

  Future<UpdateAvailability> checkUpdate(
    String applicationId,
    Version currentVersion,
  );

  Future<UpdateAvailability> checkAndroidUpdate(
    String applicationId,
    Version currentVersion,
  );

  Future<UpdateAvailability> checkAndroidUpdateFromGoogleService();

  Future<UpdateAvailability> checkAndroidUpdateFromPlayStore(
    String applicationId,
    Version currentVersion,
  );

  Future<UpdateAvailability> checkIosUpdate(
    String applicationId,
    Version currentVersion,
  );

  /// Принудительное  обновление
  /// не пускает в приложение
  /// работает только на  Android
  Future<AppUpdateResult> performImmediateUpdate();

  /// гибкое обновление
  /// разрешает пользователю сервфить прилку пока качается обнова
  /// работает только на  Android
  Future<AppUpdateResult> startFlexibleUpdate();

  /// после того как скачается обновление [startFlexibleUpdate]
  /// перезапускает приложение для применения обновы
  /// работает только на  Android
  Future<void> completeFlexibleUpdate();
}
