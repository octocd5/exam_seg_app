import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_seg_app/main.dart';

void main() {
  testWidgets('Focus Chronometer smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FocusGuardApp(),
      ),
    );

    expect(find.text('Focus Chronometer'), findsOneWidget);
    expect(find.text('Start Chronometer'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
  });
}
