class AppInfo {
  final String appName;
  final String apkPath;
  final String packageName;
  final String dataPath;
  final String obbPath;
  final String iconBase64;

  AppInfo({
    required this.appName,
    required this.apkPath,
    required this.packageName,
    required this.dataPath,
    required this.obbPath,
    required this.iconBase64,
  });

  factory AppInfo.fromMap(Map map) {
    return AppInfo(
      appName: map['appName'],
      apkPath: map['apkPath'],
      packageName: map['packageName'],
      dataPath: map['dataPath'],
      obbPath: map['obbPath'],
      iconBase64: map['icon'],
    );
  }
}
