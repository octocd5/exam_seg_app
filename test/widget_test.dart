import 'package:flutter/material.dart';
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

    // Title is removed from AppBar; verify Start button and standby focus bubble
    expect(find.text('Start Chronometer'), findsOneWidget);
    expect(find.text("TODAY'S FOCUS TIME"), findsOneWidget);
  });

  testWidgets('FocusGuardApp applies Average Sans font to theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FocusGuardApp(),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.textTheme.bodyMedium?.fontFamily, contains('AverageSans'));
    expect(materialApp.theme?.textTheme.titleLarge?.fontFamily, contains('AverageSans'));
    expect(materialApp.theme?.textTheme.headlineSmall?.fontFamily, contains('AverageSans'));
  });
}
