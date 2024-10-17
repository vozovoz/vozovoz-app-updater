class ObjectResponse<T, E> {
  final _ResponseStatus? _responseStatus;
  final T? data;
  final E? error;

  const ObjectResponse._(
    this._responseStatus, {
    this.data,
    this.error,
  });

  const ObjectResponse.success({T? data})
      : this._(
          _ResponseStatus.success,
          data: data,
        );

  const ObjectResponse.error({E? error, int? statusCode})
      : this._(_ResponseStatus.error, error: error);

  bool get isSuccessful => _responseStatus == _ResponseStatus.success;

  bool get isError => _responseStatus == _ResponseStatus.error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectResponse &&
          runtimeType == other.runtimeType &&
          _responseStatus == other._responseStatus &&
          data == other.data &&
          error == other.error;

  @override
  int get hashCode => data.hashCode ^ error.hashCode ^ _responseStatus.hashCode;
}

enum _ResponseStatus {
  success,
  error,
}
