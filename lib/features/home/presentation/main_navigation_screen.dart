import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../activity/presentation/activity_screen.dart';
import '../../schedules/presentation/schedules_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../timer/controllers/timer_controller.dart';
import '../../timer/presentation/timer_screen.dart';

// ============================================================================
// 🎨 [STATE COLORS CONFIGURATION]
// Change the background, text, and button colors for the 2 app states in:
// lib/core/constants/app_colors.dart
//
// 1. STANDBY STATE: kTimerStandbyBackgroundColor / kTimerStandbyTextColor
// 2. ACTIVE STATE:  kTimerActiveBackgroundColor / kTimerActiveTextColor
// ============================================================================

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TimerScreen(),
    SchedulesScreen(),
    ActivityScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final isTimerActive = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.verifying;
    final colors = AppThemeColors(isTimerActive);

    final strings = ref.watch(appStringsProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      color: colors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: colors.navBackground,
            border: Border(
              top: BorderSide(
                color: colors.cardBorder,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: colors.accent,
            unselectedItemColor: colors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.3,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.timer_outlined),
                activeIcon: const Icon(Icons.timer),
                label: strings.navTimer,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_month_outlined),
                activeIcon: const Icon(Icons.calendar_month),
                label: strings.navSchedules,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart_rounded),
                label: strings.navActivity,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: strings.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
