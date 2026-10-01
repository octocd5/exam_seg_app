class ActivitySession {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String? targetObject;
  final int strikes;
  final bool isLive;

  const ActivitySession({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    this.targetObject,
    this.strikes = 0,
    this.isLive = false,
  });

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    } else if (minutes > 0) {
      if (seconds > 0 && minutes < 5) {
        return '${minutes}m ${seconds}s';
      }
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedTimeRange {
    final startStr = _formatTime(startTime);
    final endStr = isLive ? 'Now' : _formatTime(endTime);
    return '$startStr - $endStr';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '$formattedHour:$minute $period';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'targetObject': targetObject,
      'strikes': strikes,
    };
  }

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Focus Session',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      targetObject: json['targetObject'] as String?,
      strikes: json['strikes'] as int? ?? 0,
      isLive: false,
    );
  }

  ActivitySession copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    String? targetObject,
    int? strikes,
    bool? isLive,
  }) {
    return ActivitySession(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      targetObject: targetObject ?? this.targetObject,
      strikes: strikes ?? this.strikes,
      isLive: isLive ?? this.isLive,
    );
  }
}

class DailyActivityGroup {
  final DateTime date; // Normalized DateTime(year, month, day)
  final List<ActivitySession> sessions;
  final int totalSeconds;
  final int totalStrikes;

  DailyActivityGroup({
    required this.date,
    required this.sessions,
    required this.totalSeconds,
    required this.totalStrikes,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String get dayLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';

    const weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    return weekdays[date.weekday - 1];
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String get formattedTotalDuration {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  double get hours => totalSeconds / 3600.0;
}
