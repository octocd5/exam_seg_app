import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/verifiable_objects.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
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
    final granted = await BlockerChannel.requestPermissions();
    if (mounted) {
      setState(() => _permissionsActive = granted);
    }
  }

  Future<void> _requestPermissions(AppStrings strings) async {
    final granted = await BlockerChannel.requestPermissions();
    if (!mounted) return;
    setState(() => _permissionsActive = granted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? strings.settingsPermissionsActiveSubtitle
              : strings.settingsPermissionsInactiveSubtitle,
          style: TextStyle(
            color: granted ? kTimerStandbyButtonTextColor : Colors.white,
          ),
        ),
        backgroundColor:
            granted ? kTimerStandbyButtonColor : const Color(0xFF383633),
      ),
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors colors,
    AppStrings strings,
    Locale? currentLocale,
  ) {
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
                    strings.settingsAppLanguage,
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
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.phone_android_rounded, color: colors.accent),
                title: Text(
                  strings.settingsLanguageSystem,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                trailing: currentLocale == null
                    ? Icon(Icons.check_circle_rounded, color: colors.accent)
                    : null,
                onTap: () {
                  ref.read(localeControllerProvider.notifier).setLocale(null);
                  Navigator.of(ctx).pop();
                },
              ),
              Divider(color: colors.cardBorder),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
                title: Text(
                  strings.settingsLanguageEnglish,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                trailing: currentLocale?.languageCode == 'en'
                    ? Icon(Icons.check_circle_rounded, color: colors.accent)
                    : null,
                onTap: () {
                  ref.read(localeControllerProvider.notifier).setLocale(const Locale('en'));
                  Navigator.of(ctx).pop();
                },
              ),
              Divider(color: colors.cardBorder),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Text('🇪🇸', style: TextStyle(fontSize: 22)),
                title: Text(
                  strings.settingsLanguageSpanish,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                trailing: currentLocale?.languageCode == 'es'
                    ? Icon(Icons.check_circle_rounded, color: colors.accent)
                    : null,
                onTap: () {
                  ref.read(localeControllerProvider.notifier).setLocale(const Locale('es'));
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showObjectsCatalog(AppThemeColors colors, AppStrings strings) {
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
                    strings.settingsCatalogTitle,
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
                strings.settingsCatalogDesc,
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
                      strings.translateObject(obj),
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
    final strings = ref.watch(appStringsProvider);
    final currentLocale = ref.watch(localeControllerProvider);

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
            // LANGUAGE SELECTION
            _buildSectionHeader(strings.settingsLanguageSection, colors),
            _buildSettingsCard(colors, [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.language_rounded, color: colors.accent),
                ),
                title: Text(
                  strings.settingsAppLanguage,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  currentLocale == null
                      ? strings.settingsLanguageSystem
                      : (currentLocale.languageCode == 'es'
                          ? strings.settingsLanguageSpanish
                          : strings.settingsLanguageEnglish),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                onTap: () => _showLanguageSelector(context, ref, colors, strings, currentLocale),
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader(strings.settingsLockSection, colors),
            _buildSettingsCard(colors, [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_permissionsActive == true
                            ? colors.accent
                            : colors.textSecondary)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _permissionsActive == true
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: _permissionsActive == true
                        ? colors.accent
                        : colors.textSecondary,
                  ),
                ),
                title: Text(
                  strings.settingsBlockerPermissions,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _permissionsActive == true
                      ? strings.settingsPermissionsActiveSubtitle
                      : strings.settingsPermissionsInactiveSubtitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () => _requestPermissions(strings),
                  child: Text(
                    _permissionsActive == true ? strings.settingsCheck : strings.settingsGrant,
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
                  strings.settingsDistractionOverlay,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  strings.settingsDistractionOverlaySubtitle,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                value: _strictLockMode,
                onChanged: (val) => setState(() => _strictLockMode = val),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(strings.settingsCameraSection, colors),
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
                  strings.settingsRecognizableObjects,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  strings.settingsItemsConfiguredSubtitle(targetObjects.length),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                onTap: () => _showObjectsCatalog(colors, strings),
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
                          strings.settingsConfidenceThreshold,
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
                      strings.settingsConfidenceSubtitle,
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
            _buildSectionHeader(strings.settingsSoundsSection, colors),
            _buildSettingsCard(colors, [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                activeThumbColor: colors.accent,
                activeTrackColor: colors.accent.withValues(alpha: 0.4),
                title: Text(
                  strings.settingsAudioCues,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  strings.settingsAudioCuesSubtitle,
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
                  strings.settingsHaptic,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  strings.settingsHapticSubtitle,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                value: _hapticEnabled,
                onChanged: (val) => setState(() => _hapticEnabled = val),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(strings.settingsAboutSection, colors),
            _buildSettingsCard(colors, [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.info_outline, color: colors.textSecondary),
                title: Text(
                  strings.settingsAboutTitle,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  strings.settingsAboutSubtitle,
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
