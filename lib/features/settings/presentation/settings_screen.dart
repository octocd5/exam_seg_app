import 'package:flutter/material.dart';
import '../../../core/constants/verifiable_objects.dart';
import '../../../core/native_bridge/blocker_channel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _strictLockMode = true;
  bool _strikeOnBackground = true;
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
        ),
        backgroundColor: granted ? const Color(0xFF10B981) : Colors.orange[800],
      ),
    );
  }

  void _showObjectsCatalog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
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
                  const Text(
                    'Verifiable Target Objects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'When you want to stop a session, Focus Guard randomly assigns one of these real-world items for you to photograph:',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: targetObjects.map((obj) {
                  return Chip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF334155)),
                    avatar: const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                    label: Text(
                      obj,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            _buildSectionHeader('LOCK & ANTI-CHEATING'),
            _buildSettingsCard([
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_permissionsActive == true
                            ? const Color(0xFF10B981)
                            : Colors.orange)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _permissionsActive == true
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: _permissionsActive == true
                        ? const Color(0xFF10B981)
                        : Colors.orange,
                  ),
                ),
                title: const Text(
                  'Lock Screen Permissions',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _permissionsActive == true
                      ? 'System overlay & lock permissions active'
                      : 'Permissions required for full lockdown',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _requestPermissions,
                  child: Text(
                    _permissionsActive == true ? 'Check' : 'Grant',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(color: Color(0xFF334155), height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: const Color(0xFF10B981),
                title: const Text(
                  'Strict Lock Mode',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Block home button and app switcher during active sessions',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                value: _strictLockMode,
                onChanged: (val) => setState(() => _strictLockMode = val),
              ),
              const Divider(color: Color(0xFF334155), height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: const Color(0xFF10B981),
                title: const Text(
                  'Background Strike Penalty',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Record a strike warning whenever the app is exited or backgrounded',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                value: _strikeOnBackground,
                onChanged: (val) => setState(() => _strikeOnBackground = val),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('CAMERA & VISION VERIFICATION'),
            _buildSettingsCard([
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Color(0xFF6366F1)),
                ),
                title: const Text(
                  'Recognizable Objects',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${targetObjects.length} everyday items configured for photo unlock',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: _showObjectsCatalog,
              ),
              const Divider(color: Color(0xFF334155), height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI Confidence Threshold',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(_confidenceThreshold * 100).toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Higher values require clearer, closer photos of the target object',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    Slider(
                      value: _confidenceThreshold,
                      min: 0.5,
                      max: 0.9,
                      divisions: 8,
                      activeColor: const Color(0xFF10B981),
                      inactiveColor: const Color(0xFF334155),
                      onChanged: (val) => setState(() => _confidenceThreshold = val),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('SOUNDS & FEEDBACK'),
            _buildSettingsCard([
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: const Color(0xFF10B981),
                title: const Text(
                  'Audio Cues',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Play chime on session start, strike warning, and unlock',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                value: _soundEnabled,
                onChanged: (val) => setState(() => _soundEnabled = val),
              ),
              const Divider(color: Color(0xFF334155), height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: const Color(0xFF10B981),
                title: const Text(
                  'Haptic Vibration',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Vibrate on camera object detection confirmation',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                value: _hapticEnabled,
                onChanged: (val) => setState(() => _hapticEnabled = val),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('ABOUT'),
            _buildSettingsCard([
              const ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.info_outline, color: Colors.white60),
                title: Text(
                  'Focus Guard App',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Version 1.0.0 • On-Device ML Kit Vision',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Material(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
