import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/game_service.dart';
import '../models/user/user.dart';
import '../models/game/game.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';
import '../widgets/gamezone_hero_header.dart';
import '../widgets/search_filter.dart';
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
  String _searchQuery = '';

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
              // Search Filter
              SliverToBoxAdapter(
                child: SearchFilter(
                  hintText: 'Filtrar meus jogos...',
                  onChanged: (query) => setState(() => _searchQuery = query),
                ),
              ),
              _buildGamesList(user.uid, userModel.name),
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
    return GameZoneHeroHeader(
      collapsedTitle: 'Meus Jogos',
      collapsedSubtitle: 'Sua biblioteca pessoal de jogos',
      expandedTagline: 'Sua biblioteca pessoal de jogos',
      expandedHeight: 180,
      trailing: StreamBuilder<List<GameModel>>(
        stream: widget.gameService.watchGamesByUser(userModel.uid),
        builder: (context, snapshot) {
          final count = snapshot.data?.length ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GameZoneSpacing.md,
              vertical: GameZoneSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: GameZoneColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(GameZoneRadius.full),
              border: Border.all(color: GameZoneColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.video_library_rounded, size: 14, color: GameZoneColors.primaryCyan),
                const SizedBox(width: GameZoneSpacing.xs),
                Text(
                  '$count jogo${count != 1 ? 's' : ''}',
                  style: GameZoneTypography.labelSmall.copyWith(
                    color: GameZoneColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGamesList(String uid, String ownerName) {
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

        final allGames = snapshot.data ?? [];

        if (allGames.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyGamesState(onCreateGame: _navigateToCreateGame),
          );
        }

        // Apply search filter
        final filteredGames = _searchQuery.isEmpty
            ? allGames
            : allGames.where((game) {
                final query = _searchQuery;
                return game.nome.toLowerCase().contains(query) ||
                       game.empresa.toLowerCase().contains(query);
              }).toList();

        if (filteredGames.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: GameZoneColors.textMuted,
                  ),
                  const SizedBox(height: GameZoneSpacing.md),
                  Text(
                    'Nenhum jogo encontrado',
                    style: GameZoneTypography.headlineSmall.copyWith(
                      color: GameZoneColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: GameZoneSpacing.xs),
                  Text(
                    'Tente ajustar sua busca',
                    style: GameZoneTypography.bodyMedium.copyWith(
                      color: GameZoneColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(GameZoneSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final game = filteredGames[index];
                return GameCard(
                  key: ValueKey(game.id),
                  game: game,
                  currentUserId: uid,
                  gameService: widget.gameService,
                  ownerName: ownerName,
                  onDeleted: () => setState(() => _retryKey++),
                  onUpdated: () => setState(() => _retryKey++),
                );
              },
              childCount: filteredGames.length,
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