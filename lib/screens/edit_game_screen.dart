import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/game_service.dart';
import '../../models/game/game.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../utils/design_tokens.dart';
import '../../utils/auth_widgets.dart';
import '../../utils/snackbar.dart';

class EditGameScreen extends StatefulWidget {
  final GameModel game;
  final GameService gameService;

  const EditGameScreen({
    super.key,
    required this.game,
    required this.gameService,
  });

  @override
  State<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.game.nome;
    _priceController.text = CurrencyFormatter.format(widget.game.preco);
    _selectedDate = widget.game.dataPublicacao;
    _dateController.text = DateFormatter.format(widget.game.dataPublicacao);
    _companyController.text = widget.game.empresa;
    _genreController.text = widget.game.genero;

    _nameController.addListener(_onChange);
    _priceController.addListener(_onChange);
    _dateController.addListener(_onChange);
    _companyController.addListener(_onChange);
    _genreController.addListener(_onChange);
  }

  void _onChange() {
    if (!_hasChanges && mounted) {
      setState(() => _hasChanges = true);
    }
  }

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

  Future<void> _showConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameZoneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        ),
        title: Text(
          'Confirmar Alteração',
          style: GameZoneTypography.headlineSmall.copyWith(
            color: GameZoneColors.primaryCyan,
          ),
        ),
        content: Text(
          'Tem certeza que deseja alterar "${widget.game.nome}"?\n\n'
          'As alterações serão salvas imediatamente.',
          style: GameZoneTypography.bodyMedium.copyWith(
            color: GameZoneColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: ShaderMask(
              shaderCallback: (bounds) => GameZoneColors.primaryGradient.createShader(bounds),
              child: Text(
                'Cancelar',
                style: GameZoneTypography.titleMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
          AuthButton(
            text: 'Confirmar',
            onPressed: () => Navigator.pop(context, true),
            isCoral: false,
            width: 120,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _updateGame();
    }
  }

  Future<void> _updateGame() async {
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

    setState(() => _isLoading = true);

    try {
      final price = CurrencyFormatter.parse(_priceController.text);

      await widget.gameService.updateGame(widget.game.id, {
        'nome': _nameController.text.trim(),
        'preco': price,
        'dataPublicacao': _selectedDate!.millisecondsSinceEpoch,
        'empresa': _companyController.text.trim(),
        'genero': _genreController.text.trim(),
      });

      if (mounted) {
        showSnackBar(
          context,
          message: 'Jogo atualizado com sucesso!',
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
                      'Editar Jogo',
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
                              title: 'Editar "${widget.game.nome}"',
                              subtitle: 'Altere os dados desejados',
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
                              text: _isLoading ? 'Salvando...' : 'Salvar Alterações',
                              onPressed: (_hasChanges && !_isLoading) ? _showConfirmationDialog : null,
                              isLoading: _isLoading,
                              icon: Icons.save_rounded,
                            ),
                            if (!_hasChanges) ...[
                              const SizedBox(height: GameZoneSpacing.md),
                              Center(
                                child: Text(
                                  'Nenhuma alteração detectada',
                                  style: GameZoneTypography.bodySmall.copyWith(
                                    color: GameZoneColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
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
                'Informações',
                style: GameZoneTypography.labelMedium.copyWith(color: GameZoneColors.primaryCyan),
              ),
            ],
          ),
          const SizedBox(height: GameZoneSpacing.sm),
          Text(
            '• Apenas o criador pode editar este jogo\n'
            '• Confirmação necessária antes de salvar\n'
            '• Preço e data formatados automaticamente',
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