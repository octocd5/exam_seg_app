import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_item.dart';

class SchedulesState {
  final List<ScheduleItem> schedules;

  const SchedulesState({this.schedules = const []});

  SchedulesState copyWith({List<ScheduleItem>? schedules}) {
    return SchedulesState(
      schedules: schedules ?? this.schedules,
    );
  }
}

class SchedulesController extends StateNotifier<SchedulesState> {
  SchedulesController()
      : super(
          const SchedulesState(
            schedules: [
              ScheduleItem(
                id: 'sched-1',
                title: 'Morning Focus Block',
                time: TimeOfDay(hour: 8, minute: 30),
                durationMinutes: 45,
                repeatDays: [1, 2, 3, 4, 5],
                isEnabled: true,
              ),
              ScheduleItem(
                id: 'sched-2',
                title: 'Exam Review & Practice',
                time: TimeOfDay(hour: 14, minute: 0),
                durationMinutes: 60,
                repeatDays: [1, 2, 3, 4, 5, 6, 7],
                isEnabled: true,
              ),
              ScheduleItem(
                id: 'sched-3',
                title: 'Evening Deep Reading',
                time: TimeOfDay(hour: 20, minute: 0),
                durationMinutes: 30,
                repeatDays: [1, 3, 5],
                isEnabled: false,
              ),
            ],
          ),
        );

  void toggleSchedule(String id) {
    state = state.copyWith(
      schedules: state.schedules.map((s) {
        if (s.id == id) {
          return s.copyWith(isEnabled: !s.isEnabled);
        }
        return s;
      }).toList(),
    );
  }

  void addSchedule(ScheduleItem schedule) {
    state = state.copyWith(
      schedules: [...state.schedules, schedule],
    );
  }

  void deleteSchedule(String id) {
    state = state.copyWith(
      schedules: state.schedules.where((s) => s.id != id).toList(),
    );
  }
}

final schedulesControllerProvider =
    StateNotifierProvider<SchedulesController, SchedulesState>((ref) {
  return SchedulesController();
});
