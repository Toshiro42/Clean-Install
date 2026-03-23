import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/app_info.dart';

class NativeAppService {
  static const MethodChannel _channel =
  MethodChannel('clean_install/native');

  static Future<List<AppInfo>> getInstalledApps() async {
    final List result =
    await _channel.invokeMethod("getInstalledApps");

    return result.map((e) => AppInfo.fromMap(e)).toList();
  }

  static Future<String> getSha256(String apkPath) async {
    return await _channel.invokeMethod(
      "getSha256",
      {"apkPath": apkPath},
    );
  }

  static Future<void> uninstallApp(String packageName) async {
    await _channel.invokeMethod(
      "uninstallApp",
      {"packageName": packageName},
    );
  }
}
