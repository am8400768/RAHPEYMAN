import 'package:flutter/material.dart';

import 'listoferyar_colors.dart';
import 'listoferyar_typography.dart';

abstract final class ListoferyarTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: ListoferyarColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: ListoferyarColors.primary,
      onPrimary: Colors.white,
      primaryContainer: ListoferyarColors.surfaceBlue,
      onPrimaryContainer: ListoferyarColors.textDark,
      secondary: ListoferyarColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: ListoferyarColors.surfaceTeal,
      onSecondaryContainer: ListoferyarColors.textDark,
      surface: ListoferyarColors.surface,
      onSurface: ListoferyarColors.textPrimary,
      surfaceContainerHighest: ListoferyarColors.surfaceSoft,
      outline: ListoferyarColors.border,
      outlineVariant: ListoferyarColors.borderSoft,
      error: ListoferyarColors.danger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: ListoferyarColors.background,
      fontFamily: ListoferyarTypography.secondary,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: ListoferyarColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: ListoferyarTypography.heading,
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 23,
        ),
      ),
      cardTheme: CardThemeData(
        color: ListoferyarColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: ListoferyarColors.borderSoft,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ListoferyarColors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: ListoferyarColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: ListoferyarColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: ListoferyarColors.accent,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: ListoferyarColors.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: ListoferyarColors.danger,
            width: 1.5,
          ),
        ),
        hintStyle: ListoferyarTypography.helper,
        labelStyle: ListoferyarTypography.bodyText,
        floatingLabelStyle: ListoferyarTypography.bodyStrong.copyWith(
          color: ListoferyarColors.primary,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: ListoferyarColors.accent,
        selectionColor: ListoferyarColors.selection,
        selectionHandleColor: ListoferyarColors.accent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ListoferyarColors.accent,
          foregroundColor: Colors.white,
          elevation: 2,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontFamily: ListoferyarTypography.heading,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ListoferyarColors.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          side: const BorderSide(
            color: ListoferyarColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontFamily: ListoferyarTypography.heading,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ListoferyarColors.primary,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(
            fontFamily: ListoferyarTypography.heading,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ListoferyarColors.primary,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ListoferyarColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ListoferyarColors.surfaceSoft,
        disabledColor: ListoferyarColors.surfaceSoft,
        selectedColor: ListoferyarColors.surfaceTeal,
        secondarySelectedColor: ListoferyarColors.surfaceTeal,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        labelStyle: ListoferyarTypography.chip,
        secondaryLabelStyle: ListoferyarTypography.chip,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(
            color: ListoferyarColors.borderSoft,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ListoferyarColors.textDark,
        contentTextStyle: const TextStyle(
          fontFamily: ListoferyarTypography.body,
          fontSize: 12,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }

  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x140D47A1),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: Color(0x0D0D47A1),
    blurRadius: 10,
    offset: Offset(0, 3),
  );

  static BoxDecoration surfaceCard({
    Color color = ListoferyarColors.surface,
    double radius = 18,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: ListoferyarColors.borderSoft,
      ),
      boxShadow: const <BoxShadow>[
        softShadow,
      ],
    );
  }

  static BoxDecoration activeCard({
    double radius = 18,
  }) {
    return BoxDecoration(
      color: ListoferyarColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: ListoferyarColors.accent.withValues(alpha: 0.35),
      ),
      boxShadow: const <BoxShadow>[
        softShadow,
      ],
    );
  }
}
