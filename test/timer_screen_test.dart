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

  testWidgets('TimerScreen renders Burbuja Lottie and chronometer bar',
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

    // Verify initial idle state
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('STANDBY'), findsOneWidget);
    expect(find.text('Start Chronometer'), findsOneWidget);
    expect(find.text('Chronometer Ready'), findsOneWidget);
  });

  testWidgets(
      'TimerScreen transitions from idle to running and displays tracking state',
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

    // Verify UI reflects active tracking state
    expect(find.text('TRACKING TIME'), findsOneWidget);
    expect(find.text('Stop (Scan Object to Unlock)'), findsOneWidget);

    // Clean up active ticker before test finishes
    container.read(timerControllerProvider.notifier).reset();
    await tester.pump();
  });
}
