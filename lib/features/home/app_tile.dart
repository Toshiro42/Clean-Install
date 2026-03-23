import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/models/app_info.dart';

class AppTile extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onScan;
  final VoidCallback onUninstall;

  const AppTile({
    super.key,
    required this.app,
    required this.onScan,
    required this.onUninstall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // App Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildIcon(),
            ),
            const SizedBox(width: 12),

            // App name + package
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),

            // Scan button
            Tooltip(
              message: 'Scan with VirusTotal',
              child: IconButton(
                icon: const Icon(Icons.security_outlined, color: Colors.blueAccent),
                onPressed: onScan,
              ),
            ),

            // Uninstall button
            Tooltip(
              message: 'Uninstall app',
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmUninstall(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    try {
      if (app.iconBase64.isNotEmpty) {
        return Image.memory(
          base64Decode(app.iconBase64),
          width: 48,
          height: 48,
          errorBuilder: (_, __, ___) => _placeholderIcon(),
        );
      }
    } catch (_) {}
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.android, color: Colors.white38, size: 28),
    );
  }

  void _confirmUninstall(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Uninstall App', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to uninstall "${app.appName}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onUninstall();
            },
            child: const Text('Uninstall', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
