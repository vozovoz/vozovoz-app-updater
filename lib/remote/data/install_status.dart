enum InstallStatus {
  unknown(0),
  pending(1),
  downloading(2),
  installing(3),
  installed(4),
  failed(5),
  canceled(6),
  downloaded(11);

  const InstallStatus(this.value);
  final int value;

  /// Маппинг кодов `com.google.android.play.core.install.model.InstallStatus`.
  /// Неизвестный код не должен ронять разбор ответа.
  static InstallStatus fromPlayCore(Object? value) {
    return InstallStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => InstallStatus.unknown,
    );
  }
}
