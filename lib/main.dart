import 'package:flutter/material.dart';

import 'screens/semester_screen.dart';
import 'state/semester_controller.dart';

void main() {
  runApp(const GpaCalculatorApp());
}

class GpaCalculatorApp extends StatefulWidget {
  const GpaCalculatorApp({super.key});

  @override
  State<GpaCalculatorApp> createState() => _GpaCalculatorAppState();
}

class _GpaCalculatorAppState extends State<GpaCalculatorApp> {
  /// One controller for the life of the app, owned here and disposed here.
  /// It is passed down rather than reached for through a global, so a test can
  /// build the screen with a controller it has already filled.
  final SemesterController _controller = SemesterController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00563F)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00563F),
          brightness: Brightness.dark,
        ),
      ),
      home: SemesterScreen(controller: _controller),
    );
  }
}
