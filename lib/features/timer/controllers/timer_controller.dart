import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/verifiable_objects.dart';
import '../../../core/native_bridge/blocker_channel.dart';
import '../../activity/controllers/activity_controller.dart';

enum TimerStatus {
  idle,
  running,
  verifying,
  completed,
}

class TimerState {
  final TimerStatus status;
  final int elapsedSeconds;
  final DateTime? startTime;
  final String? targetObject;
  final int interruptionCount;
  final String? penaltyMessage;

  const TimerState({
    this.status = TimerStatus.idle,
    this.elapsedSeconds = 0,
    this.startTime,
    this.targetObject,
    this.interruptionCount = 0,
    this.penaltyMessage,
  });

  String get formattedElapsed {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get summaryFormatted {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || hours > 0) parts.add('${minutes}m');
    parts.add('${seconds}s');

    return parts.join(' ');
  }

  TimerState copyWith({
    TimerStatus? status,
    int? elapsedSeconds,
    DateTime? startTime,
    bool clearStartTime = false,
    String? targetObject,
    bool clearTargetObject = false,
    int? interruptionCount,
    String? penaltyMessage,
    bool clearPenalty = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      targetObject: clearTargetObject ? null : (targetObject ?? this.targetObject),
      interruptionCount: interruptionCount ?? this.interruptionCount,
      penaltyMessage: clearPenalty ? null : (penaltyMessage ?? this.penaltyMessage),
    );
  }
}

class TimerController extends StateNotifier<TimerState> {
  final Ref? _ref;
  Timer? _ticker;
  final Random _random = Random();

  TimerController([this._ref]) : super(const TimerState());

  Future<void> startTimer() async {
    if (state.status == TimerStatus.running) return;

    // Trigger native blocker / screen lock
    try {
      await BlockerChannel.startLock();
    } catch (_) {
      // Ignored if platform doesn't support or in debug mode
    }

    state = state.copyWith(
      status: TimerStatus.running,
      elapsedSeconds: 0,
      startTime: DateTime.now(),
      clearTargetObject: true,
      clearPenalty: true,
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  /// Initiates stopping the chronometer, strictly requiring object photo verification.
  String requestStop() {
    final chosenObject = targetObjects[_random.nextInt(targetObjects.length)];
    state = state.copyWith(
      status: TimerStatus.verifying,
      targetObject: chosenObject,
    );
    return chosenObject;
  }

  /// Cancels verification and resumes normal view (ticker keeps counting)
  void cancelVerification() {
    if (state.status == TimerStatus.verifying) {
      state = state.copyWith(
        status: TimerStatus.running,
        clearTargetObject: true,
      );
    }
  }

  /// Called after successful camera object verification to officially stop the chronometer
  Future<void> onVerificationSuccess() async {
    _ticker?.cancel();
    try {
      await BlockerChannel.stopLock();
    } catch (_) {
      // Ignored if platform doesn't support
    }

    final duration = state.elapsedSeconds;
    final object = state.targetObject;
    final strikes = state.interruptionCount;
    final start = state.startTime ??
        DateTime.now().subtract(Duration(seconds: duration));
    final end = DateTime.now();

    // Persist to ActivityController if Ref is available and duration > 0
    if (_ref != null && duration > 0) {
      _ref.read(activityControllerProvider.notifier).recordSession(
            startTime: start,
            endTime: end,
            durationSeconds: duration,
            targetObject: object,
            strikes: 0,
          );
    }

    // Return to the same Standby state as in first boot
    state = const TimerState();
  }

  /// App interrupted hook (strike logic removed)
  void onAppInterrupted() {
    // Strike logic removed
  }

  void reset() {
    _ticker?.cancel();
    state = const TimerState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final timerControllerProvider =
    StateNotifierProvider<TimerController, TimerState>((ref) {
  return TimerController(ref);
});

