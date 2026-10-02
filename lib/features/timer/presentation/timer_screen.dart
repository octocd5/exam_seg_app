import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/native_bridge/blocker_channel.dart';
import '../../activity/controllers/activity_controller.dart';
import '../../activity/models/activity_session.dart';
import '../../lists/presentation/widgets/active_list_card.dart';
import '../../verification/presentation/camera_verification_screen.dart';
import '../controllers/timer_controller.dart';

// ============================================================================
// 🎨 [STATE COLORS CONFIGURATION]
// Change the background, text, and button colors for the 2 app states in:
// 👉 lib/core/constants/app_colors.dart
//
// 1. STANDBY STATE:
//    - Background: kTimerStandbyBackgroundColor
//    - Text:       kTimerStandbyTextColor
//    - Button:     kTimerStandbyButtonColor (text: kTimerStandbyButtonTextColor)
//
// 2. ACTIVE STATE:
//    - Background: kTimerActiveBackgroundColor
//    - Text:       kTimerActiveTextColor
//    - Button:     kTimerActiveButtonColor (text: kTimerActiveButtonTextColor)
// ============================================================================

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lottieController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _lottieController.stop();
    } else if (state == AppLifecycleState.resumed) {
      final currentStatus = ref.read(timerControllerProvider).status;
      final isActive =
          currentStatus == TimerStatus.running ||
          currentStatus == TimerStatus.verifying;
      if (!isActive && _lottieController.duration != null) {
        _lottieController.repeat();
      }
    }
  }

  Future<void> _handleStopRequest() async {
    final chosenObject = ref
        .read(timerControllerProvider.notifier)
        .requestStop();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CameraVerificationScreen(targetObject: chosenObject),
      ),
    );

    // If popped back and still verifying, revert status to running
    final currentStatus = ref.read(timerControllerProvider).status;
    if (currentStatus == TimerStatus.verifying) {
      ref.read(timerControllerProvider.notifier).cancelVerification();
    }
  }

  Future<void> _requestBlockerPermissions() async {
    final granted = await BlockerChannel.requestPermissions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Lock / overlay permissions active!'
              : 'Permission not granted or not supported on this device.',
          style: TextStyle(
            color: granted ? kTimerStandbyButtonTextColor : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: granted
            ? kTimerStandbyButtonColor
            : Colors.orange[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for timer status changes to control Lottie animation playback
    ref.listen<TimerState>(timerControllerProvider, (previous, next) {
      final wasActive =
          previous != null &&
          (previous.status == TimerStatus.running ||
              previous.status == TimerStatus.verifying);
      final isActive =
          next.status == TimerStatus.running ||
          next.status == TimerStatus.verifying;

      if (isActive && !wasActive) {
        _lottieController.stop();
      } else if (!isActive && wasActive) {
        if (_lottieController.duration != null) {
          _lottieController.repeat();
        }
      }
    });

    final timerState = ref.watch(timerControllerProvider);
    final isTimerActive =
        timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.verifying;
    final colors = AppThemeColors(isTimerActive);

    final Color currentBackgroundColor = colors.background;
    final Color currentTextColor = colors.text;

    final Color accentColor = switch (timerState.status) {
      TimerStatus.running => colors.accent,
      TimerStatus.verifying => const Color(0xFFF59E0B),
      _ => colors.accent,
    };

    // Retrieve today's total focus time from the activity controller
    final activityState = ref.watch(activityControllerProvider);
    final dailyGroups = groupSessionsByDay(sessions: activityState.sessions);
    final todayGroup = dailyGroups.firstWhere(
      (g) => g.isToday,
      orElse: () => DailyActivityGroup(
        date: DateTime.now(),
        sessions: const [],
        totalSeconds: 0,
        totalStrikes: 0,
      ),
    );
    final String todayTime = todayGroup.formattedTotalDuration;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      color: currentBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // Screen title removed as requested
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: currentTextColor),
          actions: [
            IconButton(
              tooltip: 'Request Lock Permissions',
              icon: const Icon(Icons.shield_outlined),
              color: currentTextColor,
              onPressed: _requestBlockerPermissions,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                _buildTopSection(
                  timerState,
                  accentColor,
                  todayTime,
                  currentTextColor,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxAllowed = math.min(
                        constraints.maxWidth * 0.90,
                        constraints.maxHeight - 76,
                      );
                      final double size =
                          maxAllowed.isFinite && maxAllowed >= 100.0
                              ? maxAllowed.clamp(100.0, 260.0)
                              : 180.0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildMiddleSection(
                            timerState,
                            accentColor,
                            isTimerActive,
                            size,
                          ),
                          const SizedBox(height: 4),
                          ActiveListCard(isTimerActive: isTimerActive),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionButtons(timerState),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(
    TimerState state,
    Color accentColor,
    String todayTime,
    Color textColor,
  ) {
    final bool isTimerActive =
        state.status == TimerStatus.running ||
        state.status == TimerStatus.verifying;

    if (isTimerActive) {
      // ⏱️ Active Chronometer display at the top of the screen
      return _buildActiveTimerDisplay(state, accentColor, textColor);
    } else {
      // ⏱️ Standby State: Total time display at the top of the screen
      return _buildStandbyActivityBubble(todayTime, textColor);
    }
  }

  Widget _buildActiveTimerDisplay(
    TimerState state,
    Color accentColor,
    Color textColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          state.formattedElapsed,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.status == TimerStatus.running
                    ? 'TRACKING TIME'
                    : 'VERIFICATION PENDING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiddleSection(
    TimerState state,
    Color accentColor,
    bool isTimerActive,
    double size,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isTimerActive ? accentColor : const Color(0xFF8B5CF6))
                      .withValues(alpha: 0.18),
                  Colors.transparent,
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
          Lottie.asset(
            'assets/animations/BubbleIdle.json',
            controller: _lottieController,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _lottieController.duration = composition.duration;
              final currentStatus = ref.read(timerControllerProvider).status;
              final isActive = currentStatus == TimerStatus.running ||
                  currentStatus == TimerStatus.verifying;
              if (!isActive) {
                _lottieController.repeat();
              } else {
                _lottieController.stop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStandbyActivityBubble(String todayTime, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF282724),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: kTimerStandbyButtonColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: kTimerStandbyButtonColor.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: kTimerStandbyButtonColor,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "TODAY'S FOCUS TIME",
                    style: TextStyle(
                      color: kTimerStandbyButtonColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                todayTime,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        // Little arrow/pointer pointing down to Burbuja
        CustomPaint(
          size: const Size(16, 8),
          painter: _BubbleTailDownPainter(
            color: const Color(0xFF282724),
            borderColor: kTimerStandbyButtonColor.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TimerState state) {
    final notifier = ref.read(timerControllerProvider.notifier);

    // Active Mode: Running
    if (state.status == TimerStatus.running) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kTimerActiveButtonColor,
            foregroundColor: kTimerActiveButtonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          onPressed: _handleStopRequest,
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text(
            'Stop (Scan Object to Unlock)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Active Mode: Verifying
    if (state.status == TimerStatus.verifying) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kTimerActiveButtonColor,
            foregroundColor: kTimerActiveButtonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          onPressed: () {
            if (state.targetObject != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CameraVerificationScreen(
                    targetObject: state.targetObject!,
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.camera_alt),
          label: Text(
            'Photograph "${state.targetObject}"',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Standby Mode (first boot and returned standby)
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: kTimerStandbyButtonColor,
          foregroundColor: kTimerStandbyButtonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: () => notifier.startTimer(),
        icon: const Icon(Icons.play_arrow_rounded, size: 26),
        label: const Text(
          'Start Chronometer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BubbleTailDownPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _BubbleTailDownPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset.zero,
      Offset(size.width / 2, size.height),
      borderPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width, 0),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
