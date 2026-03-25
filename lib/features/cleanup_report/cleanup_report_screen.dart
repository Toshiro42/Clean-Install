import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/app_info.dart';

class CleanupReportScreen extends StatelessWidget {
  final AppInfo app;

  const CleanupReportScreen({
    super.key,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('CLEANUP REPORT', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                  SizedBox(height: 8),
                  Text(
                    'Successfully Uninstalled',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The app has been removed from your device.\nData paths are listed below for reference.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App name
            Center(
              child: Text(
                app.appName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),

            const Text(
              'Associated File Paths',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),

            const SizedBox(height: 12),
            _buildReportBox(),

            const SizedBox(height: 20),

            const Text(
              'Note: OBB and data paths may need to be removed manually using a file manager.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pathRow("APK Path", app.apkPath),
          const Divider(color: Colors.white12, height: 24),
          _pathRow("Data Path", app.dataPath),
          const Divider(color: Colors.white12, height: 24),
          _pathRow(
            "OBB Path",
            app.obbPath.isNotEmpty ? app.obbPath : "Not found or not used by this app.",
          ),
        ],
      ),
    );
  }

  Widget _pathRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(text: value)),
              child: const Row(
                children: [
                  Icon(Icons.copy, size: 13, color: Colors.white38),
                  SizedBox(width: 4),
                  Text('Copy', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}