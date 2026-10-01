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
  static const String _storageKey = 'saved_activity_sessions_v1';
  static const Uuid _uuid = Uuid();

  ActivityController() : super(const ActivityState(isLoading: true)) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        final loaded = decoded
            .map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
            .toList();

        // Sort descending by start time
        loaded.sort((a, b) => b.startTime.compareTo(a.startTime));
        state = state.copyWith(sessions: loaded, isLoading: false);
      } else {
        // First run: provide realistic past days demonstration data
        final seedSessions = _generateSeedData();
        state = state.copyWith(sessions: seedSessions, isLoading: false);
        await _saveSessionsToPrefs(seedSessions);
      }
    } catch (_) {
      // In case of error (e.g. test environment without storage), fallback to seed data
      final seed = _generateSeedData();
      state = state.copyWith(sessions: seed, isLoading: false);
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
    state = state.copyWith(sessions: []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
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

  static List<ActivitySession> _generateSeedData() {
    final now = DateTime.now();

    // Helper for days ago
    DateTime daysAgo(int days, int hour, int minute) {
      final d = now.subtract(Duration(days: days));
      return DateTime(d.year, d.month, d.day, hour, minute);
    }

    return [
      // Yesterday (1 day ago)
      ActivitySession(
        id: 'seed-1',
        title: 'Deep Exam Revision',
        startTime: daysAgo(1, 14, 30),
        endTime: daysAgo(1, 15, 25),
        durationSeconds: 3300, // 55 mins
        targetObject: 'Laptop',
        strikes: 0,
      ),
      ActivitySession(
        id: 'seed-2',
        title: 'Problem Solving & Math',
        startTime: daysAgo(1, 10, 0),
        endTime: daysAgo(1, 10, 45),
        durationSeconds: 2700, // 45 mins
        targetObject: 'Coffee cup',
        strikes: 1,
      ),

      // 2 days ago
      ActivitySession(
        id: 'seed-3',
        title: 'Literature Reading Block',
        startTime: daysAgo(2, 16, 0),
        endTime: daysAgo(2, 17, 10),
        durationSeconds: 4200, // 1h 10m
        targetObject: 'Shoe',
        strikes: 0,
      ),
      ActivitySession(
        id: 'seed-4',
        title: 'Formula & Memorization',
        startTime: daysAgo(2, 9, 15),
        endTime: daysAgo(2, 9, 50),
        durationSeconds: 2100, // 35 mins
        targetObject: 'Clock',
        strikes: 0,
      ),

      // 3 days ago
      ActivitySession(
        id: 'seed-5',
        title: 'Core Programming Practice',
        startTime: daysAgo(3, 13, 0),
        endTime: daysAgo(3, 14, 30),
        durationSeconds: 5400, // 1h 30m
        targetObject: 'Computer keyboard',
        strikes: 0,
      ),

      // 4 days ago
      ActivitySession(
        id: 'seed-6',
        title: 'Biology Concept Mapping',
        startTime: daysAgo(4, 11, 0),
        endTime: daysAgo(4, 11, 45),
        durationSeconds: 2700, // 45 mins
        targetObject: 'Laptop',
        strikes: 0,
      ),

      // 5 days ago
      ActivitySession(
        id: 'seed-7',
        title: 'History Essay Outline',
        startTime: daysAgo(5, 15, 30),
        endTime: daysAgo(5, 16, 20),
        durationSeconds: 3000, // 50 mins
        targetObject: 'Bottle',
        strikes: 0,
      ),
    ];
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

  // Ensure "Today" exists even if 0 sessions yet so the user sees today's slot
  final now = DateTime.now();
  final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  if (!groupedMap.containsKey(todayKey)) {
    groupedMap[todayKey] = [];
    normalizedDates[todayKey] = DateTime(now.year, now.month, now.day);
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
