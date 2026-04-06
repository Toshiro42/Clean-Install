import 'dart:convert';
import 'dart:typed_data';

class AppInfo {
  final String appName;
  final String apkPath;
  final String packageName;
  final String dataPath;
  final String obbPath;
  final Uint8List? iconBytes;

  AppInfo({
    required this.appName,
    required this.apkPath,
    required this.packageName,
    required this.dataPath,
    required this.obbPath,
    required this.iconBytes,
  });

  factory AppInfo.fromMap(Map map) {
    final String raw = map['icon'] as String? ?? '';
    Uint8List? bytes;
    if (raw.isNotEmpty) {
      try {
        bytes = base64Decode(raw);
      } catch (_) {
        bytes = null;
      }
    }
    return AppInfo(
      appName: map['appName'] as String,
      apkPath: map['apkPath'] as String,
      packageName: map['packageName'] as String,
      dataPath: map['dataPath'] as String,
      obbPath: map['obbPath'] as String,
      iconBytes: bytes,
    );
  }
}