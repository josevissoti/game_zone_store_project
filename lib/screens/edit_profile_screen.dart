import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user/user.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';
import '../utils/snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserService userService;
  final AuthService authService;

  const EditProfileScreen({
    super.key,
    required this.userService,
    required this.authService,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<AuthTextFieldState>();
  final _phoneKey = GlobalKey<AuthTextFieldState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = widget.authService.currentUser;
    if (user != null) {
      final userModel = await widget.userService.getUserOrCreate(
        uid: user.uid,
        name: user.displayName ?? 'Usuário',
        phone: '',
        email: user.email ?? '',
      );
      if (mounted) {
        setState(() {
          _currentUser = userModel;
          _nameController.text = userModel.name;
          _phoneController.text = userModel.phone;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Validate all AuthTextField widgets
    final nameValid = _nameKey.currentState?.validate() ?? false;
    final phoneValid = _phoneKey.currentState?.validate() ?? false;
    
    if (!nameValid || !phoneValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = widget.authService.currentUser;
      if (user != null) {
        await widget.userService.updateUser(
          user.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text,
        );
        if (mounted) {
          showSnackBar(context, message: 'Perfil atualizado com sucesso!', type: SnackBarType.success);
          Navigator.pop(context);
        }
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showSnackBar(context, message: widget.userService.getFirestoreErrorMessage(e), type: SnackBarType.error);
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
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: GameZoneColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _currentUser == null
          ? const Center(
              child: CircularProgressIndicator(color: GameZoneColors.primaryCyan),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(GameZoneSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: GameZoneColors.primaryCyan.withValues(alpha: 0.2),
                          child: Text(
                            _currentUser!.name.isNotEmpty
                                ? _currentUser!.name[0].toUpperCase()
                                : '?',
                            style: GameZoneTypography.displayMedium.copyWith(
                              color: GameZoneColors.primaryCyan,
                            ),
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
                      const SizedBox(height: GameZoneSpacing.xl),
                      AuthButton(
                        text: 'Salvar Alterações',
                        onPressed: _saveProfile,
                        isLoading: _isLoading,
                        icon: Icons.save_rounded,
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
                      AuthButton(
                        text: 'Cancelar',
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        isSecondary: true,
                        icon: Icons.close_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}