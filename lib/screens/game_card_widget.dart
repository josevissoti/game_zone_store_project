import 'package:flutter/material.dart';
import '../../models/game/game.dart';
import '../../services/game_service.dart';
import '../../services/user_service.dart';
import '../../utils/design_tokens.dart';
import '../../utils/formatters.dart';
import '../../utils/snackbar.dart';
import '../../utils/auth_widgets.dart';
import '../../widgets/owner_name_resolver.dart';
import 'edit_game_screen.dart';

typedef OnGameDeleted = void Function();
typedef OnGameUpdated = void Function();

class GameCard extends StatefulWidget {
  final GameModel game;
  final String currentUserId;
  final GameService gameService;
  final String? ownerName;
  final OnGameDeleted? onDeleted;
  final OnGameUpdated? onUpdated;

  const GameCard({
    super.key,
    required this.game,
    required this.currentUserId,
    required this.gameService,
    this.ownerName,
    this.onDeleted,
    this.onUpdated,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isDeleting = false;

  bool get _isOwner => widget.game.createdBy == widget.currentUserId;

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameZoneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(GameZoneSpacing.sm),
              decoration: BoxDecoration(
                color: GameZoneColors.borderError.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(GameZoneRadius.lg),
              ),
              child: Icon(Icons.warning_amber_rounded, color: GameZoneColors.borderError, size: 24),
            ),
            const SizedBox(width: GameZoneSpacing.md),
            Expanded(
              child: Text(
                'Excluir Jogo',
                style: GameZoneTypography.headlineSmall.copyWith(
                  color: GameZoneColors.borderError,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir "${widget.game.nome}"?',
              style: GameZoneTypography.bodyMedium.copyWith(
                color: GameZoneColors.textPrimary,
              ),
            ),
            const SizedBox(height: GameZoneSpacing.md),
            Container(
              padding: const EdgeInsets.all(GameZoneSpacing.md),
              decoration: BoxDecoration(
                color: GameZoneColors.borderError.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(GameZoneRadius.lg),
                border: Border.all(color: GameZoneColors.borderError.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: GameZoneColors.borderError),
                  const SizedBox(width: GameZoneSpacing.sm),
                  Expanded(
                    child: Text(
                      'Esta ação é irreversível. O jogo será removido permanentemente.',
                      style: GameZoneTypography.bodySmall.copyWith(
                        color: GameZoneColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            text: _isDeleting ? 'Excluindo...' : 'Excluir',
            onPressed: _isDeleting ? null : () => Navigator.pop(context, true),
            isLoading: _isDeleting,
            isCoral: true,
            width: 120,
            icon: Icons.delete_forever_rounded,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteGame();
    }
  }

  Future<void> _deleteGame() async {
    setState(() => _isDeleting = true);

    try {
      await widget.gameService.deleteGame(widget.game.id);
      if (mounted) {
        showSnackBar(
          context,
          message: 'Jogo "${widget.game.nome}" excluído com sucesso!',
          type: SnackBarType.success,
        );
        widget.onDeleted?.call();
      }
    } on Exception catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          message: 'Erro ao excluir: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _navigateToEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditGameScreen(
          game: widget.game,
          gameService: widget.gameService,
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        widget.onUpdated?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: GameZoneSpacing.md),
      decoration: BoxDecoration(
        gradient: GameZoneColors.cardGradient,
        borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        border: Border.all(color: GameZoneColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GameZoneRadius.xl),
          onTap: _isOwner ? _navigateToEdit : null,
          child: Padding(
            padding: const EdgeInsets.all(GameZoneSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: GameZoneSpacing.md),
                _buildInfoRows(),
                if (_isOwner) ...[
                  const SizedBox(height: GameZoneSpacing.md),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: GameZoneColors.primaryGradient,
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
          ),
          child: const Icon(
            Icons.videogame_asset_rounded,
            color: GameZoneColors.textOnPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: GameZoneSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.game.nome,
                style: GameZoneTypography.titleLarge.copyWith(
                  color: GameZoneColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GameZoneSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: GameZoneColors.accentCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(GameZoneRadius.full),
                    ),
                    child: Text(
                      widget.game.genero,
                      style: GameZoneTypography.labelSmall.copyWith(
                        color: GameZoneColors.accentCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_isOwner) ...[
                    const SizedBox(width: GameZoneSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GameZoneSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: GameZoneColors.primaryCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(GameZoneRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 10,
                            color: GameZoneColors.primaryCyan,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.ownerName ?? 'Você',
                            style: GameZoneTypography.labelSmall.copyWith(
                              color: GameZoneColors.primaryCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRows() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.attach_money_rounded,
          label: 'Preço',
          value: CurrencyFormatter.format(widget.game.preco),
          color: GameZoneColors.accentGreen,
        ),
        const SizedBox(height: GameZoneSpacing.sm),
        _buildInfoRow(
          icon: Icons.calendar_today_rounded,
          label: 'Publicação',
          value: DateFormatter.format(widget.game.dataPublicacao),
          color: GameZoneColors.primaryCyan,
        ),
        const SizedBox(height: GameZoneSpacing.sm),
        _buildInfoRow(
          icon: Icons.business_rounded,
          label: 'Empresa',
          value: widget.game.empresa,
          color: GameZoneColors.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(GameZoneRadius.md),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: GameZoneSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GameZoneTypography.labelSmall.copyWith(
                color: GameZoneColors.textMuted,
              ),
            ),
            Text(
              value,
              style: GameZoneTypography.bodyMedium.copyWith(
                color: GameZoneColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(
              'Editar',
              style: GameZoneTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: GameZoneColors.primaryCyan,
              side: const BorderSide(color: GameZoneColors.primaryCyan, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: GameZoneSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GameZoneRadius.lg),
              ),
            ),
          ),
        ),
        const SizedBox(width: GameZoneSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isDeleting ? null : _showDeleteConfirmation,
            icon: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: GameZoneColors.borderError),
                  )
                : const Icon(Icons.delete_rounded, size: 18),
            label: Text(
              _isDeleting ? 'Excluindo...' : 'Excluir',
              style: GameZoneTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: GameZoneColors.borderError,
              side: BorderSide(
                color: _isDeleting
                    ? GameZoneColors.borderError.withValues(alpha: 0.5)
                    : GameZoneColors.borderError,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: GameZoneSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GameZoneRadius.lg),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EmptyGamesState extends StatelessWidget {
  final VoidCallback onCreateGame;

  const EmptyGamesState({super.key, required this.onCreateGame});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameZoneSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: GameZoneColors.primaryGradient,
              ),
              child: const Icon(
                Icons.videogame_asset_rounded,
                size: 70,
                color: GameZoneColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: GameZoneSpacing.xl),
            Text(
              'Nenhum jogo cadastrado',
              style: GameZoneTypography.headlineMedium.copyWith(
                color: GameZoneColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GameZoneSpacing.md),
            Text(
              'Comece sua biblioteca adicionando\no primeiro jogo agora mesmo!',
              style: GameZoneTypography.bodyMedium.copyWith(
                color: GameZoneColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GameZoneSpacing.xl),
            AuthButton(
              text: 'Cadastrar Primeiro Jogo',
              onPressed: onCreateGame,
              icon: Icons.add_rounded,
              width: 280,
            ),
          ],
        ),
      ),
    );
  }
}

class GameStoreCard extends StatelessWidget {
  final GameModel game;
  final String ownerUid;
  final UserService userService;
  final VoidCallback onBuy;

  const GameStoreCard({
    super.key,
    required this.game,
    required this.ownerUid,
    required this.userService,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: GameZoneColors.cardGradient,
        borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        border: Border.all(color: GameZoneColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(GameZoneSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: GameZoneSpacing.md),
              _buildInfoRows(),
              const SizedBox(height: GameZoneSpacing.md),
              _buildBuyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: GameZoneColors.primaryGradient,
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
          ),
          child: const Icon(
            Icons.videogame_asset_rounded,
            color: GameZoneColors.textOnPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: GameZoneSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.nome,
                style: GameZoneTypography.titleLarge.copyWith(
                  color: GameZoneColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GameZoneSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: GameZoneColors.accentCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(GameZoneRadius.full),
                    ),
                    child: Text(
                      game.genero,
                      style: GameZoneTypography.labelSmall.copyWith(
                        color: GameZoneColors.accentCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: GameZoneSpacing.sm),
                  OwnerNameChip(
                    uid: ownerUid,
                    userService: userService,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRows() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.attach_money_rounded,
          label: 'Preço',
          value: CurrencyFormatter.format(game.preco),
          color: GameZoneColors.accentGreen,
        ),
        const SizedBox(height: GameZoneSpacing.sm),
        _buildInfoRow(
          icon: Icons.calendar_today_rounded,
          label: 'Publicação',
          value: DateFormatter.format(game.dataPublicacao),
          color: GameZoneColors.primaryCyan,
        ),
        const SizedBox(height: GameZoneSpacing.sm),
        _buildInfoRow(
          icon: Icons.business_rounded,
          label: 'Empresa',
          value: game.empresa,
          color: GameZoneColors.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(GameZoneRadius.md),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: GameZoneSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GameZoneTypography.labelSmall.copyWith(
                color: GameZoneColors.textMuted,
              ),
            ),
            Text(
              value,
              style: GameZoneTypography.bodyMedium.copyWith(
                color: GameZoneColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity,
      child: AuthButton(
        text: 'Comprar',
        onPressed: onBuy,
        icon: Icons.shopping_cart_rounded,
      ),
    );
  }
}