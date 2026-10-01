import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exam_seg_app/features/activity/models/activity_session.dart';
import 'package:exam_seg_app/features/activity/controllers/activity_controller.dart';
import 'package:exam_seg_app/features/activity/presentation/activity_screen.dart';
import 'package:exam_seg_app/features/timer/controllers/timer_controller.dart';
import 'package:exam_seg_app/features/home/presentation/main_navigation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.exam_seg_app/blocker'),
      (MethodCall methodCall) async => true,
    );
  });

  group('ActivitySession & DailyActivityGroup', () {
    test('formats duration accurately', () {
      final session1 = ActivitySession(
        id: '1',
        title: 'Session 1',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 11, 15),
        durationSeconds: 4500, // 1h 15m
      );
      expect(session1.formattedDuration, '1h 15m');

      final session2 = ActivitySession(
        id: '2',
        title: 'Session 2',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 10, 45),
        durationSeconds: 2700, // 45m
      );
      expect(session2.formattedDuration, '45m');

      final session3 = ActivitySession(
        id: '3',
        title: 'Session 3',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 10, 0, 30),
        durationSeconds: 30, // 30s
      );
      expect(session3.formattedDuration, '30s');
    });

    test('toJson and fromJson serialize properly', () {
      final now = DateTime.now();
      final session = ActivitySession(
        id: 'test-id',
        title: 'Math Study',
        startTime: now,
        endTime: now.add(const Duration(minutes: 30)),
        durationSeconds: 1800,
        targetObject: 'Laptop',
        strikes: 1,
      );

      final json = session.toJson();
      final restored = ActivitySession.fromJson(json);

      expect(restored.id, session.id);
      expect(restored.title, session.title);
      expect(restored.durationSeconds, session.durationSeconds);
      expect(restored.targetObject, session.targetObject);
      expect(restored.strikes, session.strikes);
    });

    test('groupSessionsByDay accurately separates sessions by date', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final sessionToday = ActivitySession(
        id: 'today-1',
        title: 'Today Block',
        startTime: DateTime(today.year, today.month, today.day, 10, 0),
        endTime: DateTime(today.year, today.month, today.day, 11, 0),
        durationSeconds: 3600,
      );

      final sessionYesterday = ActivitySession(
        id: 'yest-1',
        title: 'Yesterday Block',
        startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 0),
        endTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 45),
        durationSeconds: 2700,
      );

      final groups = groupSessionsByDay(
        sessions: [sessionToday, sessionYesterday],
      );

      expect(groups.isNotEmpty, true);
      final todayGroup = groups.firstWhere((g) => g.isToday);
      expect(todayGroup.sessions.length, 1);
      expect(todayGroup.totalSeconds, 3600);

      final yesterdayGroup = groups.firstWhere((g) => g.isYesterday);
      expect(yesterdayGroup.sessions.length, 1);
      expect(yesterdayGroup.totalSeconds, 2700);
    });
  });

  group('ActivityScreen Widget Tests', () {
    testWidgets('renders ActivityScreen with daily breakdown and statistics',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ActivityScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Focus Activity'), findsNothing);
      expect(find.text('Today\'s Focus'), findsOneWidget);
      expect(find.text('7-Day Focus Distribution'), findsOneWidget);
      expect(find.text('Daily Activity Breakdown'), findsOneWidget);
      expect(find.text('Today'), findsWidgets);
    });

    testWidgets('actively tracks running timer in today\'s activity tally',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start the timer to simulate active focus
      await container.read(timerControllerProvider.notifier).startTimer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ActivityScreen(),
          ),
        ),
      );
      await tester.pump();

      // Banner should be visible indicating timer is actively tracking
      expect(find.text('TIMER ACTIVELY TRACKING'), findsOneWidget);
      expect(find.text('Tracking actively now'), findsOneWidget);
      expect(find.text('ACTIVE NOW'), findsOneWidget);

      // Clean up timer
      container.read(timerControllerProvider.notifier).reset();
      await tester.pump();
    });

    testWidgets('MainNavigationScreen displays Activity tab item',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Activity'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);

      // Switch to Activity tab
      await tester.tap(find.text('Activity'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Daily Activity Breakdown'), findsOneWidget);
    });
  });
}
