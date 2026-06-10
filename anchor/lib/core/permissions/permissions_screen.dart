import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design/anchor_theme.dart';
import '../services/usage_stats_service.dart';

/// Permission request screen shown before the app starts.
/// Requests all required Android permissions upfront.
class PermissionsScreen extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionsScreen({super.key, required this.onPermissionsGranted});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  bool _isLoading = false;
  bool _isWatchingUsageStats = false;

  final List<_PermissionItem> _permissions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  /// Called when app lifecycle changes.
  /// Used to detect when user returns from the Usage Access settings page.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWatchingUsageStats) {
      _checkUsageStatsAfterReturn();
    }
  }

  /// Check if usage stats permission was granted after returning from settings.
  Future<void> _checkUsageStatsAfterReturn() async {
    final usageStats = UsageStatsService();
    final granted = await usageStats.hasPermission();

    // Find the usage access permission item
    final usageItem = _permissions.firstWhere(
      (p) => p.title == 'Usage Access',
      orElse: () => _permissions.first,
    );

    if (usageItem.title == 'Usage Access') {
      setState(() {
        usageItem.status = granted
            ? PermissionStatus.granted
            : PermissionStatus.denied;
      });

      if (granted && _allGranted) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) _saveAndProceed();
      }
    }

    setState(() => _isWatchingUsageStats = false);
  }

  void _initPermissions() {
    _permissions.addAll([
      _PermissionItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        description: 'Daily brief alerts and task reminders',
        permissions: [Permission.notification],
      ),
      // On Android 13+ (API 33+), storage permission is split into
      // granular media permissions. We request both the legacy
      // Permission.storage (for older devices) and the modern media
      // permissions so the effective status is granted if ANY works.
      _PermissionItem(
        icon: Icons.storage_outlined,
        title: 'Storage',
        description: 'Save your journal, progress, and settings locally',
        permissions: [
          Permission.storage,
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ],
      ),
      _PermissionItem(
        icon: Icons.access_time_outlined,
        title: 'Usage Access',
        description: 'Track screen time across apps',
        // No permission_handler permissions — usage stats is special
        permissions: const [],
        isSpecial: true,
      ),
      _PermissionItem(
        icon: Icons.layers_outlined,
        title: 'Display Over Apps',
        description: 'Floating widget for screen mirror',
        permissions: [Permission.systemAlertWindow],
        isSpecial: true,
      ),
      _PermissionItem(
        icon: Icons.wifi_outlined,
        title: 'Internet',
        description: 'Sync with Todoist and Gemini AI',
        permissions: null,
        isNormal: true,
      ),
    ]);
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    for (final item in _permissions) {
      if (item.isNormal) {
        item.status = PermissionStatus.granted;
      } else if (item.title == 'Usage Access') {
        // Check usage stats via native platform channel
        final usageStats = UsageStatsService();
        final granted = await usageStats.hasPermission();
        item.status = granted
            ? PermissionStatus.granted
            : PermissionStatus.denied;
      } else if (item.permissions != null && item.permissions!.isNotEmpty) {
        // Check if ANY of the requested permissions is granted
        item.status = await item.effectiveStatus;
      }
    }
    if (mounted) setState(() {});

    // If all granted, skip
    if (_allGranted) {
      _saveAndProceed();
    }
  }

  bool get _allGranted => _permissions.every((p) => p.isGranted);

  Future<void> _requestAll() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    for (final item in _permissions) {
      if (item.isGranted || item.isNormal) continue;

      if (item.title == 'Usage Access') {
        await _requestUsageAccess(item);
      } else {
        item.status = await item.request();
      }
      if (mounted) setState(() {});
    }

    setState(() => _isLoading = false);

    if (_allGranted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _saveAndProceed();
    }
  }

  Future<void> _saveAndProceed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_granted', true);
    widget.onPermissionsGranted();
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  /// Request usage access permission by opening the system settings.
  /// This is the only way to grant PACKAGE_USAGE_STATS on Android.
  Future<void> _requestUsageAccess(_PermissionItem item) async {
    final usageStats = UsageStatsService();
    final alreadyGranted = await usageStats.hasPermission();

    if (alreadyGranted) {
      setState(() => item.status = PermissionStatus.granted);
      return;
    }

    // Open the Usage Access settings page
    setState(() => _isWatchingUsageStats = true);
    await usageStats.requestPermission();

    // Start polling to detect when user returns and grants permission
    _pollForUsageStatsGrant(item);
  }

  /// Poll for usage stats permission grant while the settings page is open.
  Future<void> _pollForUsageStatsGrant(_PermissionItem item) async {
    final usageStats = UsageStatsService();

    // Poll for up to 60 seconds
    for (var i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 1));
      final granted = await usageStats.hasPermission();

      if (granted && mounted) {
        setState(() {
          item.status = PermissionStatus.granted;
          _isWatchingUsageStats = false;
        });

        if (_allGranted) {
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) _saveAndProceed();
        }
        return;
      }

      if (!_isWatchingUsageStats) break; // User cancelled or returned
    }

    if (mounted) setState(() => _isWatchingUsageStats = false);
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _allGranted;
    final someDenied = _permissions.any((p) => p.isDenied);

    return Scaffold(
      backgroundColor: AnchorTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: allGranted
                              ? AnchorTheme.statusGreen
                              : AnchorTheme.statusOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (allGranted
                                      ? AnchorTheme.statusGreen
                                      : AnchorTheme.statusOrange)
                                  .withOpacity(
                                      0.3 * _pulseController.value),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    allGranted
                        ? 'ALL SYSTEMS READY'
                        : 'SYSTEM SETUP REQUIRED',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: allGranted ? AnchorTheme.statusGreen : AnchorTheme.statusOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Permission Control',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AnchorTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anchor needs the following permissions to function fully. All data stays on your device.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AnchorTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Permission list
              Expanded(
                child: ListView.builder(
                  itemCount: _permissions.length,
                  itemBuilder: (context, index) {
                    return _PermissionTile(
                      item: _permissions[index],
                      onRequest: () => _requestSingle(_permissions[index]),
                      isWatching: _permissions[index].title == 'Usage Access'
                          ? _isWatchingUsageStats
                          : false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              if (someDenied && !allGranted) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings, size: 16, color: AnchorTheme.textSecondary),
                    label: Text('OPEN SYSTEM SETTINGS', style: TextStyle(color: AnchorTheme.textSecondary)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        allGranted ? AnchorTheme.statusGreen : AnchorTheme.cardFloat,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AnchorTheme.background,
                            ),
                          ),
                        )
                      : Text(
                          allGranted ? 'ENTER ANCHOR' : 'GRANT ALL PERMISSIONS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: allGranted ? AnchorTheme.background : AnchorTheme.textPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Your data never leaves this device',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: AnchorTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestSingle(_PermissionItem item) async {
    HapticFeedback.lightImpact();
    if (item.isNormal) return;

    // Usage Access is special — use native platform channel
    if (item.title == 'Usage Access') {
      await _requestUsageAccess(item);
      return;
    }

    // Other special permissions (system alert window, etc.)
    if (item.isSpecial && item.isDenied) {
      await openAppSettings();
      return;
    }

    item.status = await item.request();
    if (mounted) setState(() {});

    if (_allGranted) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) _saveAndProceed();
    }
  }
}

