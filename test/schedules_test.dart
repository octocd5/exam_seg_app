import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exam_seg_app/features/lists/controllers/lists_controller.dart';
import 'package:exam_seg_app/features/schedules/controllers/schedules_controller.dart';
import 'package:exam_seg_app/features/schedules/models/schedule_item.dart';
import 'package:exam_seg_app/features/schedules/presentation/schedules_screen.dart';

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
        endTime: TimeOfDay(hour: 10, minute: 0),
        repeatDays: [1, 2, 3, 4, 5],
        isEnabled: true,
      );

      await controller.addSchedule(newSchedule);

      expect(controller.state.schedules.length, 1);
      expect(controller.state.schedules.first.title, 'Morning Focus Block');
      expect(controller.state.schedules.first.endTime, const TimeOfDay(hour: 10, minute: 0));
      expect(controller.state.schedules.first.endsWhenStopped, false);

      // Check reload
      final reloadController = SchedulesController();
      await reloadController.loadSchedules();
      expect(reloadController.state.schedules.length, 1);
      expect(reloadController.state.schedules.first.id, 'test-sched-1');
      expect(reloadController.state.schedules.first.endTime, const TimeOfDay(hour: 10, minute: 0));
    });

    test('adds a schedule that ends when stopped', () async {
      final controller = SchedulesController();
      await controller.loadSchedules();

      const openSchedule = ScheduleItem(
        id: 'test-sched-open',
        title: 'Open Ended Block',
        time: TimeOfDay(hour: 14, minute: 0),
        endTime: null,
        repeatDays: [1, 2, 3],
        isEnabled: true,
      );

      await controller.addSchedule(openSchedule);
      expect(controller.state.schedules.first.endsWhenStopped, true);
      expect(controller.state.schedules.first.endTime, isNull);

      final reloadController = SchedulesController();
      await reloadController.loadSchedules();
      expect(reloadController.state.schedules.first.endsWhenStopped, true);
      expect(reloadController.state.schedules.first.endTime, isNull);
    });

    test('toggles and deletes a schedule', () async {
      final controller = SchedulesController();
      await controller.loadSchedules();

      const newSchedule = ScheduleItem(
        id: 'test-sched-2',
        title: 'Math Study',
        time: TimeOfDay(hour: 14, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 30),
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

    test('adds a schedule with an assigned list and persists it', () async {
      final controller = SchedulesController();
      await controller.loadSchedules();

      const scheduleWithList = ScheduleItem(
        id: 'test-sched-list-1',
        title: 'Deep Coding',
        time: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 30),
        repeatDays: [1, 3, 5],
        isEnabled: true,
        listId: 'list-dev-123',
        listName: 'Developer Tools',
      );

      await controller.addSchedule(scheduleWithList);

      expect(controller.state.schedules.length, 1);
      final saved = controller.state.schedules.first;
      expect(saved.listId, 'list-dev-123');
      expect(saved.listName, 'Developer Tools');
      expect(saved.endTime, const TimeOfDay(hour: 11, minute: 30));

      // Check persistence after reload
      final reloadController = SchedulesController();
      await reloadController.loadSchedules();
      expect(reloadController.state.schedules.first.listId, 'list-dev-123');
      expect(reloadController.state.schedules.first.listName, 'Developer Tools');
      expect(reloadController.state.schedules.first.endTime, const TimeOfDay(hour: 11, minute: 30));
    });

    test('updates a schedule with a new assigned list and end time', () async {
      final controller = SchedulesController();
      await controller.loadSchedules();

      const initialSchedule = ScheduleItem(
        id: 'test-sched-update-1',
        title: 'Study Session',
        time: TimeOfDay(hour: 16, minute: 0),
        endTime: TimeOfDay(hour: 17, minute: 0),
        repeatDays: [2, 4],
        isEnabled: true,
        listId: 'list-initial-1',
        listName: 'Initial List',
      );

      await controller.addSchedule(initialSchedule);

      final updatedSchedule = initialSchedule.copyWith(
        title: 'Advanced Study Session',
        endTime: const TimeOfDay(hour: 18, minute: 30),
        listId: 'list-advanced-2',
        listName: 'Advanced List',
      );

      await controller.updateSchedule(updatedSchedule);

      expect(controller.state.schedules.length, 1);
      final current = controller.state.schedules.first;
      expect(current.title, 'Advanced Study Session');
      expect(current.endTime, const TimeOfDay(hour: 18, minute: 30));
      expect(current.listId, 'list-advanced-2');
      expect(current.listName, 'Advanced List');
    });

    test('ScheduleItem toJson and fromJson preserves endTime, endsWhenStopped, listId and listName', () {
      const scheduleWithEnd = ScheduleItem(
        id: 'json-sched',
        title: 'Reading',
        time: TimeOfDay(hour: 7, minute: 30),
        endTime: TimeOfDay(hour: 8, minute: 45),
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        listId: 'list-reading',
        listName: 'No Social Media',
      );

      final json = scheduleWithEnd.toJson();
      expect(json['endHour'], 8);
      expect(json['endMinute'], 45);
      expect(json['listId'], 'list-reading');
      expect(json['listName'], 'No Social Media');

      final reconstructed = ScheduleItem.fromJson(json);
      expect(reconstructed.id, scheduleWithEnd.id);
      expect(reconstructed.endTime, const TimeOfDay(hour: 8, minute: 45));
      expect(reconstructed.endsWhenStopped, false);
      expect(reconstructed.listId, 'list-reading');

      const scheduleOpen = ScheduleItem(
        id: 'json-sched-open',
        title: 'Open Reading',
        time: TimeOfDay(hour: 7, minute: 30),
        endTime: null,
        repeatDays: [1, 2, 3],
        isEnabled: true,
      );

      final jsonOpen = scheduleOpen.toJson();
      expect(jsonOpen['endHour'], isNull);
      expect(jsonOpen['endMinute'], isNull);

      final reconstructedOpen = ScheduleItem.fromJson(jsonOpen);
      expect(reconstructedOpen.endTime, isNull);
      expect(reconstructedOpen.endsWhenStopped, true);
    });
  });

  group('SchedulesScreen Widget Tests', () {
    testWidgets('displays assigned list name, end time badge on schedule card',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Create a test list
      container.read(listsControllerProvider.notifier).createList(
            name: 'Exam Mode',
            appNames: ['Instagram', 'TikTok'],
            isTimerActive: false,
          );

      final createdList =
          container.read(listsControllerProvider).lists.first;

      // Add a schedule linked to this list with an end time
      await container.read(schedulesControllerProvider.notifier).addSchedule(
            ScheduleItem(
              id: 'widget-sched-1',
              title: 'Finals Prep',
              time: const TimeOfDay(hour: 8, minute: 0),
              endTime: const TimeOfDay(hour: 9, minute: 0),
              repeatDays: const [1, 2, 3],
              isEnabled: true,
              listId: createdList.id,
              listName: createdList.name,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SchedulesScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify schedule details, assigned list name, and Ends at badge
      expect(find.text('Finals Prep'), findsOneWidget);
      expect(find.text('Exam Mode'), findsOneWidget);
      expect(find.text('2 apps blocked'), findsOneWidget);
      expect(find.text('Ends at 9:00 AM'), findsOneWidget);
    });

    testWidgets('displays Until stopped badge when schedule has no end time',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(schedulesControllerProvider.notifier).addSchedule(
            const ScheduleItem(
              id: 'widget-sched-open',
              title: 'Open Focus Session',
              time: TimeOfDay(hour: 10, minute: 0),
              endTime: null,
              repeatDays: [1, 2, 3],
              isEnabled: true,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SchedulesScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Open Focus Session'), findsOneWidget);
      expect(find.text('Until stopped'), findsOneWidget);
    });

    testWidgets('opens modal with list dropdown and End when stopped toggle',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Create two lists
      container.read(listsControllerProvider.notifier).createList(
            name: 'Study Group',
            appNames: ['YouTube'],
            isTimerActive: false,
          );
      container.read(listsControllerProvider.notifier).createList(
            name: 'Phone Ban',
            appNames: ['Clock'],
            isPhoneWideBan: true,
            isTimerActive: false,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SchedulesScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap floating action button to open sheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify list picker dropdown is rendered
      expect(find.text('Block List'), findsOneWidget);
      expect(find.text('Phone Ban'), findsWidgets);

      // Verify End Mode buttons
      expect(find.text('Set End Time'), findsOneWidget);
      expect(find.text('End when stopped'), findsOneWidget);

      // Select "End when stopped"
      await tester.tap(find.text('End when stopped'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Schedule'));
      await tester.pumpAndSettle();

      // Verify schedule was saved with the picked list and endTime == null
      final schedules = container.read(schedulesControllerProvider).schedules;
      expect(schedules.length, 1);
      expect(schedules.first.listName, 'Phone Ban');
      expect(schedules.first.endsWhenStopped, true);
      expect(schedules.first.endTime, isNull);
    });
  });
}
