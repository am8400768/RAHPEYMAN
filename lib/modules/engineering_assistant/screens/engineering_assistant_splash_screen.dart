import 'dart:async';

import 'package:flutter/material.dart';

import 'engineering_assistant_home_screen.dart';

class EngineeringAssistantSplashScreen extends StatefulWidget {
  const EngineeringAssistantSplashScreen({super.key});

  @override
  State<EngineeringAssistantSplashScreen> createState() =>
      _EngineeringAssistantSplashScreenState();
}

class _EngineeringAssistantSplashScreenState
    extends State<EngineeringAssistantSplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _openEngineeringAssistant);
  }

  void _openEngineeringAssistant() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const EngineeringAssistantHomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.engineering_rounded,
              size: 80,
              color: Color(0xFF00BFA5),
            ),
            const SizedBox(height: 24),
            const Text(
              'مهندس‌یار',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابزارهای مهندسی رهپیمان',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF00BFA5).withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
