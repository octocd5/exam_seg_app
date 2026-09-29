import 'package:flutter/material.dart';

class ScheduleItem {
  final String id;
  final String title;
  final TimeOfDay time;
  final int durationMinutes;
  final List<int> repeatDays; // 1 = Mon, 7 = Sun
  final bool isEnabled;

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.time,
    required this.durationMinutes,
    required this.repeatDays,
    this.isEnabled = true,
  });

  ScheduleItem copyWith({
    String? id,
    String? title,
    TimeOfDay? time,
    int? durationMinutes,
    List<int> repeatDays,
    bool? isEnabled,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get daysSummary {
    if (repeatDays.length == 7) return 'Everyday';
    if (repeatDays.length == 5 &&
        !repeatDays.contains(6) &&
        !repeatDays.contains(7)) {
      return 'Weekdays (Mon-Fri)';
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains(6) &&
        repeatDays.contains(7)) {
      return 'Weekends';
    }
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => dayNames[d - 1]).join(', ');
  }
}
