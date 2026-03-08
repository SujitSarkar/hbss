import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maori_health/core/theme/app_colors.dart';

abstract class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light);
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.light).textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
      shadowColor: const Color(0x1E000000),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: .w600, color: colorScheme.onPrimary),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        margin: .symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
        border: OutlineInputBorder(borderRadius: .circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const .symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: .w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(160),
        selectedLabelStyle: TextStyle(fontSize: 14, color: Colors.white, fontWeight: .w700),
        unselectedLabelStyle: TextStyle(fontSize: 14, color: Colors.white.withAlpha(160)),
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.white.withAlpha(160)),
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark);
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.dark).textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      cardColor: AppColors.cardDark,
      dividerColor: const Color(0xFF3A3A3A),
      shadowColor: const Color(0x33000000),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: .w600, color: colorScheme.onSurface),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 2,
        margin: .symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
        border: OutlineInputBorder(borderRadius: .circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const .symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: .w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppColors.cardDark),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(160),
        selectedLabelStyle: TextStyle(fontSize: 14, color: Colors.white, fontWeight: .w700),
        unselectedLabelStyle: TextStyle(fontSize: 14, color: Colors.white.withAlpha(160)),
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.white.withAlpha(160)),
        elevation: 0,
      ),
    );
  }
}
