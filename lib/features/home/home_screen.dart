import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/models/app_info.dart';
import '../../core/services/native_app_service.dart';
import '../../core/services/virus_total_service.dart';
import 'app_tile.dart';
import '../scan_report/scan_report_screen.dart';
import '../cleanup_report/cleanup_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  AppInfo? _pendingUninstallApp;
  bool _wentInactive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadApps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_pendingUninstallApp == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _wentInactive = true;
    }

    if (state == AppLifecycleState.resumed && _wentInactive) {
      _wentInactive = false;
      _checkUninstallResult(_pendingUninstallApp!);
    }
  }

  Future<void> _checkUninstallResult(AppInfo app) async {
    _pendingUninstallApp = null;

    final bool stillInstalled =
    await NativeAppService.isPackageInstalled(app.packageName);

    if (!mounted) return;

    if (!stillInstalled) {
      setState(() {
        _allApps.removeWhere((a) => a.packageName == app.packageName);
        _filteredApps.removeWhere((a) => a.packageName == app.packageName);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CleanupReportScreen(app: app),
        ),
      );
    }
  }

  Future<void> loadApps() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final installed = await NativeAppService.getInstalledApps();
      setState(() {
        _allApps = installed;
        _filteredApps = installed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load apps: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredApps = _allApps.where((app) {
        return app.appName.toLowerCase().contains(_searchQuery) ||
            app.packageName.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('virustotal.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.orangeAccent, size: 22),
            SizedBox(width: 10),
            Text(
              'No Internet',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'You\'re offline. Please connect to the internet to scan apps with VirusTotal.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onScan(AppInfo app) async {
    final online = await _isOnline();
    if (!mounted) return;

    if (!online) {
      _showNoInternetDialog();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Scanning ${app.appName}...',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );

    try {
      final sha = await NativeAppService.getSha256(app.apkPath);
      final result = await VirusTotalService.scanFile(sha);

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanReportScreen(
            app: app,
            sha256: sha,
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _onUninstall(AppInfo app) async {
    await NativeAppService.uninstallApp(app.packageName);
    _pendingUninstallApp = app;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clean Install',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading installed apps...',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(_error,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loadApps, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: Colors.white38, size: 48),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No apps match "$_searchQuery"'
                  : 'No apps found',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadApps,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                '${_filteredApps.length} app${_filteredApps.length == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 72,
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final app = _filteredApps[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: AppTile(
                    app: app,
                    onScan: () => _onScan(app),
                    onUninstall: () => _onUninstall(app),
                  ),
                );
              },
              childCount: _filteredApps.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}