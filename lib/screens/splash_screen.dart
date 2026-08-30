import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../utils/design_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particlesController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoGlow;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: GameZoneAnimations.page,
      vsync: this,
    );
    _textController = AnimationController(
      duration: GameZoneAnimations.slow,
      vsync: this,
    );
    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: GameZoneAnimations.decelerate),
    );
    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: GameZoneAnimations.decelerate),
    );
    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: GameZoneAnimations.standard),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: GameZoneAnimations.decelerate),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: GameZoneAnimations.page,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameZoneColors.background,
      body: Stack(
        children: [
          _buildBackgroundParticles(),
          _buildGradientOrbs(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _particlesController]),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _logoRotation.value * 0.1,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _buildLogo(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: GameZoneSpacing.xl),
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => GameZoneColors.primaryGradient
                                  .createShader(bounds),
                              child: Text(
                                'GAMEZONE',
                                style: GameZoneTypography.displayMedium.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                            const SizedBox(height: GameZoneSpacing.sm),
                            Text(
                              'Sua loja de jogos digitais',
                              style: GameZoneTypography.bodyMedium.copyWith(
                                color: GameZoneColors.textSecondary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: GameZoneSpacing.xxxl),
                _buildLoadingIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlesPainter(
            progress: _particlesController.value,
            color: GameZoneColors.primaryCyan.withValues(alpha: 0.03),
          ),
        );
      },
    );
  }

  Widget _buildGradientOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.primaryCyan.withValues(alpha: 0.15),
                  GameZoneColors.primaryCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.primaryPurple.withValues(alpha: 0.12),
                  GameZoneColors.primaryPurple.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.accentGold.withValues(alpha: 0.08),
                  GameZoneColors.accentGold.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _logoGlow,
          builder: (context, child) {
            return Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GameZoneColors.primaryCyan.withValues(alpha: 0.3 * _logoGlow.value),
                    GameZoneColors.primaryPurple.withValues(alpha: 0.15 * _logoGlow.value),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: GameZoneColors.cardGradient,
            border: Border.all(
              color: GameZoneColors.border,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GameZoneColors.primaryCyan.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/gamezone_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => GameZoneColors.primaryGradient
                        .createShader(bounds),
                    child: const Icon(
                      Icons.videogame_asset_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ]
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                GameZoneColors.primaryCyan.withValues(alpha: 0.3),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                GameZoneColors.primaryCyan,
              ),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: GameZoneColors.primaryGradient,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 30; i++) {
      final seed = (random + i * 17) % 10000 / 10000.0;
      final x = (seed * 1.61803398875 * size.width) % size.width;
      final y = ((seed * 2.61803398875 + progress) * size.height) % size.height;
      final radius = 1.0 + (seed * 2.5);
      final opacity = (0.3 + seed * 0.7) * (1 - (y / size.height) * 0.5);
      
      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}