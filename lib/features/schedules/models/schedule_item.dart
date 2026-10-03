import 'package:flutter/material.dart';
import '../../../core/localization/app_strings.dart';

class ScheduleItem {
  final String id;
  final String title;
  final TimeOfDay time;
  final TimeOfDay? endTime;
  final int? durationMinutes;
  final List<int> repeatDays; // 1 = Mon, 7 = Sun
  final bool isEnabled;
  final String? listId;
  final String? listName;

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.time,
    this.endTime,
    this.durationMinutes,
    required this.repeatDays,
    this.isEnabled = true,
    this.listId,
    this.listName,
  });

  bool get endsWhenStopped => endTime == null;

  ScheduleItem copyWith({
    String? id,
    String? title,
    TimeOfDay? time,
    TimeOfDay? endTime,
    bool clearEndTime = false,
    int? durationMinutes,
    bool clearDuration = false,
    List<int>? repeatDays,
    bool? isEnabled,
    String? listId,
    bool clearListId = false,
    String? listName,
    bool clearListName = false,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      durationMinutes: clearDuration ? null : (durationMinutes ?? this.durationMinutes),
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      listId: clearListId ? null : (listId ?? this.listId),
      listName: clearListName ? null : (listName ?? this.listName),
    );
  }

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String? get formattedEndTime {
    if (endTime == null) return null;
    final hour = endTime!.hourOfPeriod == 0 ? 12 : endTime!.hourOfPeriod;
    final minute = endTime!.minute.toString().padLeft(2, '0');
    final period = endTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String timeRangeSummary(AppStrings strings) {
    if (endTime != null) {
      return '$formattedTime - $formattedEndTime';
    }
    return '$formattedTime (${strings.schedulesUntilStopped})';
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

  String localizedDaysSummary(AppStrings strings) {
    if (repeatDays.length == 7) return strings.scheduleEveryday;
    if (repeatDays.length == 5 &&
        !repeatDays.contains(6) &&
        !repeatDays.contains(7)) {
      return strings.scheduleWeekdays;
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains(6) &&
        repeatDays.contains(7)) {
      return strings.scheduleWeekends;
    }
    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => strings.scheduleShortDayNames[d - 1]).join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hour': time.hour,
        'minute': time.minute,
        'endHour': endTime?.hour,
        'endMinute': endTime?.minute,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        'repeatDays': repeatDays,
        'isEnabled': isEnabled,
        'listId': listId,
        'listName': listName,
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    final endHour = json['endHour'] as int?;
    final endMinute = json['endMinute'] as int?;
    final parsedEndTime = endHour != null
        ? TimeOfDay(hour: endHour, minute: endMinute ?? 0)
        : null;

    return ScheduleItem(
      id: json['id'] as String,
      title: json['title'] as String,
      time: TimeOfDay(
        hour: json['hour'] as int? ?? 9,
        minute: json['minute'] as int? ?? 0,
      ),
      endTime: parsedEndTime,
      durationMinutes: json['durationMinutes'] as int?,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [1, 2, 3, 4, 5],
      isEnabled: json['isEnabled'] as bool? ?? true,
      listId: json['listId'] as String?,
      listName: json['listName'] as String?,
    );
  }
}

