import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_item.dart';

class SchedulesState {
  final List<ScheduleItem> schedules;
  final bool isLoading;

  const SchedulesState({
    this.schedules = const [],
    this.isLoading = false,
  });

  SchedulesState copyWith({
    List<ScheduleItem>? schedules,
    bool? isLoading,
  }) {
    return SchedulesState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SchedulesController extends StateNotifier<SchedulesState> {
  static const String _storageKey = 'saved_focus_schedules_v2';
  Future<void>? _loadFuture;

  SchedulesController() : super(const SchedulesState(schedules: [])) {
    loadSchedules();
  }

  Future<void> loadSchedules() {
    return _loadFuture ??= _loadSchedulesInternal();
  }

  Future<void> _loadSchedulesInternal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear any legacy placeholder schedules from previous runs
      await prefs.remove('saved_focus_schedules_v1');

      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        final loaded = decoded
            .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
            .where((s) => !s.id.startsWith('sched-1') && !s.id.startsWith('sched-2') && !s.id.startsWith('sched-3'))
            .toList();
        state = state.copyWith(schedules: loaded, isLoading: false);
      } else {
        // Empty on first boot - users set them up first
        state = state.copyWith(schedules: const [], isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(schedules: const [], isLoading: false);
    }
  }

  Future<void> toggleSchedule(String id) async {
    await loadSchedules();
    final updated = state.schedules.map((s) {
      if (s.id == id) {
        return s.copyWith(isEnabled: !s.isEnabled);
      }
      return s;
    }).toList();
    state = state.copyWith(schedules: updated);
    await _persistToPrefs(updated);
  }

  Future<void> addSchedule(ScheduleItem schedule) async {
    await loadSchedules();
    final updated = [...state.schedules, schedule];
    state = state.copyWith(schedules: updated);
    await _persistToPrefs(updated);
  }

  Future<void> deleteSchedule(String id) async {
    await loadSchedules();
    final updated = state.schedules.where((s) => s.id != id).toList();
    state = state.copyWith(schedules: updated);
    await _persistToPrefs(updated);
  }

  Future<void> _persistToPrefs(List<ScheduleItem> schedules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(schedules.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (_) {}
  }
}

final schedulesControllerProvider =
    StateNotifierProvider<SchedulesController, SchedulesState>((ref) {
  return SchedulesController();
});
