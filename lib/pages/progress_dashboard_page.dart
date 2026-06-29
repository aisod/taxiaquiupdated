import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../data/questions_data.dart';
import 'quiz_page.dart';
import 'character_creation_page.dart';
import 'profile_page.dart';
import 'landing_page.dart';
import 'home_page.dart';
import '../services/storage_service.dart';

class ProgressDashboardPage extends StatefulWidget {
  const ProgressDashboardPage({super.key});

  @override
  State<ProgressDashboardPage> createState() => _ProgressDashboardPageState();
}

class _ProgressDashboardPageState extends State<ProgressDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storageService = StorageService();
      final currentUser = await storageService.loadData('current_user');
      if (currentUser != null && currentUser.toString().isNotEmpty) {
        final gameService = context.read<GameService>();
        await gameService.loadUserProgress(currentUser.toString());
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        if (!gameService.hasPlayer) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final player = gameService.player!;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFE8E3FF),
                  const Color(0xFFF5F3FF),
                  colorScheme.surface,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center( // CENTRALIZAÇÃO DO CONTEÚDO
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800), // LIMITE DE 800PX
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            children: [
                              _buildHeader(context, theme, colorScheme),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildWelcomeCard(player, theme, colorScheme),
                                      const SizedBox(height: 32),
                                      _buildLearningModules(context, gameService, theme, colorScheme),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.home,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          Text(
            'SUPER-HERÓI TRIBUTÁRIO',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          GestureDetector(
            onTap: () => _showSettingsDialog(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.settings,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(player, ThemeData theme, ColorScheme colorScheme) {
    final currentLevelXp = player.xp % 1000;
    final xpProgress = currentLevelXp / 1000;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF06B6D4),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getAvatarIcon(player.avatarType),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Bem-vindo, ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Herói',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Fiscal!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Guardião dos Impostos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: const Color(0xFF06B6D4),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Nível ${player.level}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${player.xp} Pontos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],   
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: xpProgress,
              backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningModules(BuildContext context, GameService gameService, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos de Aprendizagem',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        
        const SizedBox(height: 20),
        // Novo Módulo Adicionado:
        _buildModuleCard(
                context,
          gameService,
          theme,
          colorScheme,
          moduleId: 3,
          title: 'Justinho e os Impostos',
          subtitle: 'Educação fiscal de forma lúdica e divertida',
          icon: Icons.auto_stories, // Ícone de livro/história
         // trailing: Image.asset(
            //'assets/images/JUSTINHO-2.png', // Use o nome exato do arquivo que você me enviou
            //width: 50,
           // height: 50,
           // fit: BoxFit.contain,
          //),
          iconColor: const Color(0xFFF59E0B),
          iconBackground: const Color(0xFFFEF3C7),
        ),
        const SizedBox(height: 20),
        _buildModuleCard(
          context,
          gameService,
          theme,
          colorScheme,
          moduleId: 1,
          title: 'Impostos Fiscais',
          subtitle: 'Aprenda sobre IVA, IRT, Imposto Predial e muito mais',
          icon: Icons.account_balance,
          iconColor: const Color(0xFF06B6D4),
          iconBackground: const Color(0xFFE0F2FE),
        ),
        const SizedBox(height: 20),
        _buildModuleCard(
          context,
          gameService,
          theme,
          colorScheme,
          moduleId: 2,
          title: 'Direitos Aduaneiros',
          subtitle: 'Explore importações, exportações e regimes especiais',
          icon: Icons.local_shipping,
          iconColor: const Color(0xFF8B5CF6),
          iconBackground: const Color(0xFFF3E8FF),
        ),
      
      ],
    );
  }
  
  Widget _buildModuleCard(
    BuildContext context,
    GameService gameService,
    ThemeData theme,
    ColorScheme colorScheme, {
    required int moduleId,
    required String title,
    required String subtitle,
    IconData? icon,
    Widget? trailing, // Novo parâmetro opcional
    required Color iconColor,
    required Color iconBackground,
  }) {
    final progress = gameService.getModuleProgress(moduleId);
    final progressPercent = (progress * 100).round();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(moduleId: moduleId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: iconColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAvatarIcon(String avatarType) {
    switch (avatarType) {
      case 'warrior':
        return Icons.shield;
      case 'mage':
        return Icons.auto_fix_high;
      case 'guardian':
        return Icons.security;
      case 'scholar':
        return Icons.school;
      default:
        return Icons.person;
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.settings,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Configurações',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: colorScheme.primary,
                ),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Sair da Conta',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fechar',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    Navigator.pop(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
              SizedBox(width: 12),
              Text('Confirmar Saída'),
            ],
          ),
          content: const Text(
            'Tem certeza que deseja sair da sua conta? Seu progresso será salvo.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      final gameService = context.read<GameService>();
      final storageService = StorageService();
      
      final currentUser = await storageService.loadData('current_user');
      if (currentUser != null) {
        await gameService.saveUserProgress(currentUser.toString());
      }
      
      await storageService.saveData('current_user', '');
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    }
  }
}