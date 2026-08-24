import 'package:flutter/material.dart';

import 'package:rahpeyman/features/home/presentation/screens/module_placeholder_screen.dart';
import 'package:rahpeyman/modules/engineering_assistant/screens/engineering_assistant_splash_screen.dart';
import 'package:rahpeyman/modules/listoferyar/presentation/screens/listoferyar_home_screen.dart';
import 'package:rahpeyman/modules/estefsarieh/screens/estefsarieh_splash_screen.dart';
import 'package:rahpeyman/modules/sharayet_omoomi_piman/screens/sharayet_splash_screen.dart';
import 'package:rahpeyman/features/courses/presentation/screens/courses_screen.dart';

class ModuleNavigator {
  static void navigateToModule(
    BuildContext context,
    String moduleId,
  ) {
    switch (moduleId) {
      case 'inquiries':
        _push(context, const EstefsariehSplashScreen());

      case 'general_conditions':
        _push(context, const SharayetSplashScreen());

      case 'engineering_assistant':
        _push(context, const EngineeringAssistantSplashScreen());

      case 'listoferyar':
        _push(context, const ListoferyarHomeScreen());

      case 'courses':
        _push(context, const CoursesScreen());
        break;
      case 'announcements':
      case 'about':
      case 'favorites':
        _push(
          context,
          ModulePlaceholderScreen(
            moduleId: moduleId,
            title: _moduleTitle(moduleId),
            subtitle: _moduleSubtitle(moduleId),
            icon: _moduleIcon(moduleId),
          ),
        );

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'این بخش در حال حاضر در دسترس نیست.',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
              ),
            ),
          ),
        );
    }
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  static String _moduleTitle(String id) {
    return switch (id) {
      'courses' => 'دوره‌های آموزشی',
      'listoferyar' => 'لیستوفر‌یار',
      'announcements' => 'اطلاعیه‌ها',
      'about' => 'درباره ما',
      'favorites' => 'علاقه‌مندی‌ها',
      _ => 'رهپیمان',
    };
  }

  static String _moduleSubtitle(String id) {
    return switch (id) {
      'courses' => 'آموزش از پایه تا اجرا',
      'listoferyar' => 'مدیریت و گزارش‌گیری متره و برآورد',
      'announcements' => 'جدیدترین اطلاعیه‌ها',
      'about' => 'معرفی رهپیمان',
      'favorites' => 'موارد ذخیره‌شده شما',
      _ => 'همراه مهندسین از آموزش تا اجرا',
    };
  }

  static IconData _moduleIcon(String id) {
    return switch (id) {
      'courses' => Icons.school_rounded,
      'listoferyar' => Icons.view_module_rounded,
      'announcements' => Icons.campaign_rounded,
      'about' => Icons.info_outline_rounded,
      'favorites' => Icons.favorite_rounded,
      _ => Icons.apps_rounded,
    };
  }
}
