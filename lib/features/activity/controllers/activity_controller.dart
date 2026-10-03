import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_session.dart';

class ActivityState {
  final List<ActivitySession> sessions;
  final bool isLoading;

  const ActivityState({
    this.sessions = const [],
    this.isLoading = false,
  });

  ActivityState copyWith({
    List<ActivitySession>? sessions,
    bool? isLoading,
  }) {
    return ActivityState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ActivityController extends StateNotifier<ActivityState> {
  static const String _storageKey = 'saved_activity_sessions_v2';
  static const Uuid _uuid = Uuid();

  ActivityController() : super(const ActivityState(isLoading: true)) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear legacy storage key containing seed/placeholder data
      await prefs.remove('saved_activity_sessions_v1');

      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        final loaded = decoded
            .map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
            .where((s) => !s.id.startsWith('seed-'))
            .toList();

        // Sort descending by start time
        loaded.sort((a, b) => b.startTime.compareTo(a.startTime));
        state = state.copyWith(sessions: loaded, isLoading: false);
      } else {
        // First boot: completely clean with 0 placeholder sessions
        state = state.copyWith(sessions: const [], isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(sessions: const [], isLoading: false);
    }
  }

  Future<void> recordSession({
    required DateTime startTime,
    required DateTime endTime,
    required int durationSeconds,
    String? targetObject,
    int strikes = 0,
    String? title,
  }) async {
    if (durationSeconds <= 0) return;

    final newSession = ActivitySession(
      id: _uuid.v4(),
      title: title ?? _defaultTitleForDuration(durationSeconds),
      startTime: startTime,
      endTime: endTime,
      durationSeconds: durationSeconds,
      targetObject: targetObject,
      strikes: strikes,
    );

    final updated = [newSession, ...state.sessions];
    updated.sort((a, b) => b.startTime.compareTo(a.startTime));

    state = state.copyWith(sessions: updated);
    await _saveSessionsToPrefs(updated);
  }

  Future<void> clearAllSessions() async {
    state = state.copyWith(sessions: const []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove('saved_activity_sessions_v1');
    } catch (_) {}
  }

  Future<void> _saveSessionsToPrefs(List<ActivitySession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (_) {}
  }

  static String _defaultTitleForDuration(int seconds) {
    if (seconds >= 3600) {
      return 'Deep Exam Focus';
    } else if (seconds >= 1800) {
      return 'Core Study Block';
    } else {
      return 'Quick Focus Sprint';
    }
  }
}

final activityControllerProvider =
    StateNotifierProvider<ActivityController, ActivityState>((ref) {
  return ActivityController();
});

/// Grouped daily activity provider that merges saved sessions with the currently active live timer session
List<DailyActivityGroup> groupSessionsByDay({
  required List<ActivitySession> sessions,
  ActivitySession? liveSession,
}) {
  final allSessions = <ActivitySession>[];
  if (liveSession != null) {
    allSessions.add(liveSession);
  }
  allSessions.addAll(sessions);

  if (allSessions.isEmpty) {
    return const [];
  }

  // Group by date (normalized to year, month, day)
  final Map<String, List<ActivitySession>> groupedMap = {};
  final Map<String, DateTime> normalizedDates = {};

  for (final session in allSessions) {
    final d = session.startTime;
    final dateKey = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (!groupedMap.containsKey(dateKey)) {
      groupedMap[dateKey] = [];
      normalizedDates[dateKey] = DateTime(d.year, d.month, d.day);
    }
    groupedMap[dateKey]!.add(session);
  }

  // Convert to DailyActivityGroup list
  final List<DailyActivityGroup> result = [];
  final sortedKeys = groupedMap.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // Descending order: newest day first

  for (final key in sortedKeys) {
    final daySessions = groupedMap[key]!;
    // Sort day's sessions newest first
    daySessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    final totalSecs = daySessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );
    final totalStrikes = daySessions.fold<int>(
      0,
      (sum, s) => sum + s.strikes,
    );

    result.add(
      DailyActivityGroup(
        date: normalizedDates[key]!,
        sessions: daySessions,
        totalSeconds: totalSecs,
        totalStrikes: totalStrikes,
      ),
    );
  }

  return result;
}
