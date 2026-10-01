import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/native_bridge/blocker_channel.dart';
import '../../activity/controllers/activity_controller.dart';
import '../../activity/models/activity_session.dart';
import '../../verification/presentation/camera_verification_screen.dart';
import '../controllers/timer_controller.dart';

// ============================================================================
// 🎨 [STATE BACKGROUND COLORS CONFIGURATION]
// Change the background colors for the 2 app states in:
// 👉 lib/core/constants/app_colors.dart
//
// 1. STANDBY STATE: kTimerStandbyBackgroundColor
// 2. ACTIVE STATE:  kTimerActiveBackgroundColor
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
      ref.read(timerControllerProvider.notifier).onAppInterrupted();
      _lottieController.stop();
    } else if (state == AppLifecycleState.resumed) {
      final currentStatus = ref.read(timerControllerProvider).status;
      final isActive = currentStatus == TimerStatus.running ||
          currentStatus == TimerStatus.verifying;
      if (!isActive && _lottieController.duration != null) {
        _lottieController.repeat();
      }
    }
  }

  Future<void> _handleStopRequest() async {
    final chosenObject =
        ref.read(timerControllerProvider.notifier).requestStop();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraVerificationScreen(
          targetObject: chosenObject,
        ),
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
        ),
        backgroundColor: granted ? Colors.teal : Colors.orange[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for timer status changes to control Lottie animation playback
    ref.listen<TimerState>(timerControllerProvider, (previous, next) {
      final wasActive = previous != null &&
          (previous.status == TimerStatus.running ||
              previous.status == TimerStatus.verifying);
      final isActive = next.status == TimerStatus.running ||
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
    final isTimerActive = timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.verifying;

    // 🎨 Switch background color based on the 2 states:
    final Color currentBackgroundColor = isTimerActive
        ? kTimerActiveBackgroundColor
        : kTimerStandbyBackgroundColor;

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
          actions: [
            IconButton(
              tooltip: 'Request Lock Permissions',
              icon: const Icon(Icons.shield_outlined),
              onPressed: _requestBlockerPermissions,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                _buildStatusBadge(timerState),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildMiddleSection(timerState),
                ),
                const SizedBox(height: 12),
                if (timerState.penaltyMessage != null) ...[
                  _buildInterruptionAlert(timerState),
                  const SizedBox(height: 16),
                ],
                if (timerState.status == TimerStatus.completed) ...[
                  _buildSessionSummaryCard(timerState),
                  const SizedBox(height: 20),
                ],
                _buildActionButtons(timerState),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TimerState state) {
    String label;
    Color color;
    IconData icon;

    switch (state.status) {
      case TimerStatus.idle:
        label = 'Chronometer Ready';
        color = Colors.blueGrey;
        icon = Icons.timer_outlined;
        break;
      case TimerStatus.running:
        label = 'Tracking Active • Phone Locked';
        color = const Color(0xFF10B981);
        icon = Icons.lock_clock;
        break;
      case TimerStatus.verifying:
        label = 'Photo Verification Required';
        color = const Color(0xFFF59E0B);
        icon = Icons.camera_alt_outlined;
        break;
      case TimerStatus.completed:
        label = 'Session Finished';
        color = const Color(0xFF6366F1);
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleSection(TimerState state) {
    final Color accentColor = switch (state.status) {
      TimerStatus.running => const Color(0xFF10B981),
      TimerStatus.verifying => const Color(0xFFF59E0B),
      TimerStatus.completed => const Color(0xFF6366F1),
      TimerStatus.idle => const Color(0xFF818CF8),
    };

    final bool isTimerActive = state.status == TimerStatus.running ||
        state.status == TimerStatus.verifying;

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
    final int todaySessionsCount = todayGroup.sessions.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lottie Burbuja character with atmospheric glow
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxSize = constraints.maxHeight.clamp(140.0, 260.0);
              return Center(
                child: SizedBox(
                  width: maxSize,
                  height: maxSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: maxSize,
                        height: maxSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              (isTimerActive
                                      ? accentColor
                                      : const Color(0xFF8B5CF6))
                                  .withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                            stops: const [0.35, 1.0],
                          ),
                        ),
                      ),
                      Lottie.asset(
                        'assets/animations/Burbuja.json',
                        controller: _lottieController,
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          _lottieController.duration = composition.duration;
                          final currentStatus =
                              ref.read(timerControllerProvider).status;
                          final isActive =
                              currentStatus == TimerStatus.running ||
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ⏱️ TIMER DISPLAY LOGIC:
        // - When ACTIVE: The actual counting chronometer is visible.
        // - When STANDBY: The actual timer is hidden. Instead, a bubble shows the time
        //   called from the activity screen that the user has used the timer for in the day.
        if (isTimerActive) ...[
          Text(
            state.formattedElapsed,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
              ),
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
        ] else ...[
          // Standby Bubble: calls time from the activity screen used today
          _buildStandbyActivityBubble(todayTime, todaySessionsCount),
        ],
      ],
    );
  }

  Widget _buildStandbyActivityBubble(String todayTime, int sessionCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Little arrow/pointer pointing up to Burbuja
        CustomPaint(
          size: const Size(16, 8),
          painter: _BubbleTailPainter(
            color: const Color(0xFF1E293B).withValues(alpha: 0.95),
            borderColor: const Color(0xFF10B981).withValues(alpha: 0.4),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
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
                    color: Color(0xFF10B981),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "TODAY'S FOCUS TIME",
                    style: TextStyle(
                      color: Color(0xFF34D399),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sessionCount == 0
                    ? '0 sessions logged today'
                    : '$sessionCount session${sessionCount == 1 ? '' : 's'} logged today',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterruptionAlert(TimerState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.penaltyMessage ?? '',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummaryCard(TimerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 8),
              Text(
                'Focus Session Completed!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Time Logged',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.summaryFormatted,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 30, color: const Color(0xFF334155)),
              Column(
                children: [
                  Text(
                    'Discipline Strikes',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.interruptionCount}',
                    style: TextStyle(
                      color: state.interruptionCount == 0
                          ? const Color(0xFF10B981)
                          : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TimerState state) {
    final notifier = ref.read(timerControllerProvider.notifier);

    if (state.status == TimerStatus.idle) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
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

    if (state.status == TimerStatus.running) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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

    if (state.status == TimerStatus.verifying) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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

    // Completed state
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => notifier.reset(),
        icon: const Icon(Icons.refresh),
        label: const Text(
          'Start New Session',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _BubbleTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height), Offset(size.width / 2, 0), borderPaint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
