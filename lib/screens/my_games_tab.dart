import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/game_service.dart';
import '../models/user/user.dart';
import '../models/game/game.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';
import 'create_game_screen.dart';
import 'game_card_widget.dart';

class MyGamesTab extends StatefulWidget {
  final UserService userService;
  final AuthService authService;
  final GameService gameService;

  const MyGamesTab({
    super.key,
    required this.userService,
    required this.authService,
    required this.gameService,
  });

  @override
  State<MyGamesTab> createState() => _MyGamesTabState();
}

class _MyGamesTabState extends State<MyGamesTab> {
  int _retryKey = 0;
  UserModel? _initialUserModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialUser();
  }

  Future<void> _loadInitialUser() async {
    final user = widget.authService.currentUser;
    if (user == null) return;

    try {
      final userModel = await widget.userService.getUserOrCreate(
        uid: user.uid,
        name: user.displayName ?? 'Usuário',
        phone: '',
        email: user.email ?? '',
      );
      if (mounted) {
        setState(() {
          _initialUserModel = userModel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToCreateGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateGameScreen(
          gameService: widget.gameService,
          authService: widget.authService,
        ),
      ),
    ).then((created) {
      if (created == true) {
        setState(() => _retryKey++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: GameZoneColors.primaryCyan),
      );
    }

    return StreamBuilder<UserModel>(
      stream: widget.userService.watchUser(user.uid),
      initialData: _initialUserModel,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting &&
            _initialUserModel == null) {
          return const Center(
            child: CircularProgressIndicator(color: GameZoneColors.primaryCyan),
          );
        }

        if (userSnapshot.hasError) {
          return Center(
            key: ValueKey(_retryKey),
            child: _buildErrorState(
              'Erro ao carregar perfil',
              userSnapshot.error.toString(),
              () => setState(() => _retryKey++),
            ),
          );
        }

        final userModel = userSnapshot.data ?? _initialUserModel;

        if (userModel == null) {
          return const Center(child: Text('Perfil não encontrado'));
        }

        return Scaffold(
          backgroundColor: GameZoneColors.background,
          floatingActionButton: _buildFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: CustomScrollView(
            slivers: [
              _buildHeroSection(userModel),
              _buildGamesList(user.uid),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreateGame,
      backgroundColor: GameZoneColors.primaryCyan,
      foregroundColor: GameZoneColors.textOnPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameZoneRadius.xl),
      ),
      icon: const Icon(Icons.add_rounded, size: 24),
      label: Text(
        'Novo Jogo',
        style: GameZoneTypography.labelLarge.copyWith(
          color: GameZoneColors.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      extendedPadding: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg),
    );
  }

  Widget _buildHeroSection(UserModel userModel) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: GameZoneColors.surface,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: GameZoneSpacing.lg, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meus Jogos',
              style: GameZoneTypography.displaySmall.copyWith(
                color: GameZoneColors.textPrimary,
              ),
            ),
            Text(
              'Sua biblioteca pessoal de jogos',
              style: GameZoneTypography.bodyMedium.copyWith(
                color: GameZoneColors.textSecondary,
              ),
            ),
          ],
        ),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: GameZoneColors.primaryGradient,
              ),
            ),
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      GameZoneColors.accentCoral.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      GameZoneColors.primaryCyan.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: GameZoneSpacing.lg,
              right: GameZoneSpacing.lg,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GameZoneSpacing.md,
                  vertical: GameZoneSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: GameZoneColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(GameZoneRadius.full),
                  border: Border.all(color: GameZoneColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_library_rounded, size: 16, color: GameZoneColors.primaryCyan),
                    const SizedBox(width: GameZoneSpacing.xs),
                    StreamBuilder<List<GameModel>>(
                      stream: widget.gameService.watchGamesByUser(userModel.uid),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Text(
                          '$count jogo${count != 1 ? 's' : ''}',
                          style: GameZoneTypography.labelMedium.copyWith(
                            color: GameZoneColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesList(String uid) {
    return StreamBuilder<List<GameModel>>(
      stream: widget.gameService.watchGamesByUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: GameZoneColors.primaryCyan),
                  const SizedBox(height: GameZoneSpacing.md),
                  Text(
                    'Carregando sua biblioteca...',
                    style: GameZoneTypography.bodyMedium.copyWith(
                      color: GameZoneColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              key: ValueKey(_retryKey),
              child: _buildErrorState(
                'Erro ao carregar jogos',
                snapshot.error.toString(),
                () => setState(() => _retryKey++),
              ),
            ),
          );
        }

        final games = snapshot.data ?? [];

        if (games.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyGamesState(onCreateGame: _navigateToCreateGame),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(GameZoneSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final game = games[index];
                return GameCard(
                  key: ValueKey(game.id),
                  game: game,
                  currentUserId: uid,
                  gameService: widget.gameService,
                  onDeleted: () => setState(() => _retryKey++),
                  onUpdated: () => setState(() => _retryKey++),
                );
              },
              childCount: games.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String title, String error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(GameZoneSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: GameZoneColors.borderError,
          ),
          const SizedBox(height: GameZoneSpacing.md),
          Text(
            title,
            style: GameZoneTypography.headlineSmall.copyWith(
              color: GameZoneColors.textPrimary,
            ),
          ),
          const SizedBox(height: GameZoneSpacing.sm),
          Text(
            error,
            style: GameZoneTypography.bodyMedium.copyWith(
              color: GameZoneColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GameZoneSpacing.lg),
          AuthButton(
            text: 'Tentar novamente',
            onPressed: onRetry,
            icon: Icons.refresh_rounded,
            width: 200,
          ),
        ],
      ),
    );
  }
}