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
    return RepaintBoundary(
      // Material handles rounded corners via hardware acceleration —
      // unlike Container+BoxDecoration which forces an expensive saveLayer.
      child: Material(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
              IconButton(
                icon: const Icon(Icons.security_outlined, color: Colors.blueAccent),
                onPressed: onScan,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onUninstall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final bytes = app.iconBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        // Clip.hardEdge skips anti-aliasing on the clip itself —
        // at 48px icon size the difference is invisible but it's
        // significantly cheaper than the default Clip.antiAlias.
        clipBehavior: Clip.hardEdge,
        child: Image.memory(
          bytes,
          width: 48,
          height: 48,
          cacheWidth: 96,
          cacheHeight: 96,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _placeholderIcon(),
        ),
      );
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.android, color: Colors.white38, size: 28),
    );
  }
}