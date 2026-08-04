part of 'remote_store_data_source.dart';

class RemoteStoreDataSourceImpl implements RemoteStoreDataSource {
  RemoteStoreDataSourceImpl({Dio? playStoreClient, Dio? itunesClient})
      : _playStoreClient = playStoreClient ??
            Dio(BaseOptions(
              baseUrl: _playStoreURL,
              connectTimeout: _timeout,
              receiveTimeout: _timeout,
              responseType: ResponseType.plain,
            )),
        _itunesClient = itunesClient ??
            Dio(BaseOptions(
              baseUrl: _itunesURL,
              connectTimeout: _timeout,
              receiveTimeout: _timeout,
            ));

  static const _playStoreURL = 'https://play.google.com';
  static const _itunesURL = 'https://itunes.apple.com';
  static const _playStoreDetail = '/store/apps/details';
  static const _lookup = '/lookup';
  static const _timeout = Duration(seconds: 15);

  final Dio _playStoreClient;
  final Dio _itunesClient;

  @override
  Future<ObjectResponse<Version, dynamic>> fetchItunesVersion(
    String applicationId, {
    String countryCode = 'RU',
  }) async {
    try {
      final response = await _itunesClient.get(_lookup, queryParameters: {
        'bundleId': applicationId,
        'country': countryCode.toUpperCase(),
      });
      // `response.data` — уже разобранный Map (Dio по умолчанию декодирует
      // JSON), поэтому передавать его в `json.decode` нельзя.
      final itunesData = ItunesDto.fromResponse(response.data);
      if (itunesData.results.isEmpty) {
        return const ObjectResponse<Version, dynamic>.error(
          error: 'App is not found in the App Store',
        );
      }
      final version = VersionParseUtil.tryParse(itunesData.results.first.version);
      if (version == null) {
        return const ObjectResponse<Version, dynamic>.error(
          error: 'Unable to parse App Store version',
        );
      }
      return ObjectResponse<Version, dynamic>.success(data: version);
    } on DioException catch (e) {
      return ObjectResponse<Version, dynamic>.error(
        error: e,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ObjectResponse<Version, dynamic>.error(error: e);
    }
  }

  @override
  Future<ObjectResponse<Version, dynamic>> fetchPlayStoreVersion(
    String applicationId, {
    String countryCode = 'RU',
    String lang = 'ru',
  }) async {
    try {
      final response =
          await _playStoreClient.get(_playStoreDetail, queryParameters: {
        'id': applicationId,
        'gl': countryCode.toUpperCase(),
        'hl': lang,
        '_cb': DateTime.now().microsecondsSinceEpoch.toString(),
      });
      final statusCode = response.statusCode ?? -1;
      if (statusCode < HttpStatus.ok ||
          statusCode >= HttpStatus.multipleChoices) {
        return ObjectResponse<Version, dynamic>.error(statusCode: statusCode);
      }
      final version = VersionParseUtil.playStoreVersion('${response.data}');
      if (version == null) {
        return const ObjectResponse<Version, dynamic>.error(
          error: 'Unable to parse Play Store version',
        );
      }
      return ObjectResponse<Version, dynamic>.success(data: version);
    } on DioException catch (e) {
      return ObjectResponse<Version, dynamic>.error(
        error: e,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ObjectResponse<Version, dynamic>.error(error: e);
    }
  }

  @override
  Future<ObjectResponse<bool, dynamic>> fetchRustroreUpdate() async {
    try {
      final result = await RustoreUpdateClient.info();
      final isAvailable =
          result.updateAvailability == UPDATE_AVAILABILITY_AVAILABLE;
      return ObjectResponse<bool, dynamic>.success(data: isAvailable);
    } on Object catch (e) {
      return ObjectResponse<bool, dynamic>.error(error: e);
    }
  }

  @override
  Future<ObjectResponse<int, dynamic>> rustorePerformImmediateUpdate() async {
    try {
      final result = await RustoreUpdateClient.immediate();
      return ObjectResponse<int, dynamic>.success(data: result.code);
    } on Object catch (e) {
      return ObjectResponse<int, dynamic>.error(error: e);
    }
  }
}
