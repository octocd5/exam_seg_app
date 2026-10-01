import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/verifiable_objects.dart';
import '../../../core/native_bridge/blocker_channel.dart';
import '../../timer/controllers/timer_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _strictLockMode = true;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  double _confidenceThreshold = 0.65;
  bool? _permissionsActive;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Quick test / check
    final granted = await BlockerChannel.requestPermissions();
    if (mounted) {
      setState(() => _permissionsActive = granted);
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await BlockerChannel.requestPermissions();
    if (!mounted) return;
    setState(() => _permissionsActive = granted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Lock permissions granted and active!'
              : 'Permission not granted. Please allow in Android system settings.',
          style: TextStyle(
            color: granted ? kTimerStandbyButtonTextColor : Colors.white,
          ),
        ),
        backgroundColor: granted ? kTimerStandbyButtonColor : Colors.orange[800],
      ),
    );
  }

  void _showObjectsCatalog(AppThemeColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verifiable Target Objects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'When you want to stop a session, Focus Guard randomly assigns one of these real-world items for you to photograph:',
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: targetObjects.map((obj) {
                  return Chip(
                    backgroundColor: colors.background,
                    side: BorderSide(color: colors.cardBorder),
                    avatar: Icon(Icons.check_circle, size: 16, color: colors.accent),
                    label: Text(
                      obj,
                      style: TextStyle(color: colors.text, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final isTimerActive = timerState.status == TimerStatus.running;
    final colors = AppThemeColors(isTimerActive);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            _buildSectionHeader('LOCK & ANTI-CHEATING', colors),
            _buildSettingsCard(colors, [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_permissionsActive == true
                            ? colors.accent
                            : Colors.orange)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _permissionsActive == true
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: _permissionsActive == true
                        ? colors.accent
                        : Colors.orange,
                  ),
                ),
                title: Text(
                  'Lock Screen Permissions',
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _permissionsActive == true
                      ? 'System overlay & lock permissions active'
                      : 'Permissions required for full lockdown',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _requestPermissions,
                  child: Text(
                    _permissionsActive == true ? 'Check' : 'Grant',
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Divider(color: colors.cardBorder, height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: colors.accent,
                activeTrackColor: colors.accent.withValues(alpha: 0.4),
                title: Text(
                  'Strict Lock Mode',
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Block home button and app switcher during active sessions',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                value: _strictLockMode,
                onChanged: (val) => setState(() => _strictLockMode = val),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('CAMERA & VISION VERIFICATION', colors),
            _buildSettingsCard(colors, [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.qr_code_scanner, color: colors.accent),
                ),
                title: Text(
                  'Recognizable Objects',
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${targetObjects.length} everyday items configured for photo unlock',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                onTap: () => _showObjectsCatalog(colors),
              ),
              Divider(color: colors.cardBorder, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AI Confidence Threshold',
                          style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(_confidenceThreshold * 100).toInt()}%',
                          style: TextStyle(
                            color: colors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Higher values require clearer, closer photos of the target object',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    Slider(
                      value: _confidenceThreshold,
                      min: 0.5,
                      max: 0.9,
                      divisions: 8,
                      activeColor: colors.accent,
                      inactiveColor: colors.cardBorder,
                      onChanged: (val) => setState(() => _confidenceThreshold = val),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('SOUNDS & FEEDBACK', colors),
            _buildSettingsCard(colors, [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: colors.accent,
                activeTrackColor: colors.accent.withValues(alpha: 0.4),
                title: Text(
                  'Audio Cues',
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Play chime on session start and unlock',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                value: _soundEnabled,
                onChanged: (val) => setState(() => _soundEnabled = val),
              ),
              Divider(color: colors.cardBorder, height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: colors.accent,
                activeTrackColor: colors.accent.withValues(alpha: 0.4),
                title: Text(
                  'Haptic Vibration',
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Vibrate on camera object detection confirmation',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                value: _hapticEnabled,
                onChanged: (val) => setState(() => _hapticEnabled = val),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('ABOUT', colors),
            _buildSettingsCard(colors, [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.info_outline, color: colors.textSecondary),
                title: Text(
                  'Focus Guard App',
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Version 1.0.0 • On-Device ML Kit Vision',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(AppThemeColors colors, List<Widget> children) {
    return Material(
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
