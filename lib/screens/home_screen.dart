import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/game_service.dart';
import '../models/user/user.dart';
import '../models/game/game.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';
import '../utils/snackbar.dart';
import '../utils/formatters.dart';
import 'edit_profile_screen.dart';
import 'my_games_tab.dart';
import 'game_card_widget.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final UserService userService;
  final GameService gameService;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.userService,
    required this.gameService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(
        userService: widget.userService,
        authService: widget.authService,
        gameService: widget.gameService,
      ),
      MyGamesTab(
        userService: widget.userService,
        authService: widget.authService,
        gameService: widget.gameService,
      ),
      ProfileTab(userService: widget.userService, authService: widget.authService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameZoneColors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: GameZoneColors.surface,
        indicatorColor: GameZoneColors.primaryCyan.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded, color: GameZoneColors.primaryCyan),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_rounded),
            selectedIcon: Icon(Icons.video_library_rounded, color: GameZoneColors.primaryCyan),
            label: 'Meus Jogos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: GameZoneColors.primaryCyan),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final UserService userService;
  final AuthService authService;
  final GameService gameService;

  const HomeTab({
    super.key,
    required this.userService,
    required this.authService,
    required this.gameService,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  UserModel? _initialUserModel;
  bool _isLoading = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Scroll listener kept for potential future use (e.g., scroll-based animations)
    // No setState needed - avoids rebuild on every scroll event
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

        final userName = userSnapshot.data?.name ?? _initialUserModel?.name ?? 'Usuário';
        final firstName = userName.split(' ').first;

        return StreamBuilder<List<GameModel>>(
          stream: widget.gameService.watchAllGames(),
          builder: (context, gamesSnapshot) {
            if (gamesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: GameZoneColors.primaryCyan),
              );
            }

            if (gamesSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: GameZoneColors.borderError,
                    ),
                    const SizedBox(height: GameZoneSpacing.md),
                    Text(
                      'Erro ao carregar jogos',
                      style: GameZoneTypography.headlineSmall.copyWith(
                        color: GameZoneColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GameZoneSpacing.sm),
                    Text(
                      gamesSnapshot.error.toString(),
                      style: GameZoneTypography.bodyMedium.copyWith(
                        color: GameZoneColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final games = gamesSnapshot.data ?? [];

            if (games.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(GameZoneSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: GameZoneColors.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.videogame_asset_rounded,
                          size: 60,
                          color: GameZoneColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: GameZoneSpacing.xl),
                      Text(
                        'Nenhum jogo disponível',
                        style: GameZoneTypography.headlineMedium.copyWith(
                          color: GameZoneColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: GameZoneSpacing.md),
                      Text(
                        'Seja o primeiro a cadastrar um jogo!',
                        style: GameZoneTypography.bodyMedium.copyWith(
                          color: GameZoneColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return HomeTabContent(
              games: games,
              firstName: firstName,
              scrollController: _scrollController,
              onBuy: _showBuyDialog,
            );
          },
        );
      },
    );
  }

  void _showBuyDialog(BuildContext context, GameModel game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameZoneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        ),
        title: Text(
          'Comprar Jogo',
          style: GameZoneTypography.headlineSmall.copyWith(
            color: GameZoneColors.primaryCyan,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja comprar "${game.nome}"?',
              style: GameZoneTypography.bodyMedium.copyWith(
                color: GameZoneColors.textPrimary,
              ),
            ),
            const SizedBox(height: GameZoneSpacing.sm),
            Text(
              'Preço: ${CurrencyFormatter.format(game.preco)}',
              style: GameZoneTypography.bodyLarge.copyWith(
                color: GameZoneColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement purchase logic
              showSnackBar(
                context,
                message: 'Compra de "${game.nome}" iniciada!',
                type: SnackBarType.success,
              );
            },
            isCoral: false,
            width: 120,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}

class HomeTabContent extends StatelessWidget {
  final List<GameModel> games;
  final String firstName;
  final ScrollController scrollController;
  final void Function(BuildContext, GameModel) onBuy;

  const HomeTabContent({
    super.key,
    required this.games,
    required this.firstName,
    required this.scrollController,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Hero Section
        SliverAppBar(
          expandedHeight: 160,
          floating: false,
          pinned: true,
          backgroundColor: GameZoneColors.surface,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: GameZoneSpacing.lg, bottom: 16),
            title: Text(
              'Olá, $firstName!',
              style: GameZoneTypography.displaySmall.copyWith(
                color: GameZoneColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: GameZoneColors.primaryGradient,
              ),
              child: Positioned(
                left: GameZoneSpacing.lg,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $firstName!',
                      style: GameZoneTypography.displaySmall.copyWith(
                        color: GameZoneColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      'Descubra os melhores jogos',
                      style: GameZoneTypography.bodyMedium.copyWith(
                        color: GameZoneColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: GameZoneSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Todos os Jogos',
                          style: GameZoneTypography.headlineMedium.copyWith(
                            color: GameZoneColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Catálogo completo da GameZone',
                          style: GameZoneTypography.bodyMedium.copyWith(
                            color: GameZoneColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: GameZoneSpacing.md),
              ],
            ),
          ),
        ),
        // Games List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final game = games[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: GameZoneSpacing.md),
                  child: GameStoreCard(
                    key: ValueKey(game.id),
                    game: game,
                    ownerName: 'Usuário',
                    onBuy: () => onBuy(context, game),
                  ),
                );
              },
              childCount: games.length,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileTab extends StatefulWidget {
  final UserService userService;
  final AuthService authService;

  const ProfileTab({
    super.key,
    required this.userService,
    required this.authService,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
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

    final displayName = user.displayName ?? '';
    final email = user.email ?? '';
    final phone = '';

    try {
      final userModel = await widget.userService.getUserOrCreate(
        uid: user.uid,
        name: displayName.isNotEmpty ? displayName : 'Usuário',
        phone: phone,
        email: email,
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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _initialUserModel == null) {
          return const Center(
            child: CircularProgressIndicator(color: GameZoneColors.primaryCyan),
          );
        }

        if (snapshot.hasError) {
          return Center(
            key: ValueKey(_retryKey),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: GameZoneColors.borderError,
                ),
                const SizedBox(height: GameZoneSpacing.md),
                Text(
                  'Erro ao carregar perfil',
                  style: GameZoneTypography.headlineSmall.copyWith(
                    color: GameZoneColors.textPrimary,
                  ),
                ),
                const SizedBox(height: GameZoneSpacing.sm),
                Text(
                  snapshot.error.toString(),
                  style: GameZoneTypography.bodyMedium.copyWith(
                    color: GameZoneColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: GameZoneSpacing.lg),
                AuthButton(
                  text: 'Tentar novamente',
                  onPressed: () => setState(() => _retryKey++),
                  icon: Icons.refresh_rounded,
                  width: 200,
                ),
              ],
            ),
          );
        }

        final userModel = snapshot.data ?? _initialUserModel;

        if (userModel == null) {
          return const Center(
            child: Text('Perfil não encontrado'),
          );
        }

        return CustomScrollView(
          slivers: [
            // Profile Header
            SliverAppBar(
              expandedHeight: 230,
              floating: false,
              pinned: true,
              backgroundColor: GameZoneColors.surface,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: GameZoneColors.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: GameZoneSpacing.md),
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: GameZoneColors.surface,
                          child: Text(
                            userModel.name.isNotEmpty
                                ? userModel.name[0].toUpperCase()
                                : '?',
                            style: GameZoneTypography.displayMedium.copyWith(
                              color: GameZoneColors.primaryCyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: GameZoneSpacing.md),
                        Text(
                          userModel.name,
                          style: GameZoneTypography.displaySmall.copyWith(
                            color: GameZoneColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(height: GameZoneSpacing.xs),
                        Text(
                          userModel.email,
                          style: GameZoneTypography.bodyMedium.copyWith(
                            color: GameZoneColors.textOnPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(GameZoneSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Account Settings Section
                  _buildSettingsSection(
                    title: 'Configurações da Conta',
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Nome',
                        subtitle: userModel.name,
                        onTap: () => _navigateToEditProfile(),
                      ),
                      _SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'E-mail',
                        subtitle: userModel.email,
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.phone_outlined,
                        title: 'Telefone',
                        subtitle: userModel.phone.isNotEmpty ? userModel.phone : 'Não cadastrado',
                        onTap: () => _navigateToEditProfile(),
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Alterar Senha',
                        subtitle: 'Atualizar senha de acesso',
                        onTap: () => _showChangePasswordDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: GameZoneSpacing.xl),
                  // Danger Zone
                  _buildSettingsSection(
                    title: 'Zona de Perigo',
                    isDestructive: true,
                    children: [
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Excluir Conta',
                        subtitle: 'Remover permanentemente seus dados',
                        isDestructive: true,
                        onTap: () => _showDeleteAccountDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: GameZoneSpacing.xxxl),
                  // Sign Out Button
                  AuthButton(
                    text: 'Sair da Conta',
                    onPressed: () async {
                      await widget.authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    },
                    isSecondary: true,
                    icon: Icons.logout_rounded,
                  ),
                  const SizedBox(height: GameZoneSpacing.xxxl),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          userService: widget.userService,
          authService: widget.authService,
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameZoneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        ),
        title: Text(
          'Alterar Senha',
          style: GameZoneTypography.headlineSmall,
        ),
        content: Text(
          'Esta funcionalidade será implementada em breve. Por enquanto, use a opção "Esqueceu a senha?" na tela de login.',
          style: GameZoneTypography.bodyMedium.copyWith(
            color: GameZoneColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ShaderMask(
              shaderCallback: (bounds) => GameZoneColors.primaryGradient
                  .createShader(bounds),
              child: Text(
                'Entendido',
                style: GameZoneTypography.titleMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameZoneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        ),
        title: Text(
          'Excluir Conta',
          style: GameZoneTypography.headlineSmall.copyWith(
            color: GameZoneColors.borderError,
          ),
        ),
        content: Text(
          'Esta ação é irreversível. Todos os seus dados, jogos e progresso serão permanentemente removidos. Tem certeza?',
          style: GameZoneTypography.bodyMedium.copyWith(
            color: GameZoneColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ShaderMask(
              shaderCallback: (bounds) => GameZoneColors.primaryGradient
                  .createShader(bounds),
              child: Text(
                'Cancelar',
                style: GameZoneTypography.titleMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          AuthButton(
            text: 'Excluir',
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog();
            },
            isCoral: true,
            width: 120,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameZoneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        ),
        title: Text(
          'Confirmação Final',
          style: GameZoneTypography.headlineSmall.copyWith(
            color: GameZoneColors.borderError,
          ),
        ),
        content: Text(
          'Digite "EXCLUIR" para confirmar a exclusão permanente da sua conta.',
          style: GameZoneTypography.bodyMedium.copyWith(
            color: GameZoneColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ShaderMask(
              shaderCallback: (bounds) => GameZoneColors.primaryGradient
                  .createShader(bounds),
              child: Text(
                'Cancelar',
                style: GameZoneTypography.titleMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
    bool isDestructive = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GameZoneTypography.labelLarge.copyWith(
            color: isDestructive ? GameZoneColors.borderError : GameZoneColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: GameZoneSpacing.sm),
        Container(
          decoration: BoxDecoration(
            gradient: GameZoneColors.cardGradient,
            borderRadius: BorderRadius.circular(GameZoneRadius.xl),
            border: Border.all(
              color: isDestructive ? GameZoneColors.borderError.withValues(alpha: 0.3) : GameZoneColors.border,
            ),
          ),
          child: Column(
            children: children.map((child) => child).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameZoneRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(GameZoneSpacing.md),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: GameZoneColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: GameZoneColors.primaryCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GameZoneRadius.lg),
                ),
                child: Icon(
                  icon,
                  color: GameZoneColors.primaryCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: GameZoneSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GameZoneTypography.bodyMedium.copyWith(
                        color: GameZoneColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GameZoneTypography.bodySmall.copyWith(
                        color: GameZoneColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: GameZoneSpacing.md),
                Icon(
                  Icons.chevron_right_rounded,
                  color: GameZoneColors.textMuted,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}