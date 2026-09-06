import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';
import '../utils/snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<AuthTextFieldState>();
  final _phoneKey = GlobalKey<AuthTextFieldState>();
  final _emailKey = GlobalKey<AuthTextFieldState>();
  final _passwordKey = GlobalKey<AuthTextFieldState>();
  final _confirmPasswordKey = GlobalKey<AuthTextFieldState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate all AuthTextField widgets
    final nameValid = _nameKey.currentState?.validate() ?? false;
    final phoneValid = _phoneKey.currentState?.validate() ?? false;
    final emailValid = _emailKey.currentState?.validate() ?? false;
    final passwordValid = _passwordKey.currentState?.validate() ?? false;
    final confirmPasswordValid = _confirmPasswordKey.currentState?.validate() ?? false;
    
    if (!nameValid || !phoneValid || !emailValid || !passwordValid || !confirmPasswordValid) {
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text,
      );
      // Fazer logout automático para forçar login após cadastro
      await _authService.signOut();
      if (mounted) {
        showSnackBar(context, message: 'Conta criada com sucesso! Faça login para continuar.', type: SnackBarType.success);
        Navigator.pop(context); // Volta para LoginScreen
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showSnackBar(context, message: _authService.getAuthErrorMessage(e), type: SnackBarType.error);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showSnackBar(context, message: _userService.getFirestoreErrorMessage(e), type: SnackBarType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameZoneColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: GameZoneSpacing.lg,
                      vertical: GameZoneSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: AuthCard(
                          showTopAccent: false,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AuthCardHeader(
                                  title: 'Criar conta',
                                  subtitle: 'Preencha seus dados para começar',
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                  key: _nameKey,
                                  controller: _nameController,
                                  label: 'Nome completo',
                                  hint: 'João da Silva',
                                  prefixIcon: Icons.person_outline_rounded,
                                  textCapitalization: TextCapitalization.words,
                                  validator: Validators.validateName,
                                ),
                                const SizedBox(height: GameZoneSpacing.md),
                                AuthTextField(
                                  key: _phoneKey,
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
                                  key: _emailKey,
                                  controller: _emailController,
                                  label: 'E-mail',
                                  hint: 'seu@email.com',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.validateEmail,
                                ),
                                const SizedBox(height: GameZoneSpacing.md),
                                AuthTextField(
                                  key: _passwordKey,
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
                                  key: _confirmPasswordKey,
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
                                const SizedBox(height: GameZoneSpacing.lg),
                                AuthButton(
                                  text: 'Cadastrar',
                                  onPressed: _register,
                                  isLoading: _isLoading,
                                  icon: Icons.person_add_rounded,
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
                  );
                },
              ),
            ),
          ),
        ],
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