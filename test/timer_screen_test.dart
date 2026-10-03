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

  testWidgets(
      'TimerScreen renders BubbleTriste in standby state and standby activity bubble',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TimerScreen(),
        ),
      ),
    );

    // Verify BubbleTriste Lottie is present in standby state
    expect(find.byType(Lottie), findsOneWidget);
    expect(
      find.byKey(const ValueKey('assets/animations/BubbleTriste.json')),
      findsOneWidget,
    );

    // Verify initial standby state: actual timer is hidden, activity bubble is visible
    expect(find.text('00:00'), findsNothing);
    expect(find.text("TODAY'S FOCUS TIME"), findsOneWidget);
    expect(find.text('Start Chronometer'), findsOneWidget);
    // "Timer Ready" / "Chronometer Ready" banner is removed to make way for top elements
    expect(find.text('Chronometer Ready'), findsNothing);

    // Verify title and button subtitles are removed
    expect(find.text('Focus Chronometer'), findsNothing);
    expect(
      find.text('The only way to stop is by photographing a random object'),
      findsNothing,
    );
  });

  testWidgets(
      'TimerScreen transitions from standby to active: plays BubbleTF then BubbleIdle',
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

    // Initially in standby with BubbleTriste
    expect(
      find.byKey(const ValueKey('assets/animations/BubbleTriste.json')),
      findsOneWidget,
    );

    // Tap Start Chronometer
    await tester.tap(find.text('Start Chronometer'));
    await tester.pump();

    // Verify state transitioned to running and BubbleTF transition animation is loaded
    final state = container.read(timerControllerProvider);
    expect(state.status, TimerStatus.running);
    expect(
      find.byKey(const ValueKey('assets/animations/BubbleTF.json')),
      findsOneWidget,
    );

    // In active state: actual timer & tracking indicator become visible, bubble is hidden
    expect(find.text('TRACKING TIME'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text("TODAY'S FOCUS TIME"), findsNothing);
    expect(find.text('Stop (Scan Object to Unlock)'), findsOneWidget);

    final lottie = tester.widget<Lottie>(find.byType(Lottie));
    expect(lottie.controller, isNotNull);
    final animController = lottie.controller as AnimationController;
    expect(animController.duration, const Duration(seconds: 6));

    // Pump initial frame so AnimationController registers start time
    await tester.pump(const Duration(milliseconds: 100));
    // Pump until BubbleTF completes its 6-second forward animation
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Verify it transitioned into active looping BubbleIdle
    expect(
      find.byKey(const ValueKey('assets/animations/BubbleIdle.json')),
      findsOneWidget,
    );

    // Clean up active ticker before test finishes
    container.read(timerControllerProvider.notifier).reset();
    await tester.pump();
  });

  testWidgets(
      'TimerScreen session completion triggers BubbleFT transition back to BubbleTriste',
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

    // Start chronometer
    await tester.tap(find.text('Start Chronometer'));
    await tester.pump();

    // Trigger verification success
    await container
        .read(timerControllerProvider.notifier)
        .onVerificationSuccess();
    await tester.pump();

    // Verify transition to BubbleFT occurs upon ending session
    expect(
      find.byKey(const ValueKey('assets/animations/BubbleFT.json')),
      findsOneWidget,
    );

    // Pump until BubbleFT (5 seconds) completes its forward animation
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Verify it transitioned back into standby looping BubbleTriste
    expect(
      find.byKey(const ValueKey('assets/animations/BubbleTriste.json')),
      findsOneWidget,
    );

    // Verify screen returned to the first-boot Standby state UI:
    expect(find.text("TODAY'S FOCUS TIME"), findsOneWidget);
    expect(find.text('Start Chronometer'), findsOneWidget);
    expect(find.text('Focus Session Completed!'), findsNothing);
    expect(find.text('Session Finished'), findsNothing);
    expect(find.text('Discipline Strikes'), findsNothing);
  });
}
