class ObjectResponse<T, E> {
  final _ResponseStatus? _responseStatus;
  final T? data;
  final E? error;
  final int? statusCode;

  const ObjectResponse._(
    this._responseStatus, {
    this.data,
    this.error,
    this.statusCode,
  });

  const ObjectResponse.success({T? data})
      : this._(
          _ResponseStatus.success,
          data: data,
        );

  const ObjectResponse.error({E? error, int? statusCode})
      : this._(_ResponseStatus.error, error: error, statusCode: statusCode);

  bool get isSuccessful => _responseStatus == _ResponseStatus.success;

  bool get isError => _responseStatus == _ResponseStatus.error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectResponse &&
          runtimeType == other.runtimeType &&
          _responseStatus == other._responseStatus &&
          data == other.data &&
          error == other.error &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(_responseStatus, data, error, statusCode);
}

enum _ResponseStatus {
  success,
  error,
}
