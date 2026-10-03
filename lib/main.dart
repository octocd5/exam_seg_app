import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.averageSans().fontFamily,
      scaffoldBackgroundColor: const Color(0xFF1D1C1A),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC4BDDD),
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Focus Guard',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.averageSansTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.averageSansTextTheme(baseTheme.primaryTextTheme),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
