part of 'remote_store_data_source.dart';

class RemoteStoreDataSourceImpl implements RemoteStoreDataSource {
  final String playStoreURL = 'https://play.google.com';
  final String itunesURL = 'https://itunes.apple.com';
  final String playStoreDetail = '/store/apps/details';
  final String lookup = '/lookup';

  @override
  Future<ObjectResponse<Version, dynamic>> fetchItunesVersion(
      String applicationId,
      {String countryCode = 'RU'}) async {
    final dio = Dio(BaseOptions(baseUrl: itunesURL));
    try {
      final response = await dio.get(lookup, queryParameters: {
        'bundleId': applicationId,
        'country': countryCode.toUpperCase(),
      });
      var itunesData = ItunesDto.fromRawJson(response.data);
      final version = Version.parse(itunesData.results.first.version);
      return ObjectResponse<Version, dynamic>.success(data: version);
    } catch (e) {
      return const ObjectResponse<Version, dynamic>.error();
    }
  }

  @override
  Future<ObjectResponse<Version, dynamic>> fetchPlayStoreVersion(
      String applicationId,
      {String countryCode = 'RU',
      String lang = 'ru'}) async {
    final dio = Dio(BaseOptions(baseUrl: playStoreURL));
    try {
      final response = await dio.get(playStoreDetail, queryParameters: {
        'id': applicationId,
        'gl': countryCode.toUpperCase(),
        'hl': lang,
        '_cb': DateTime.now().microsecondsSinceEpoch.toString()
      });
      var statusCode = response.statusCode ?? -1;
      if (statusCode < HttpStatus.ok ||
          statusCode >= HttpStatus.multipleChoices) {
        return const ObjectResponse<Version, dynamic>.error();
      }
      final version = VersionParseUtil.plyStoreVersion(response.data);
      return ObjectResponse<Version, dynamic>.success(data: version);
    } on DioException catch (e) {
      return ObjectResponse<Version, dynamic>.error(error: e);
    } catch (e) {
      return const ObjectResponse<Version, dynamic>.error();
    }
  }

  @override
  Future<ObjectResponse<bool, dynamic>> fetchRustroreUpdate() async {
    try {
      final result = await RustoreUpdateClient.info();
      bool isAvailable =
          result.updateAvailability == UPDATE_AILABILITY_AVAILABLE;
      return ObjectResponse<bool, dynamic>.success(data: isAvailable);
    } on Object catch (e) {
      return ObjectResponse<bool, dynamic>.error(error: e);
    }
  }

  @override
  Future<ObjectResponse<void, dynamic>> rustorePerformImmediateUpdate() async {
    try {
      final result = await RustoreUpdateClient.immediate();
      bool isOk = result.code == ACTIVITY_RESULT_OK ||
          result.code == ACTIVITY_RESULT_CANCELED;
      return isOk
          ? const ObjectResponse<void, dynamic>.success()
          : const ObjectResponse<void, dynamic>.error();
    } on Object catch (e) {
      return ObjectResponse<void, dynamic>.error(error: e);
    }
  }
}
