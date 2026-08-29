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

class HomeTab extends StatelessWidget {
  final UserService userService;
  final AuthService authService;

  const HomeTab({
    super.key,
    required this.userService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return StreamBuilder<UserModel>(
      stream: userService.watchUserOrCreate(
        uid: user.uid,
        name: user.displayName ?? 'Usuário',
        phone: '',
        email: user.email ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: GameZoneColors.primaryCyan),
          );
        }

        final userName = snapshot.data?.name ?? 'Usuário';
        final firstName = userName.split(' ').first;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
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
                      'Olá, $firstName! 👋',
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
                background: Container(
                  decoration: BoxDecoration(
                    gradient: GameZoneColors.primaryGradient,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(GameZoneSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionTitle('Em destaque'),
                  const SizedBox(height: GameZoneSpacing.md),
                  _buildPlaceholderCard('Jogo em destaque 1', 'Ação'),
                  const SizedBox(height: GameZoneSpacing.md),
                  _buildPlaceholderCard('Jogo em destaque 2', 'RPG'),
                  const SizedBox(height: GameZoneSpacing.xl),
                  _buildSectionTitle('Novidades'),
                  const SizedBox(height: GameZoneSpacing.md),
                  _buildPlaceholderCard('Lançamento recente', 'Aventura'),
                  const SizedBox(height: GameZoneSpacing.md),
                  _buildPlaceholderCard('Atualização disponível', 'Estratégia'),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GameZoneTypography.headlineMedium.copyWith(
        color: GameZoneColors.textPrimary,
      ),
    );
  }

  Widget _buildPlaceholderCard(String title, String genre) {
    return Container(
      height: 180,
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
                    colors: [
                      GameZoneColors.primaryCyan.withValues(alpha: 0.1),
                      GameZoneColors.primaryPurple.withValues(alpha: 0.1),
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
                    color: GameZoneColors.primaryCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(GameZoneRadius.full),
                  ),
                  child: Text(
                    genre,
                    style: GameZoneTypography.labelSmall.copyWith(
                      color: GameZoneColors.primaryCyan,
                    ),
                  ),
                ),
                const SizedBox(height: GameZoneSpacing.sm),
                Text(
                  title,
                  style: GameZoneTypography.headlineMedium.copyWith(
                    color: GameZoneColors.textPrimary,
                  ),
                ),
                const SizedBox(height: GameZoneSpacing.xs),
                Text(
                  'Em breve na GameZone',
                  style: GameZoneTypography.bodySmall.copyWith(
                    color: GameZoneColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    // Obter dados do usuário do Firebase Auth para criar perfil se necessário
    final displayName = user.displayName ?? '';
    final email = user.email ?? '';
    // Phone não está disponível no Firebase Auth User, usar placeholder
    final phone = '';

    return StreamBuilder<UserModel>(
      stream: widget.userService.watchUserOrCreate(
        uid: user.uid,
        name: displayName.isNotEmpty ? displayName : 'Usuário',
        phone: phone,
        email: email,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        final userModel = snapshot.data;

        if (userModel == null) {
          return const Center(
            child: Text('Perfil não encontrado'),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: GameZoneColors.surface,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: GameZoneColors.primaryGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
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
                  _buildInfoCard(userModel),
                  const SizedBox(height: GameZoneSpacing.lg),
                  _buildActionButtons(context),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(GameZoneSpacing.lg),
      decoration: BoxDecoration(
        gradient: GameZoneColors.cardGradient,
        borderRadius: BorderRadius.circular(GameZoneRadius.xl),
        border: Border.all(color: GameZoneColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Nome',
            value: user.name,
          ),
          const SizedBox(height: GameZoneSpacing.md),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'E-mail',
            value: user.email,
          ),
          const SizedBox(height: GameZoneSpacing.md),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Telefone',
            value: user.phone,
          ),
          if (user.createdAt != null) ...[
            const SizedBox(height: GameZoneSpacing.md),
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Membro desde',
              value: _formatDate(user.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: GameZoneColors.primaryCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
          ),
          child: Icon(
            icon,
            color: GameZoneColors.primaryCyan,
            size: 22,
          ),
        ),
        const SizedBox(width: GameZoneSpacing.md),
        Expanded(
          child: Column(
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        AuthButton(
          text: 'Editar Perfil',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(
                userService: widget.userService,
                authService: widget.authService,
              ),
            ),
          ),
          icon: Icons.edit_rounded,
        ),
        const SizedBox(height: GameZoneSpacing.md),
        AuthButton(
          text: 'Sair',
          onPressed: () async {
            await widget.authService.signOut();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          },
          isSecondary: true,
          icon: Icons.logout_rounded,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}