import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        _showErrorSnackBar('Você deve aceitar os termos de uso');
        return;
      }
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessSnackBar('Conta criada com sucesso!');
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: GameZoneAnimations.normal,
            ),
          );
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GameZoneTypography.bodyMedium),
        backgroundColor: GameZoneColors.borderError.withValues(alpha: 0.2),
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
                        title: 'Criar conta',
                        subtitle: 'Preencha seus dados para começar',
                        crossAxisAlignment: CrossAxisAlignment.start,
                        action: IconButton(
                          icon: const Icon(Icons.close_rounded, color: GameZoneColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            backgroundColor: GameZoneColors.surface,
                            padding: const EdgeInsets.all(GameZoneSpacing.sm),
                          ),
                        ),
                      ),
                      const SizedBox(height: GameZoneSpacing.xl),
                      AuthTextField(
                        controller: _nameController,
                        label: 'Nome completo',
                        hint: 'João da Silva',
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
                      AuthTextField(
                        controller: _phoneController,
                        label: 'Telefone',
                        hint: '(11) 99999-9999',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [PhoneFormatter()],
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
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
                        hint: 'Mín. 8 caracteres',
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
                        onChanged: (_) => _confirmPasswordController.clear(),
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar senha',
                        hint: 'Digite novamente',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 22,
                            color: GameZoneColors.textMuted,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (value) => Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
                      _buildTermsCheckbox(),
                      const SizedBox(height: GameZoneSpacing.lg),
                      AuthButton(
                        text: 'Cadastrar',
                        onPressed: _register,
                        isLoading: _isLoading,
                        icon: Icons.person_add_rounded,
                      ),
                      const SizedBox(height: GameZoneSpacing.xl),
                      DividerWithText(text: 'ou cadastre-se com'),
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
                        text: 'Já tem uma conta?',
                        actionText: 'Faça login',
                        onActionPressed: () => Navigator.pop(context),
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

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
          child: AnimatedContainer(
            duration: GameZoneAnimations.fast,
            margin: const EdgeInsets.only(top: 2),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GameZoneRadius.sm),
              gradient: _acceptTerms ? GameZoneColors.primaryGradient : null,
              color: _acceptTerms ? null : GameZoneColors.surface,
              border: Border.all(
                color: _acceptTerms
                    ? Colors.transparent
                    : GameZoneColors.border,
                width: 1.5,
              ),
            ),
            child: _acceptTerms
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: GameZoneColors.textOnPrimary,
                  )
                : null,
          ),
        ),
        const SizedBox(width: GameZoneSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GameZoneTypography.bodySmall.copyWith(
                color: GameZoneColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Concordo com os '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: ShaderMask(
                      shaderCallback: (bounds) => GameZoneColors.primaryGradient
                          .createShader(bounds),
                      child: Text(
                        'Termos de Uso',
                        style: GameZoneTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' e a '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: ShaderMask(
                      shaderCallback: (bounds) => GameZoneColors.primaryGradient
                          .createShader(bounds),
                      child: Text(
                        'Política de Privacidade',
                        style: GameZoneTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                  GameZoneColors.primaryPurple.withValues(alpha: 0.08),
                  GameZoneColors.primaryPurple.withValues(alpha: 0.0),
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
                  GameZoneColors.primaryCyan.withValues(alpha: 0.06),
                  GameZoneColors.primaryCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: -60,
          child: Container(
            width: 160,
            height: 160,
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