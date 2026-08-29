import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user/user.dart';
import '../utils/design_tokens.dart';
import '../utils/auth_widgets.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _userService = UserService();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(userService: _userService, authService: _authService),
      const StoreTab(),
      ProfileTab(userService: _userService, authService: _authService),
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
            icon: Icon(Icons.store_rounded),
            selectedIcon: Icon(Icons.store_rounded, color: GameZoneColors.primaryCyan),
            label: 'Loja',
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

  const HomeTab({
    super.key,
    required this.userService,
    required this.authService,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  UserModel? _initialUserModel;
  bool _isLoading = true;
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

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
    if (_scrollController.hasClients) {
      setState(() => _scrollOffset = _scrollController.offset);
    }
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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _initialUserModel == null) {
          return const Center(
            child: CircularProgressIndicator(color: GameZoneColors.primaryCyan),
          );
        }

        final userName = snapshot.data?.name ?? _initialUserModel?.name ?? 'Usuário';
        final firstName = userName.split(' ').first;

        return CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Hero Section with Parallax
            SliverAppBar(
              expandedHeight: 160,
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
                      'Olá, $firstName!',
                      style: GameZoneTypography.displaySmall.copyWith(
                        color: GameZoneColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Descubra os melhores jogos',
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
                    // Parallax gradient orb
                    Positioned(
                      top: -80 + (_scrollOffset * 0.15),
                      right: -60,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              GameZoneColors.primaryCyan.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100 + (_scrollOffset * 0.1),
                      left: -80,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              GameZoneColors.primaryPurple.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: GameZoneSpacing.xl),
                  // Continue Playing Section
                  _buildSection(
                    title: 'Continue Jogando',
                    subtitle: 'Retome onde parou',
                    child: _buildHorizontalGameList(_mockContinuePlayingGames()),
                  ),
                  const SizedBox(height: GameZoneSpacing.xl),
                  // Featured Section
                  _buildSection(
                    title: 'Em Destaque',
                    subtitle: 'Escolhas da semana',
                    child: _buildHorizontalGameList(_mockFeaturedGames(), isFeatured: true),
                  ),
                  const SizedBox(height: GameZoneSpacing.xl),
                  // New Releases Section
                  _buildSection(
                    title: 'Novidades',
                    subtitle: 'Lançamentos recentes',
                    child: _buildNewReleasesGrid(_mockNewReleasesGames()),
                  ),
                  const SizedBox(height: GameZoneSpacing.xl),
                  // Trending Section
                  _buildSection(
                    title: 'Em Alta',
                    subtitle: 'Mais jogados agora',
                    child: _buildHorizontalGameList(_mockTrendingGames()),
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

  // Mock data for demonstration
  List<_GameItem> _mockContinuePlayingGames() => [
    _GameItem('Elden Ring', 'RPG de Ação', 'assets/images/elden_ring.jpg', 0.65),
    _GameItem('Cyberpunk 2077', 'RPG', 'assets/images/cyberpunk.jpg', 0.42),
    _GameItem('The Witcher 3', 'RPG de Ação', 'assets/images/witcher3.jpg', 0.78),
  ];

  List<_GameItem> _mockFeaturedGames() => [
    _GameItem('Baldur\'s Gate 3', 'RPG', 'assets/images/bg3.jpg', 0.0),
    _GameItem('Alan Wake 2', 'Terror Psicológico', 'assets/images/alan_wake2.jpg', 0.0),
    _GameItem('Hogwarts Legacy', 'RPG de Ação', 'assets/images/hogwarts.jpg', 0.0),
  ];

  List<_GameItem> _mockNewReleasesGames() => [
    _GameItem('Starfield', 'RPG Espacial', 'assets/images/starfield.jpg', 0.0),
    _GameItem('Lies of P', 'Soulslike', 'assets/images/lies_of_p.jpg', 0.0),
    _GameItem('Remnant 2', 'Tiro em Terceira Pessoa', 'assets/images/remnant2.jpg', 0.0),
    _GameItem('Armored Core VI', 'Mecha Action', 'assets/images/armored_core.jpg', 0.0),
    _GameItem('Sea of Stars', 'RPG por Turnos', 'assets/images/sea_of_stars.jpg', 0.0),
    _GameItem('Dave the Diver', 'Aventura/Pesca', 'assets/images/dave_diver.jpg', 0.0),
  ];

  List<_GameItem> _mockTrendingGames() => [
    _GameItem('Counter-Strike 2', 'FPS Competitivo', 'assets/images/cs2.jpg', 0.0),
    _GameItem('Dota 2', 'MOBA', 'assets/images/dota2.jpg', 0.0),
    _GameItem('Apex Legends', 'Battle Royale', 'assets/images/apex.jpg', 0.0),
    _GameItem('Valorant', 'FPS Tático', 'assets/images/valorant.jpg', 0.0),
  ];

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GameZoneTypography.headlineMedium.copyWith(
                    color: GameZoneColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GameZoneTypography.bodySmall.copyWith(
                    color: GameZoneColors.textMuted,
                  ),
                ),
              ],
            ),
            TextButton(
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
                  'Ver todos',
                  style: GameZoneTypography.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: GameZoneSpacing.md),
        child,
      ],
    );
  }

  Widget _buildHorizontalGameList(List<_GameItem> games, {bool isFeatured = false}) {
    return SizedBox(
      height: isFeatured ? 240 : 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: GameZoneSpacing.md),
        itemBuilder: (context, index) {
          return _buildGameCard(games[index], isFeatured: isFeatured);
        },
      ),
    );
  }

  Widget _buildNewReleasesGrid(List<_GameItem> games) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: GameZoneSpacing.md,
        mainAxisSpacing: GameZoneSpacing.md,
        childAspectRatio: 0.7,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return _buildGameCard(games[index], isGrid: true);
      },
    );
  }

  Widget _buildGameCard(_GameItem game, {bool isFeatured = false, bool isGrid = false}) {
    final width = isFeatured ? 280.0 : (isGrid ? null : 200.0);
    final height = isFeatured ? 240.0 : (isGrid ? null : 180.0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: GameZoneColors.cardGradient,
        borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        border: Border.all(color: GameZoneColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GameZoneRadius.xl),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      GameZoneColors.primaryCyan.withValues(alpha: 0.08),
                      GameZoneColors.primaryPurple.withValues(alpha: 0.12),
                      GameZoneColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(GameZoneSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GameZoneSpacing.md,
                    vertical: GameZoneSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: GameZoneColors.accentCoral.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(GameZoneRadius.full),
                  ),
                  child: Text(
                    game.genre,
                    style: GameZoneTypography.labelSmall.copyWith(
                      color: GameZoneColors.accentCoral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: GameZoneSpacing.sm),
                Text(
                  game.title,
                  style: GameZoneTypography.headlineSmall.copyWith(
                    color: GameZoneColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (game.progress > 0) ...[
                  const SizedBox(height: GameZoneSpacing.sm),
                  _buildProgressBar(game.progress),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: GameZoneTypography.labelSmall.copyWith(
                color: GameZoneColors.textMuted,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GameZoneTypography.labelSmall.copyWith(
                color: GameZoneColors.accentCoral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: GameZoneSpacing.xs),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: GameZoneColors.border,
            borderRadius: BorderRadius.circular(GameZoneRadius.full),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: GameZoneColors.coralGradient,
                borderRadius: BorderRadius.circular(GameZoneRadius.full),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GameItem {
  final String title;
  final String genre;
  final String imagePath;
  final double progress;

  const _GameItem(this.title, this.genre, this.imagePath, this.progress);
}

class StoreTab extends StatelessWidget {
  const StoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Loja'),
          backgroundColor: GameZoneColors.surface,
          surfaceTintColor: Colors.transparent,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(GameZoneSpacing.lg),
          sliver: SliverFillRemaining(
            child: Center(
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
                      Icons.store_rounded,
                      size: 60,
                      color: GameZoneColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: GameZoneSpacing.xl),
                  Text(
                    'Loja GameZone',
                    style: GameZoneTypography.displaySmall.copyWith(
                      color: GameZoneColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: GameZoneSpacing.md),
                  Text(
                    'Em breve: catálogo completo de jogos\ndigitais com preços imperdíveis!',
                    style: GameZoneTypography.bodyMedium.copyWith(
                      color: GameZoneColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: GameZoneSpacing.xl),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GameZoneSpacing.xl,
                      vertical: GameZoneSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      gradient: GameZoneColors.goldGradient,
                      borderRadius: BorderRadius.circular(GameZoneRadius.full),
                    ),
                    child: Text(
                      'Notifique-me quando abrir',
                      style: GameZoneTypography.titleMedium.copyWith(
                        color: GameZoneColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
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
                        const SizedBox(height: GameZoneSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GameZoneSpacing.md,
                            vertical: GameZoneSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: GameZoneColors.accentGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(GameZoneRadius.full),
                            border: Border.all(
                              color: GameZoneColors.accentGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: GameZoneColors.accentGreen,
                              ),
                              const SizedBox(width: GameZoneSpacing.xs),
                              Text(
                                'E-mail verificado',
                                style: GameZoneTypography.labelSmall.copyWith(
                                  color: GameZoneColors.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                        trailing: _VerifiedBadge(),
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
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
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
              if (trailing != null) ...[
                const SizedBox(width: GameZoneSpacing.md),
                trailing!,
              ] else if (onTap != null) ...[
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

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GameZoneSpacing.sm,
        vertical: GameZoneSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: GameZoneColors.accentGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(GameZoneRadius.full),
        border: Border.all(
          color: GameZoneColors.accentGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 12,
            color: GameZoneColors.accentGreen,
          ),
          const SizedBox(width: GameZoneSpacing.xs),
          Text(
            'Verificado',
            style: GameZoneTypography.labelSmall.copyWith(
              color: GameZoneColors.accentGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}