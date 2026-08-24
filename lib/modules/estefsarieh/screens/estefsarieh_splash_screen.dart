import 'package:flutter/material.dart';
import 'estefsarieh_home_screen.dart';

class EstefsariehSplashScreen extends StatefulWidget {
  const EstefsariehSplashScreen({super.key});

  @override
  State<EstefsariehSplashScreen> createState() =>
      _EstefsariehSplashScreenState();
}

class _EstefsariehSplashScreenState
    extends State<EstefsariehSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EstefsariehHomeScreen(),
        ),
      );
    }
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
              Icons.description_outlined,
              size: 80,
              color: Color(0xFF00BFA5),
            ),
            const SizedBox(height: 24),
            const Text(
              'سیستم استفساریه رهپیمان',
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
                Color(0xFF00BFA5).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}