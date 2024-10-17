import 'dart:io';

import 'package:dio/dio.dart';
import 'package:version/version.dart';
import 'package:vozovoz_app_updater/remote/data_source/dto/object_response.dart';

import '../../util/version_parse_util.dart';
import '../dto/itunes_dto.dart';

part 'remote_store_data_source_impl.dart';

abstract class RemoteStoreDataSource {
  factory RemoteStoreDataSource() = RemoteStoreDataSourceImpl;

  Future<ObjectResponse<Version, dynamic>> fetchPlayStoreVersion(
    String applicationId, {
    String countryCode,
    String lang,
  });

  Future<ObjectResponse<Version, dynamic>> fetchItunesVersion(
    String applicationId, {
    String countryCode = 'RU',
  });
}
