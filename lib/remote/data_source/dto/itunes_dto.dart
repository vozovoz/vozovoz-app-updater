import 'dart:convert';

class ItunesDto {
  ItunesDto({
    required this.resultCount,
    required this.results,
  });

  factory ItunesDto.fromRawJson(String str) =>
      ItunesDto.fromJson(json.decode(str));

  factory ItunesDto.fromJson(Map<String, dynamic> json) => ItunesDto(
        resultCount: json['resultCount'],
        results: json['results'] != null
            ? List<Result>.from(json['results'].map((x) => Result.fromJson(x)))
            : <Result>[],
      );
  final int resultCount;
  final List<Result> results;
}

class Result {
  Result({
    required this.version,
    required this.wrapperType,
    required this.userRatingCount,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        version: json['version'],
        wrapperType: json['wrapperType'],
        userRatingCount: json['userRatingCount'],
      );
  final String version;
  final String wrapperType;
  final int userRatingCount;
}
