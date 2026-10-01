import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../activity/presentation/activity_screen.dart';
import '../../schedules/presentation/schedules_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../timer/controllers/timer_controller.dart';
import '../../timer/presentation/timer_screen.dart';

// ============================================================================
// 🎨 [STATE COLORS CONFIGURATION]
// Change the background colors for the 2 app states in:
// lib/core/constants/app_colors.dart
//
// 1. STANDBY STATE: kTimerStandbyBackgroundColor
// 2. ACTIVE STATE:  kTimerActiveBackgroundColor
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

    // 🎨 Switch background color based on the 2 states
    final Color currentBackgroundColor = isTimerActive
        ? kTimerActiveBackgroundColor
        : kTimerStandbyBackgroundColor;

    final Color currentNavColor = isTimerActive
        ? kNavActiveBackgroundColor
        : kNavStandbyBackgroundColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      color: currentBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: currentNavColor,
            border: Border(
              top: BorderSide(
                color: isTimerActive
                    ? const Color(0xFF0D5E48)
                    : const Color(0xFF334155),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF10B981),
            unselectedItemColor: const Color(0xFF94A3B8),
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                activeIcon: Icon(Icons.timer),
                label: 'Timer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'Schedules',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart_rounded),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
