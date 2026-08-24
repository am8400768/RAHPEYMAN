import 'package:flutter/material.dart';

import 'sharayet_home_screen.dart';

class SharayetSplashScreen extends StatefulWidget {
  const SharayetSplashScreen({super.key});

  @override
  State<SharayetSplashScreen> createState() => _SharayetSplashScreenState();
}

class _SharayetSplashScreenState extends State<SharayetSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SharayetHomeScreen(),
      ),
    );
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
              Icons.gavel,
              size: 80,
              color: Color(0xFF00BFA5),
            ),
            const SizedBox(height: 24),
            const Text(
              'شرایط عمومی پیمان',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'همراه مهندسین از آموزش تا اجرا',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF00BFA5).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}