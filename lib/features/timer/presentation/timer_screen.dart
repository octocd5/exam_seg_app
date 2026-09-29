import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/native_bridge/blocker_channel.dart';
import '../../verification/presentation/camera_verification_screen.dart';
import '../controllers/timer_controller.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(timerControllerProvider.notifier).onAppInterrupted();
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
    final timerState = ref.watch(timerControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Focus Chronometer',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF0F172A),
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
              const Spacer(),
              _buildChronometerDial(timerState),
              const Spacer(),
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

  Widget _buildChronometerDial(TimerState state) {
    // Second dial progress (cycles 0.0 -> 1.0 each minute)
    final double secondProgress = state.status == TimerStatus.running
        ? ((state.elapsedSeconds % 60) + 1) / 60.0
        : (state.status == TimerStatus.completed ? 1.0 : 0.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: CircularProgressIndicator(
            value: secondProgress,
            strokeWidth: 10,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: AlwaysStoppedAnimation<Color>(
              state.status == TimerStatus.running
                  ? const Color(0xFF10B981)
                  : (state.status == TimerStatus.completed
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF334155)),
            ),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.formattedElapsed,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.status == TimerStatus.running
                  ? 'TRACKING TIME'
                  : (state.status == TimerStatus.completed
                      ? 'COMPLETED'
                      : 'STANDBY'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: state.status == TimerStatus.running
                    ? const Color(0xFF10B981)
                    : Colors.white.withValues(alpha: 0.5),
                letterSpacing: 1.5,
              ),
            ),
          ],
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummaryCard(TimerState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Total Time',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                state.summaryFormatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            height: 36,
            width: 1,
            color: Colors.white24,
          ),
          Column(
            children: [
              const Text('Strikes / Exits',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '${state.interruptionCount}',
                style: TextStyle(
                  color: state.interruptionCount == 0
                      ? const Color(0xFF10B981)
                      : Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
      return Column(
        children: [
          SizedBox(
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
          ),
          const SizedBox(height: 8),
          Text(
            'The only way to stop is by photographing a random object',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (state.status == TimerStatus.running) {
      return Column(
        children: [
          SizedBox(
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
          ),
          const SizedBox(height: 8),
          Text(
            'App will assign a random item to photograph',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
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
