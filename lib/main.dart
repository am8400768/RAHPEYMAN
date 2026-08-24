import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rahpeyman/core/theme/app_theme.dart';
import 'package:rahpeyman/modules/startup/startup_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const RahpeymanApp());
}

class RahpeymanApp extends StatelessWidget {
  const RahpeymanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StartupScreen(),
    );
  }
}
