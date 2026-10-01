import 'package:flutter/material.dart';

// ============================================================================
// 🎨 [STATE COLORS CONFIGURATION]
// You can customize the background, text, and button colors for the 2 app states below:
//
// 1. STANDBY STATE (when the timer is idle, completed, or not actively counting)
// 2. ACTIVE STATE  (when the chronometer is actively running or verifying)
// ============================================================================

/// Background color when timer is in STANDBY
const Color kTimerStandbyBackgroundColor = Color(0xFF1D1C1A);

/// Text color when timer is in STANDBY
const Color kTimerStandbyTextColor = Color(0xFFFAF8F6);

/// Background color when timer is ACTIVE
const Color kTimerActiveBackgroundColor = Color(0xFFFAF8F6);

/// Text color when timer is ACTIVE
const Color kTimerActiveTextColor = Color(0xFF1D1C1A);

/// Button colors on Timer screen
const Color kTimerStandbyButtonColor = Color(0xFFC4BDDD);
const Color kTimerStandbyButtonTextColor = Color(0xFF1D1C1A);

const Color kTimerActiveButtonColor = Color(0xFF1D1C1A);
const Color kTimerActiveButtonTextColor = Color(0xFFFAF8F6);

// Navigation bar colors for both states
const Color kNavStandbyBackgroundColor = Color(0xFF1D1C1A);
const Color kNavActiveBackgroundColor = Color(0xFFFAF8F6);

/// Unified theme palette based on Standby vs Active mode
class AppThemeColors {
  final bool isTimerActive;

  const AppThemeColors(this.isTimerActive);

  Color get background =>
      isTimerActive ? kTimerActiveBackgroundColor : kTimerStandbyBackgroundColor;

  Color get text =>
      isTimerActive ? kTimerActiveTextColor : kTimerStandbyTextColor;

  Color get textSecondary =>
      isTimerActive
          ? kTimerActiveTextColor.withValues(alpha: 0.65)
          : kTimerStandbyTextColor.withValues(alpha: 0.65);

  Color get textMuted =>
      isTimerActive
          ? kTimerActiveTextColor.withValues(alpha: 0.40)
          : kTimerStandbyTextColor.withValues(alpha: 0.40);

  Color get cardBackground =>
      isTimerActive ? const Color(0xFFEFECE8) : const Color(0xFF282724);

  Color get cardBorder =>
      isTimerActive ? const Color(0xFFE2DDD7) : const Color(0xFF383633);

  Color get divider => cardBorder;

  /// KTimerButton accent colors used across the entire app
  Color get accent =>
      isTimerActive ? kTimerActiveButtonColor : kTimerStandbyButtonColor;

  Color get accentText =>
      isTimerActive ? kTimerActiveButtonTextColor : kTimerStandbyButtonTextColor;

  Color get navBackground =>
      isTimerActive ? kNavActiveBackgroundColor : kNavStandbyBackgroundColor;
}
