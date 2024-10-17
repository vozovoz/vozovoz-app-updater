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
}
