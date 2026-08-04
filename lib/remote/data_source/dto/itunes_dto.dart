import 'dart:convert';

class ItunesDto {
  ItunesDto({
    required this.resultCount,
    required this.results,
  });

  factory ItunesDto.fromRawJson(String str) =>
      ItunesDto.fromJson(json.decode(str) as Map<String, dynamic>);

  /// Dio отдаёт уже разобранный JSON, а при `ResponseType.plain` — строку.
  /// Поддерживаем оба варианта, чтобы разбор не зависел от настроек клиента.
  factory ItunesDto.fromResponse(Object? payload) {
    if (payload is String) {
      return ItunesDto.fromRawJson(payload);
    }
    if (payload is Map) {
      return ItunesDto.fromJson(Map<String, dynamic>.from(payload));
    }
    return ItunesDto(resultCount: 0, results: const <ItunesResult>[]);
  }

  factory ItunesDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    return ItunesDto(
      resultCount: json['resultCount'] as int? ?? 0,
      results: rawResults is List
          ? rawResults
              .whereType<Map>()
              .map((x) => ItunesResult.fromJson(Map<String, dynamic>.from(x)))
              .toList()
          : const <ItunesResult>[],
    );
  }

  final int resultCount;
  final List<ItunesResult> results;
}

class ItunesResult {
  const ItunesResult({
    required this.version,
    required this.wrapperType,
    required this.userRatingCount,
  });

  factory ItunesResult.fromRawJson(String str) =>
      ItunesResult.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ItunesResult.fromJson(Map<String, dynamic> json) => ItunesResult(
        version: json['version'] as String? ?? '',
        wrapperType: json['wrapperType'] as String? ?? '',
        userRatingCount: json['userRatingCount'] as int? ?? 0,
      );

  final String version;
  final String wrapperType;
  final int userRatingCount;
}
