import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/app_info.dart';
import '../../core/models/scan_result.dart';

class ScanReportScreen extends StatelessWidget {
  final AppInfo app;
  final String sha256;
  final ScanResult? result;

  const ScanReportScreen({
    super.key,
    required this.app,
    required this.sha256,
    required this.result,
  });

  // Verdict helpers
  bool get _isDangerous => result != null && result!.malicious > 0;
  bool get _isSuspicious => result != null && result!.malicious == 0 && result!.suspicious > 0;
  bool get _isClean => result != null && result!.malicious == 0 && result!.suspicious == 0;

  Color get _verdictColor {
    if (_isDangerous) return Colors.red;
    if (_isSuspicious) return Colors.orange;
    if (_isClean) return Colors.greenAccent;
    return Colors.white38;
  }

  String get _verdictLabel {
    if (_isDangerous) return '⚠ DANGEROUS';
    if (_isSuspicious) return '⚠ SUSPICIOUS';
    if (_isClean) return '✓ CLEAN';
    return 'UNKNOWN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('SCAN REPORT', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // App header (icon + name)
            _buildAppHeader(),

            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),

            // App info
            _buildSection(
              'App Details',
              _buildAppInfoSection(),
            ),

            const SizedBox(height: 20),

            // Verdict banner
            if (result != null) _buildVerdictBanner(),
            const SizedBox(height: 20),

            // VirusTotal results
            _buildSection(
              'VirusTotal Analysis',
              _buildResultBox(context),
            ),

            const SizedBox(height: 20),

            if (result != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _openVirusTotal,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View Full Report on VirusTotal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _buildIcon(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.appName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                app.packageName,
                style: const TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    try {
      if (app.iconBase64.isNotEmpty) {
        return Image.memory(
          base64Decode(app.iconBase64),
          width: 60,
          height: 60,
          errorBuilder: (_, __, ___) => _placeholderIcon(),
        );
      }
    } catch (_) {}
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.android, color: Colors.white38, size: 36),
    );
  }

  Widget _buildVerdictBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _verdictColor.withOpacity(0.12),
        border: Border.all(color: _verdictColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          _verdictLabel,
          style: TextStyle(
            color: _verdictColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _boldLabel("APK Path:", app.apkPath),
          _boldLabel("SHA-256:", sha256, copyable: true),
        ],
      ),
    );
  }

  Widget _boldLabel(String title, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
              if (copyable)
                GestureDetector(
                  onTap: () => Clipboard.setData(ClipboardData(text: value)),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.copy, size: 14, color: Colors.white38),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox(BuildContext context) {
    if (result == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "This file was not found in the VirusTotal database.\nIt may be a new or private APK.",
          style: TextStyle(color: Colors.white54),
          textAlign: TextAlign.center,
        ),
      );
    }

    final total = result!.malicious + result!.suspicious + result!.harmless + result!.undetected;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _resultRow("Malicious", result!.malicious, result!.malicious > 0 ? Colors.redAccent : Colors.white60, total),
          _resultRow("Suspicious", result!.suspicious, result!.suspicious > 0 ? Colors.orange : Colors.white60, total),
          _resultRow("Harmless", result!.harmless, Colors.greenAccent, total),
          _resultRow("Undetected", result!.undetected, Colors.white38, total),
        ],
      ),
    );
  }

  Widget _resultRow(String label, int value, Color color, int total) {
    final frac = total > 0 ? value / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '$value',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVirusTotal() async {
    final url = Uri.parse("https://www.virustotal.com/gui/file/$sha256");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
