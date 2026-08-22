import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/design_tokens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameZoneColors.background,
        colorScheme: const ColorScheme.dark(
          primary: GameZoneColors.primaryCyan,
          secondary: GameZoneColors.primaryPurple,
          surface: GameZoneColors.surface,
          onPrimary: GameZoneColors.textOnPrimary,
          onSecondary: GameZoneColors.textOnPrimary,
          onSurface: GameZoneColors.textPrimary,
          error: GameZoneColors.borderError,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: GameZoneColors.surface,
          labelStyle: GameZoneTypography.labelMedium.copyWith(
            color: GameZoneColors.textSecondary,
          ),
          hintStyle: GameZoneTypography.bodyMedium.copyWith(
            color: GameZoneColors.textMuted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            borderSide: BorderSide(color: GameZoneColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            borderSide: const BorderSide(color: GameZoneColors.borderFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            borderSide: const BorderSide(color: GameZoneColors.borderError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            borderSide: const BorderSide(color: GameZoneColors.borderError, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: GameZoneSpacing.md,
            vertical: GameZoneSpacing.md,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: GameZoneColors.primaryCyan,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: GameZoneColors.textPrimary,
            side: const BorderSide(color: GameZoneColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: GameZoneSpacing.lg,
              vertical: GameZoneSpacing.md,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: GameZoneColors.textPrimary),
          titleTextStyle: TextStyle(
            color: GameZoneColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: GameZoneColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.xl),
            side: const BorderSide(color: GameZoneColors.border),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: GameZoneColors.border,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: GameZoneColors.surfaceElevated,
          contentTextStyle: GameZoneTypography.bodyMedium,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GameZoneColors.primaryCyan;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(GameZoneColors.textOnPrimary),
          side: const BorderSide(color: GameZoneColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameZoneRadius.sm),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GameZoneColors.primaryCyan;
            }
            return GameZoneColors.border;
          }),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GameZoneColors.primaryCyan;
            }
            return GameZoneColors.textMuted;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GameZoneColors.primaryCyan.withValues(alpha: 0.5);
            }
            return GameZoneColors.border;
          }),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}