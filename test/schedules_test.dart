import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exam_seg_app/features/schedules/controllers/schedules_controller.dart';
import 'package:exam_seg_app/features/schedules/models/schedule_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SchedulesController Unit Tests', () {
    test('schedules are empty on first boot', () async {
      final controller = SchedulesController();
      await controller.loadSchedules();

      expect(controller.state.schedules.isEmpty, true);
    });

    test('adds a schedule and persists it', () async {
      final controller = SchedulesController();
      await controller.loadSchedules();

      const newSchedule = ScheduleItem(
        id: 'test-sched-1',
        title: 'Morning Focus Block',
        time: TimeOfDay(hour: 8, minute: 30),
        durationMinutes: 45,
        repeatDays: [1, 2, 3, 4, 5],
        isEnabled: true,
      );

      await controller.addSchedule(newSchedule);

      expect(controller.state.schedules.length, 1);
      expect(controller.state.schedules.first.title, 'Morning Focus Block');

      // Check reload
      final reloadController = SchedulesController();
      await reloadController.loadSchedules();
      expect(reloadController.state.schedules.length, 1);
      expect(reloadController.state.schedules.first.id, 'test-sched-1');
    });

    test('toggles and deletes a schedule', () async {
      final controller = SchedulesController();
      await controller.loadSchedules();

      const newSchedule = ScheduleItem(
        id: 'test-sched-2',
        title: 'Math Study',
        time: TimeOfDay(hour: 14, minute: 0),
        durationMinutes: 60,
        repeatDays: [1, 2, 3],
        isEnabled: true,
      );

      await controller.addSchedule(newSchedule);
      expect(controller.state.schedules.first.isEnabled, true);

      await controller.toggleSchedule('test-sched-2');
      expect(controller.state.schedules.first.isEnabled, false);

      await controller.deleteSchedule('test-sched-2');
      expect(controller.state.schedules.isEmpty, true);
    });
  });
}
