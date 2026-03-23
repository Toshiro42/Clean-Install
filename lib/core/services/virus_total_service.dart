import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/scan_result.dart';

class VirusTotalService {
  static Future<ScanResult?> scanFile(String sha256) async {
    try {
      final apiKey = dotenv.env['VIRUSTOTAL_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('VirusTotal API key is missing from .env');
      }

      final response = await http
          .get(
            Uri.parse("https://www.virustotal.com/api/v3/files/$sha256"),
            headers: {"x-apikey": apiKey},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body);
      final stats = json["data"]?["attributes"]?["last_analysis_stats"];

      if (stats == null) return null;

      return ScanResult(
        malicious: stats["malicious"] ?? 0,
        suspicious: stats["suspicious"] ?? 0,
        harmless: stats["harmless"] ?? 0,
        undetected: stats["undetected"] ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}
