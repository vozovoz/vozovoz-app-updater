part of 'package_repository.dart';

class PackageRepositoryImpl implements PackageRepository {
  final MethodChannelVozovozAppUpdater _methodChannel =
      MethodChannelVozovozAppUpdater();

  @override
  Future<PackageDetail> fetchPackageDetail() async {
    final result = await _methodChannel.getPackageDetail();
    if (result.isSuccessful) {
      return PackageDetail.fromMap(result.data!);
    }
    return const PackageDetail.empty();
  }
}
