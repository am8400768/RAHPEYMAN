import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rahpeyman/core/theme/app_theme.dart';
import 'package:rahpeyman/modules/home/home_placeholder_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    _timer = Timer(
      const Duration(milliseconds: 2600),
      _goNext,
    );
  }

  void _goNext() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const HomePlaceholderScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.14),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'RP',
                          style: TextStyle(
                          fontFamily: 'ETHNOCEN',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'RAHPEYMAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ETHNOCEN',
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'رهپیمان',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Dima.Sogand.New',
                        fontSize: 30,
                        height: 1.5,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppTheme.slogan,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Dima.Sogand.New',
                        fontSize: 18,
                        height: 1.8,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 42),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'در حال آماده‌سازی...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryLight,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
