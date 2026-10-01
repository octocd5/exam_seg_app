import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FocusGuardApp(),
    ),
  );
}

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1D1C1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC4BDDD),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
