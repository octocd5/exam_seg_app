import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:exam_seg_app/features/timer/presentation/timer_screen.dart';
import 'package:exam_seg_app/features/timer/controllers/timer_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.exam_seg_app/blocker'),
      (MethodCall methodCall) async => true,
    );
  });

  testWidgets('TimerScreen renders Burbuja Lottie and standby activity bubble',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TimerScreen(),
        ),
      ),
    );

    // Verify Lottie is present
    expect(find.byType(Lottie), findsOneWidget);

    // Verify initial standby state: actual timer is hidden, activity bubble is visible
    expect(find.text('00:00'), findsNothing);
    expect(find.text("TODAY'S FOCUS TIME"), findsOneWidget);
    expect(find.text('Start Chronometer'), findsOneWidget);
    expect(find.text('Chronometer Ready'), findsOneWidget);

    // Verify title and button subtitles are removed
    expect(find.text('Focus Chronometer'), findsNothing);
    expect(
      find.text('The only way to stop is by photographing a random object'),
      findsNothing,
    );
  });

  testWidgets(
      'TimerScreen transitions from standby to active: shows actual timer and removes bubble',
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

    // Tap Start Chronometer
    await tester.tap(find.text('Start Chronometer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Verify state transitioned to running
    final state = container.read(timerControllerProvider);
    expect(state.status, TimerStatus.running);

    // In active state: actual timer & tracking indicator become visible, bubble is hidden
    expect(find.text('TRACKING TIME'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text("TODAY'S FOCUS TIME"), findsNothing);
    expect(find.text('Stop (Scan Object to Unlock)'), findsOneWidget);
    expect(
      find.text('App will assign a random item to photograph'),
      findsNothing,
    );

    // Clean up active ticker before test finishes
    container.read(timerControllerProvider.notifier).reset();
    await tester.pump();
  });
}
