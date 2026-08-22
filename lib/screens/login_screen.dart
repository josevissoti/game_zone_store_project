import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../utils/validators.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessSnackBar('Login realizado com sucesso!');
        }
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GameZoneTypography.bodyMedium),
        backgroundColor: GameZoneColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameZoneRadius.lg),
        ),
        margin: const EdgeInsets.all(GameZoneSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: GameZoneSpacing.lg,
          vertical: GameZoneSpacing.md,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameZoneColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: AuthCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthCardHeader(
                        title: 'Bem-vindo de volta',
                        subtitle: 'Entre na sua conta GameZone',
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      const SizedBox(height: GameZoneSpacing.xl),
                      AuthTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        hint: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 22,
                            color: GameZoneColors.textMuted,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
                      Row(
                        children: [
                          _buildRememberMe(),
                          const Spacer(),
                          _buildForgotPassword(),
                        ],
                      ),
                      const SizedBox(height: GameZoneSpacing.lg),
                      AuthButton(
                        text: 'Entrar',
                        onPressed: _login,
                        isLoading: _isLoading,
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: GameZoneSpacing.xl),
                      DividerWithText(text: 'ou continue com'),
                      const SizedBox(height: GameZoneSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: SocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: GameZoneSpacing.md),
                          Expanded(
                            child: SocialButton(
                              icon: Icons.apple_rounded,
                              label: 'Apple',
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GameZoneSpacing.xl),
                      AuthFooter(
                        text: 'Não tem uma conta?',
                        actionText: 'Cadastre-se',
                        onActionPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const RegisterScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: GameZoneAnimations.emphasized,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                              transitionDuration: GameZoneAnimations.page,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: AnimatedContainer(
            duration: GameZoneAnimations.fast,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GameZoneRadius.sm),
              gradient: _rememberMe ? GameZoneColors.primaryGradient : null,
              color: _rememberMe ? null : GameZoneColors.surface,
              border: Border.all(
                color: _rememberMe
                    ? Colors.transparent
                    : GameZoneColors.border,
                width: 1.5,
              ),
            ),
            child: _rememberMe
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: GameZoneColors.textOnPrimary,
                  )
                : null,
          ),
        ),
        const SizedBox(width: GameZoneSpacing.sm),
        Text(
          'Lembrar-me',
          style: GameZoneTypography.bodyMedium.copyWith(
            color: GameZoneColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => GameZoneColors.primaryGradient
            .createShader(bounds),
        child: Text(
          'Esqueceu a senha?',
          style: GameZoneTypography.labelMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -200,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.primaryCyan.withValues(alpha: 0.08),
                  GameZoneColors.primaryCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -200,
          left: -150,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.primaryPurple.withValues(alpha: 0.06),
                  GameZoneColors.primaryPurple.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: -80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.accentGold.withValues(alpha: 0.05),
                  GameZoneColors.accentGold.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}