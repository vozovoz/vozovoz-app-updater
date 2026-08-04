part of 'package_repository.dart';

class PackageRepositoryImpl implements PackageRepository {
  VozovozAppUpdaterPlatform get _platform => VozovozAppUpdaterPlatform.instance;

  @override
  Future<PackageDetail> fetchPackageDetail() async {
    final result = await _platform.getPackageDetail();
    if (result.isSuccessful) {
      return PackageDetail.fromMap(result.data!);
    }
    return const PackageDetail.empty();
  }
}
