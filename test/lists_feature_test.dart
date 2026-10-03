import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exam_seg_app/features/lists/controllers/lists_controller.dart';
import 'package:exam_seg_app/features/lists/models/app_block_list.dart';
import 'package:exam_seg_app/features/lists/presentation/widgets/active_list_card.dart';
import 'package:exam_seg_app/features/lists/presentation/manage_lists_sheet.dart';
import 'package:exam_seg_app/features/lists/presentation/create_or_edit_list_sheet.dart';
import 'package:exam_seg_app/features/timer/controllers/timer_controller.dart';
import 'package:exam_seg_app/features/timer/presentation/timer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.exam_seg_app/blocker'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getInstalledApps') {
          return [
            {
              'appName': 'Instagram',
              'packageName': 'com.instagram.android',
              'isSystemApp': false,
            },
            {
              'appName': 'TikTok',
              'packageName': 'com.zhiliaoapp.musically',
              'isSystemApp': false,
            },
            {
              'appName': 'YouTube',
              'packageName': 'com.google.android.youtube',
              'isSystemApp': false,
            },
          ];
        }
        return true;
      },
    );
  });

  group('ListsController Unit Tests', () {
    test('starts with empty lists on first boot', () async {
      final controller = ListsController();
      await controller.loadLists();

      final state = controller.state;
      expect(state.lists.isEmpty, true);
      expect(state.activeList, isNull);
    });

    test('creates a new list when timer is not active', () async {
      final controller = ListsController();
      await controller.loadLists();

      final success = controller.createList(
        name: 'Work Distractions',
        appNames: ['Slack', 'Reddit', 'YouTube'],
        isTimerActive: false,
      );

      expect(success, true);
      expect(controller.state.lists.length, 1);
      expect(controller.state.activeList!.name, 'Work Distractions');
      expect(controller.state.activeList!.appNames, ['Slack', 'Reddit', 'YouTube']);
    });

    test('switches active list when timer is not active', () async {
      final controller = ListsController();
      await controller.loadLists();

      controller.createList(
        name: 'List A',
        appNames: ['Instagram'],
        isTimerActive: false,
      );
      controller.createList(
        name: 'List B',
        appNames: ['YouTube'],
        isTimerActive: false,
      );

      final listA = controller.state.lists.firstWhere((l) => l.name == 'List A');
      final success = controller.setActiveList(
        listA.id,
        isTimerActive: false,
      );

      expect(success, true);
      expect(controller.state.activeListId, listA.id);
      expect(controller.state.activeList!.name, 'List A');
    });

    test('REJECTS switching active list when timer is active', () async {
      final controller = ListsController();
      await controller.loadLists();

      controller.createList(
        name: 'List A',
        appNames: ['Instagram'],
        isTimerActive: false,
      );
      controller.createList(
        name: 'List B',
        appNames: ['YouTube'],
        isTimerActive: false,
      );

      final listA = controller.state.lists.firstWhere((l) => l.name == 'List A');
      final initialActiveId = controller.state.activeListId;

      final success = controller.setActiveList(
        listA.id,
        isTimerActive: true,
      );

      expect(success, false);
      expect(controller.state.activeListId, initialActiveId);
      expect(
        controller.state.errorMessage,
        'Lists cannot be changed while the timer is active.',
      );
    });

    test('REJECTS creating a list when timer is active', () async {
      final controller = ListsController();
      await controller.loadLists();

      final countBefore = controller.state.lists.length;
      final success = controller.createList(
        name: 'Unauthorized List',
        appNames: ['Chrome'],
        isTimerActive: true,
      );

      expect(success, false);
      expect(controller.state.lists.length, countBefore);
      expect(
        controller.state.errorMessage,
        'Lists cannot be created or edited while the timer is active.',
      );
    });

    test('updates an existing list when timer is not active', () async {
      final controller = ListsController();
      await controller.loadLists();

      controller.createList(
        name: 'Social Distractions',
        appNames: ['Instagram'],
        isTimerActive: false,
      );

      final active = controller.state.activeList!;
      final updated = active.copyWith(
        name: 'Social Media Blocked',
        appNames: ['Instagram', 'TikTok'],
      );

      final success = controller.updateList(updated, isTimerActive: false);
      expect(success, true);
      expect(controller.state.activeList!.name, 'Social Media Blocked');
      expect(controller.state.activeList!.appCount, 2);
    });

    test('REJECTS editing an existing list when timer is active', () async {
      final controller = ListsController();
      await controller.loadLists();

      controller.createList(
        name: 'Social Distractions',
        appNames: ['Instagram'],
        isTimerActive: false,
      );

      final active = controller.state.activeList!;
      final updated = active.copyWith(name: 'Changed Name');

      final success = controller.updateList(updated, isTimerActive: true);
      expect(success, false);
      expect(controller.state.activeList!.name, 'Social Distractions');
      expect(
        controller.state.errorMessage,
        'Lists cannot be edited while the timer is active.',
      );
    });

    test('deletes a list when timer is not active', () async {
      final controller = ListsController();
      await controller.loadLists();

      controller.createList(
        name: 'List 1',
        appNames: ['App 1'],
        isTimerActive: false,
      );
      controller.createList(
        name: 'List 2',
        appNames: ['App 2'],
        isTimerActive: false,
      );

      final listToDelete = controller.state.lists.last;
      final success = controller.deleteList(listToDelete.id, isTimerActive: false);

      expect(success, true);
      expect(controller.state.lists.length, 1);
      expect(controller.state.lists.any((l) => l.id == listToDelete.id), false);
    });

    test('REJECTS deleting a list when timer is active', () async {
      final controller = ListsController();
      await controller.loadLists();

      controller.createList(
        name: 'List 1',
        appNames: ['App 1'],
        isTimerActive: false,
      );

      final listToDelete = controller.state.lists.first;
      final countBefore = controller.state.lists.length;

      final success = controller.deleteList(listToDelete.id, isTimerActive: true);
      expect(success, false);
      expect(controller.state.lists.length, countBefore);
      expect(
        controller.state.errorMessage,
        'Lists cannot be deleted while the timer is active.',
      );
    });
  });

  group('Lists Widget & TimerScreen Integration Tests', () {
    testWidgets('ActiveListCard displays empty state and Create button on first boot',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TimerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Active list card is rendered below the animation
      expect(find.byType(ActiveListCard), findsOneWidget);
      expect(find.text('No Lists Created'), findsOneWidget);
      expect(find.text('Tap to create your first app list'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);

      // Tapping Create opens CreateOrEditListSheet
      await tester.tap(find.text('Create'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(CreateOrEditListSheet), findsOneWidget);
      expect(find.text('Create New List'), findsOneWidget);
    });

    testWidgets('ActiveListCard displays list name and Manage button after creating a list',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Create a list first
      container.read(listsControllerProvider.notifier).createList(
            name: 'Gaming & Streams',
            appNames: ['Twitch', 'YouTube', 'Discord'],
            isTimerActive: false,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TimerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Gaming & Streams'), findsOneWidget);
      expect(find.text('3 apps blocked'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);

      // Tap Manage opens sheet
      await tester.tap(find.text('Manage'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(ManageListsSheet), findsOneWidget);
      expect(find.text('Gaming & Streams'), findsWidgets);
    });

    testWidgets('Active Timer changes Manage button to View and locks lists',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Create a list first
      container.read(listsControllerProvider.notifier).createList(
            name: 'Study Block',
            appNames: ['Instagram', 'TikTok'],
            isTimerActive: false,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TimerScreen(),
          ),
        ),
      );
      await tester.pump();

      // Start the chronometer
      await tester.tap(find.text('Start Chronometer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Now timer is running
      expect(container.read(timerControllerProvider).status, TimerStatus.running);

      // In active mode: button says "View" instead of "Manage", "+ New" is hidden
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Manage'), findsNothing);
      expect(find.text('New'), findsNothing);

      // Tap "View"
      await tester.tap(find.text('View'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // ManageListsSheet is opened in locked / read-only mode
      expect(find.byType(ManageListsSheet), findsOneWidget);
      expect(find.text('Active Block List'), findsOneWidget);
      expect(find.text('View only • Timer is active'), findsOneWidget);
      expect(find.text('LOCKED DURING SESSION'), findsOneWidget);

      // Create New List button is NOT shown in locked mode
      expect(find.text('Create New List'), findsNothing);

      // Clean up timer
      container.read(timerControllerProvider.notifier).reset();
      await tester.pump();
    });

    testWidgets('ActiveListCard renders Phone-Wide Ban badge and summary',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(listsControllerProvider.notifier).createList(
            name: 'Study Allowlist',
            appNames: ['Google Docs', 'Dictionary'],
            isPhoneWideBan: true,
            isTimerActive: false,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TimerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Study Allowlist'), findsOneWidget);
      expect(find.text('Phone-Wide Ban'), findsOneWidget);
      expect(find.text('Phone-wide ban • 2 apps allowed'), findsOneWidget);
    });

    testWidgets('TimerScreen passes list packages and isPhoneWideBan to BlockerChannel',
        (WidgetTester tester) async {
      final recordedCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.exam_seg_app/blocker'),
        (MethodCall call) async {
          recordedCalls.add(call);
          return true;
        },
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(listsControllerProvider.notifier).createList(
            name: 'Allowed Apps Only',
            appNames: ['Calculator', 'Calendar'],
            isPhoneWideBan: true,
            isTimerActive: false,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TimerScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap start chronometer
      await tester.tap(find.text('Start Chronometer'));
      await tester.pump();

      final startLockCall =
          recordedCalls.firstWhere((c) => c.method == 'startLock');
      expect(startLockCall.arguments['isPhoneWideBan'], true);
      expect(startLockCall.arguments['packages'], ['Calculator', 'Calendar']);

      container.read(timerControllerProvider.notifier).reset();
      await tester.pump();
    });
  });

  group('AppBlockList Model Tests', () {
    test('supports standard blocklist mode', () {
      final list = AppBlockList(
        id: 'list-1',
        name: 'Blocklist Test',
        appNames: ['Instagram', 'TikTok'],
        createdAt: DateTime.now(),
        isPhoneWideBan: false,
      );

      expect(list.isPhoneWideBan, false);
      expect(list.modeTitle, 'Blocklist');
      expect(list.blockedSummary, '2 apps blocked');
    });

    test('supports phone-wide ban mode (excluding listed apps)', () {
      final list = AppBlockList(
        id: 'list-2',
        name: 'Phone-Wide Focus',
        appNames: ['Slack', 'Calculator'],
        createdAt: DateTime.now(),
        isPhoneWideBan: true,
      );

      expect(list.isPhoneWideBan, true);
      expect(list.modeTitle, 'Phone-Wide Ban');
      expect(list.blockedSummary, 'Phone-wide ban • 2 apps allowed');
    });

    test('toJson and fromJson preserves isPhoneWideBan correctly', () {
      final original = AppBlockList(
        id: 'list-3',
        name: 'Exclude Ban',
        appNames: ['Notes'],
        createdAt: DateTime.now(),
        isPhoneWideBan: true,
      );

      final json = original.toJson();
      expect(json['isPhoneWideBan'], true);

      final reconstituted = AppBlockList.fromJson(json);
      expect(reconstituted.isPhoneWideBan, true);
      expect(reconstituted.name, 'Exclude Ban');
      expect(reconstituted.appNames, ['Notes']);
    });
  });
}

