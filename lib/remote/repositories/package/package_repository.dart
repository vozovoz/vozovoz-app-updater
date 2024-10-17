import 'package:vozovoz_app_updater/remote/data/package_detail.dart';
import 'package:vozovoz_app_updater/remote/data_source/platform/vozovoz_app_updater_method_channel.dart';

part 'package_repository_impl.dart';

abstract class PackageRepository {
  factory PackageRepository() = PackageRepositoryImpl;

  Future<PackageDetail> fetchPackageDetail();
}
