import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/game_service.dart';
import 'utils/design_tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Single service instances for the entire app
  final authService = AuthService();
  final userService = UserService();
  final gameService = GameService();
  
  runApp(MyApp(
    authService: authService,
    userService: userService,
    gameService: gameService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final UserService userService;
  final GameService gameService;

  const MyApp({
    super.key,
    required this.authService,
    required this.userService,
    required this.gameService,
  });

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
      home: AuthWrapper(
        authService: authService,
        userService: userService,
        gameService: gameService,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final AuthService authService;
  final UserService userService;
  final GameService gameService;

  const AuthWrapper({
    super.key,
    required this.authService,
    required this.userService,
    required this.gameService,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Ensure splash screen shows for minimum 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: widget.authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return HomeScreen(
            authService: widget.authService,
            userService: widget.userService,
            gameService: widget.gameService,
          );
        }
        return LoginScreen(
          authService: widget.authService,
          userService: widget.userService,
        );
      },
    );
  }
}