class _PermissionItem {
  final IconData icon;
  final String title;
  final String description;

  /// The permission(s) to request. Multiple permissions are treated as
  /// alternatives — if ANY is granted the item is considered granted.
  final List<Permission>? permissions;
  final bool isSpecial;
  final bool isNormal;
  PermissionStatus status;

  _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    this.permissions,
    this.isSpecial = false,
    this.isNormal = false,
    this.status = PermissionStatus.denied,
  });

  bool get isGranted =>
      status == PermissionStatus.granted ||
      status == PermissionStatus.limited;
  bool get isDenied =>
      status == PermissionStatus.denied ||
      status == PermissionStatus.permanentlyDenied;

  /// Computes the effective status across all alternative permissions.
  /// Returns [PermissionStatus.granted] if any is granted/limited,
  /// otherwise returns the most "permissive" non-granted status.
  Future<PermissionStatus> get effectiveStatus async {
    if (permissions == null || permissions!.isEmpty) {
      return PermissionStatus.denied;
    }

    PermissionStatus? result;
    for (final perm in permissions!) {
      final s = await perm.status;
      if (s.isGranted || s.isLimited) {
        return PermissionStatus.granted;
      }
      // Prefer permanentlyDenied over denied
      if (s.isPermanentlyDenied) {
        result = s;
      } else if (result == null || !result.isPermanentlyDenied) {
        result = s;
      }
    }
    return result ?? PermissionStatus.denied;
  }

  /// Requests all alternative permissions and returns the best resulting status.
  Future<PermissionStatus> request() async {
    if (permissions == null || permissions!.isEmpty) {
      return PermissionStatus.denied;
    }

    PermissionStatus? result;
    for (final perm in permissions!) {
      final s = await perm.request();
      if (s.isGranted || s.isLimited) {
        return PermissionStatus.granted;
      }
      if (s.isPermanentlyDenied) {
        result = s;
      } else if (result == null || !result.isPermanentlyDenied) {
        result = s;
      }
    }
    return result ?? PermissionStatus.denied;
  }
}

class _PermissionTile extends StatelessWidget {
  final _PermissionItem item;
  final VoidCallback onRequest;
  final bool isWatching;

  const _PermissionTile({
    required this.item,
    required this.onRequest,
    this.isWatching = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (item.isGranted) {
      statusColor = AnchorTheme.statusGreen;
      statusText = 'GRANTED';
      statusIcon = Icons.check;
    } else if (isWatching) {
      statusColor = AnchorTheme.statusOrange;
      statusText = 'WAITING';
      statusIcon = Icons.hourglass_top;
    } else if (item.isDenied && item.isSpecial) {
      statusColor = AnchorTheme.statusOrange;
      statusText = 'MANUAL';
      statusIcon = Icons.open_in_new;
    } else if (item.isDenied) {
      statusColor = AnchorTheme.statusRed;
      statusText = 'DENIED';
      statusIcon = Icons.close;
    } else {
      statusColor = AnchorTheme.textMuted;
      statusText = 'PENDING';
      statusIcon = Icons.circle_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isGranted
              ? AnchorTheme.cardBorder
              : statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(item.icon, size: 18, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AnchorTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 10, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AnchorTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!item.isGranted)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRequest,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AnchorTheme.cardInset,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isWatching
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AnchorTheme.accent),
                          ),
                        )
                      : Text(
                          item.isSpecial ? 'OPEN' : 'ALLOW',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AnchorTheme.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
