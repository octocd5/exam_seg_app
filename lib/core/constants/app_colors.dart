import 'package:flutter/material.dart';

// ============================================================================
// 🎨 [STATE COLORS CONFIGURATION]
// You can customize the background colors for the 2 app states below:
//
// 1. STANDBY STATE (when the timer is idle, completed, or not actively counting)
// 2. ACTIVE STATE  (when the chronometer is actively running or verifying)
// ============================================================================

/// Background color when timer is in STANDBY
const Color kTimerStandbyBackgroundColor = Color(0xFF0F172A); // Default: Deep Slate

/// Background color when timer is ACTIVE
const Color kTimerActiveBackgroundColor = Color(0xFF042F24); // Default: Deep Focused Forest Green

// Navigation bar colors for both states
const Color kNavStandbyBackgroundColor = Color(0xFF1E293B);
const Color kNavActiveBackgroundColor = Color(0xFF063A2D);
