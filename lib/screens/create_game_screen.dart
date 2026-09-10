import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../models/game/game.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../utils/design_tokens.dart';
import '../../utils/auth_widgets.dart';
import '../../utils/snackbar.dart';

class CreateGameScreen extends StatefulWidget {
  final GameService gameService;
  final AuthService authService;

  const CreateGameScreen({
    super.key,
    required this.gameService,
    required this.authService,
  });

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<AuthTextFieldState>();
  final _priceKey = GlobalKey<AuthTextFieldState>();
  final _dateKey = GlobalKey<AuthTextFieldState>();
  final _companyKey = GlobalKey<AuthTextFieldState>();
  final _genreKey = GlobalKey<AuthTextFieldState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _companyController = TextEditingController();
  final _genreController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _companyController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: GameZoneColors.primaryCyan,
              onPrimary: GameZoneColors.textOnPrimary,
              surface: GameZoneColors.surface,
              onSurface: GameZoneColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: GameZoneColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GameZoneRadius.xl),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormatter.format(picked);
      });
    }
  }

  Future<void> _createGame() async {
    final nameValid = _nameKey.currentState?.validate() ?? false;
    final priceValid = _priceKey.currentState?.validate() ?? false;
    final dateValid = _dateKey.currentState?.validate() ?? false;
    final companyValid = _companyKey.currentState?.validate() ?? false;
    final genreValid = _genreKey.currentState?.validate() ?? false;

    if (!nameValid || !priceValid || !dateValid || !companyValid || !genreValid) {
      return;
    }

    if (_selectedDate == null) {
      showSnackBar(context, message: 'Selecione a data de publicação', type: SnackBarType.error);
      return;
    }

    final user = widget.authService.currentUser;
    if (user == null) {
      showSnackBar(context, message: 'Usuário não autenticado', type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = CurrencyFormatter.parse(_priceController.text);

      final game = GameModel(
        id: '',
        nome: _nameController.text.trim(),
        preco: price,
        dataPublicacao: _selectedDate!,
        empresa: _companyController.text.trim(),
        genero: _genreController.text.trim(),
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: null,
      );

      await widget.gameService.createGame(game);

      if (mounted) {
        showSnackBar(
          context,
          message: 'Jogo "${game.nome}" cadastrado com sucesso!',
          type: SnackBarType.success,
        );
        Navigator.pop(context, true);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          message: widget.gameService.getFirestoreErrorMessage(e),
          type: SnackBarType.error,
        );
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
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: GameZoneColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: ShaderMask(
                    shaderCallback: (bounds) => GameZoneColors.primaryGradient.createShader(bounds),
                    child: Text(
                      'Novo Jogo',
                      style: GameZoneTypography.headlineMedium.copyWith(color: Colors.white),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(GameZoneSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: AuthCard(
                      showTopAccent: true,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthCardHeader(
                              title: 'Cadastrar Jogo',
                              subtitle: 'Preencha os dados para adicionar à sua biblioteca',
                            ),
                            const SizedBox(height: GameZoneSpacing.xl),
                            _buildNameField(),
                            const SizedBox(height: GameZoneSpacing.md),
                            _buildPriceField(),
                            const SizedBox(height: GameZoneSpacing.md),
                            _buildDateField(),
                            const SizedBox(height: GameZoneSpacing.md),
                            _buildCompanyField(),
                            const SizedBox(height: GameZoneSpacing.md),
                            _buildGenreField(),
                            const SizedBox(height: GameZoneSpacing.xl),
                            AuthButton(
                              text: _isLoading ? 'Cadastrando...' : 'Cadastrar Jogo',
                              onPressed: _isLoading ? null : _createGame,
                              isLoading: _isLoading,
                              icon: Icons.add_rounded,
                            ),
                            const SizedBox(height: GameZoneSpacing.lg),
                            _buildHintSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return AuthTextField(
      key: _nameKey,
      controller: _nameController,
      label: 'Nome do Jogo',
      hint: 'Ex: Elden Ring',
      prefixIcon: Icons.videogame_asset_rounded,
      textCapitalization: TextCapitalization.words,
      validator: Validators.validateGameName,
    );
  }

  Widget _buildPriceField() {
    return AuthTextField(
      key: _priceKey,
      controller: _priceController,
      label: 'Preço',
      hint: 'R\$ 0,00',
      prefixIcon: Icons.attach_money_rounded,
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyFormatter()],
      validator: Validators.validatePrice,
    );
  }

  Widget _buildDateField() {
    return AuthTextField(
      key: _dateKey,
      controller: _dateController,
      label: 'Data de Publicação',
      hint: 'dd/mm/aaaa',
      prefixIcon: Icons.calendar_today_rounded,
      readOnly: true,
      onTap: _pickDate,
      validator: Validators.validateReleaseDate,
      suffixIcon: IconButton(
        icon: const Icon(Icons.date_range_rounded, color: GameZoneColors.textMuted, size: 22),
        onPressed: _pickDate,
      ),
    );
  }

  Widget _buildCompanyField() {
    return AuthTextField(
      key: _companyKey,
      controller: _companyController,
      label: 'Empresa/Desenvolvedora',
      hint: 'Ex: FromSoftware',
      prefixIcon: Icons.business_rounded,
      textCapitalization: TextCapitalization.words,
      validator: Validators.validateCompany,
    );
  }

  Widget _buildGenreField() {
    return AuthTextField(
      key: _genreKey,
      controller: _genreController,
      label: 'Gênero',
      hint: 'Ex: RPG de Ação',
      prefixIcon: Icons.category_rounded,
      textCapitalization: TextCapitalization.words,
      validator: Validators.validateGenre,
    );
  }

  Widget _buildHintSection() {
    return Container(
      padding: const EdgeInsets.all(GameZoneSpacing.md),
      decoration: BoxDecoration(
        color: GameZoneColors.primaryCyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(GameZoneRadius.lg),
        border: Border.all(color: GameZoneColors.primaryCyan.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: GameZoneColors.primaryCyan),
              const SizedBox(width: GameZoneSpacing.sm),
              Text(
                'Dicas',
                style: GameZoneTypography.labelMedium.copyWith(color: GameZoneColors.primaryCyan),
              ),
            ],
          ),
          const SizedBox(height: GameZoneSpacing.sm),
          Text(
            '• O preço é formatado automaticamente (R\$ 199,90)\n'
            '• A data pode ser futura para jogos em pré-venda\n'
            '• Apenas você poderá editar ou excluir este jogo',
            style: GameZoneTypography.bodySmall.copyWith(
              color: GameZoneColors.textSecondary,
              height: 1.6,
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
          top: -150,
          right: -80,
          child: Container(
            width: 350,
            height: 350,
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
          bottom: -200,
          left: -120,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.primaryPurple.withValues(alpha: 0.05),
                  GameZoneColors.primaryPurple.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          left: -60,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GameZoneColors.accentCoral.withValues(alpha: 0.04),
                  GameZoneColors.accentCoral.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}