import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import '../models/game_state.dart';
import '../data/questions_data.dart';
import '../widgets/rpg_ui_components.dart';
import '../theme.dart';
import 'landing_page.dart';
import 'progress_dashboard_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storageService = StorageService();
  String? _currentUsername;
  Map<String, dynamic>? _userProgress;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load current user
      final currentUser = await _storageService.loadData('current_user');
      if (currentUser != null) {
        _currentUsername = currentUser.toString();
        // Load user progress
        final progress = await _storageService.loadData('user_progress_$_currentUsername');
        if (progress != null) {
          _userProgress = Map<String, dynamic>.from(progress);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GameService>(
            builder: (context, gameService, child) {
              final player = gameService.player!;
              
              return Column(
                children: [
                  // Header
                  _buildHeader(context, theme, colorScheme),
                  
                  // Profile Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        // User Account Info
                        _buildUserAccountCard(context, theme, colorScheme),
                        
                        const SizedBox(height: 16),
                        
                        // Player Info Card
                        _buildPlayerInfoCard(context, theme, colorScheme, player),
                        
                        const SizedBox(height: 16),
                        
                        // Progress Cards
                        _buildProgressCards(context, theme, colorScheme, gameService),
                        
                        const SizedBox(height: 16),
                        
                        // Achievements Section
                        _buildAchievementsSection(context, theme, colorScheme, gameService),
                        
                        const SizedBox(height: 16),
                        
                        // Statistics Section
                        _buildStatisticsSection(context, theme, colorScheme, gameService),
                        
                        const SizedBox(height: 32),
                        
                        // Logout Button
                        _buildLogoutButton(context, theme, colorScheme),
                        
                        const SizedBox(height: 16),
                        
                        // Reset Button
                        _buildResetButton(context, theme, colorScheme, gameService),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: colorScheme.primary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Perfil do Herói',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_currentUsername != null && !_isLoadingUserData) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Usuário: $_currentUsername',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPlayerInfoCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Player player,
  ) {
    return RPGCard(
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              RPGAvatar(
                avatarType: player.avatarType,
                size: 80,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: Text(
                        player.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPlayerClass(player.avatarType),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // XP Bar
          XPBar(
            currentXP: player.xp,
            maxXP: (player.level * 500), // 500 XP per level
            level: player.level,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    GameService gameService,
  ) {
    final module1Progress = gameService.getModuleProgress(1);
    final module2Progress = gameService.getModuleProgress(2);

    return Row(
      children: [
        Expanded(
          child: RPGCard(
            child: Column(
              children: [
                Text(
                  '💰',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Impostos Fiscais',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(module1Progress * 100).toInt()}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: module1Progress,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(colorScheme.secondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: RPGCard(
            child: Column(
              children: [
                Text(
                  '🚢',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Direitos Aduaneiros',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(module2Progress * 100).toInt()}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: module2Progress,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(colorScheme.tertiary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    GameService gameService,
  ) {
    final unlockedAchievements = gameService.achievements.where((a) => a.unlocked).toList();
    final totalAchievements = gameService.achievements.length;

    return RPGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: colorScheme.tertiary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Conquistas',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                ),
                child: Text(
                  '${unlockedAchievements.length}/$totalAchievements',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Achievements Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: gameService.achievements.length,
            itemBuilder: (context, index) {
              final achievement = gameService.achievements[index];
              return GestureDetector(
                onTap: () => _showAchievementDialog(context, achievement),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: achievement.unlocked 
                        ? colorScheme.tertiary.withValues(alpha: 0.1)
                        : colorScheme.outline.withValues(alpha: 0.1),
                    border: Border.all(
                      color: achievement.unlocked 
                          ? colorScheme.tertiary
                          : colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        achievement.icon,
                        style: TextStyle(
                          fontSize: 24,
                          color: achievement.unlocked ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.title,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: achievement.unlocked 
                              ? colorScheme.onSurface
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    GameService gameService,
  ) {
    final player = gameService.player!;
    final totalQuestions = QuestionsData.allQuestions.length;
    final completedQuestions = player.completedQuestions.length;
    final completionRate = totalQuestions > 0 ? (completedQuestions / totalQuestions) : 0.0;

    return RPGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Estatísticas',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  theme,
                  colorScheme,
                  '📊',
                  'Nível Atual',
                  '${player.level}',
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  theme,
                  colorScheme,
                  '⭐',
                  'XP Total',
                  '${player.xp}',
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  theme,
                  colorScheme,
                  '✅',
                  'Questões Respondidas',
                  '$completedQuestions/$totalQuestions',
                  colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  theme,
                  colorScheme,
                  '🎯',
                  'Taxa de Conclusão',
                  '${(completionRate * 100).toInt()}%',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    GameService gameService,
  ) {
    return SizedBox(
      width: double.infinity,
      child: RPGButton(
        onPressed: () => _showResetDialog(context, gameService),
        color: colorScheme.error,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 8),
            Text('Reiniciar Progresso', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String _getPlayerClass(String avatarType) {
    switch (avatarType) {
      case 'warrior':
        return 'Guerreiro Fiscal - Especialista em combater a evasão fiscal';
      case 'mage':
        return 'Mago dos Impostos - Mestre em cálculos e fórmulas fiscais';
      case 'guardian':
        return 'Guardião Aduaneiro - Protetor das fronteiras comerciais';
      case 'scholar':
        return 'Sábio da AGT - Conhecedor das leis e regulamentos';
      default:
        return 'Herói Fiscal';
    }
  }

  void _showAchievementDialog(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => RPGDialog(
        title: achievement.title,
        content: achievement.description,
        child: Column(
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.description,
              style: TextStyle(color: AppTheme.lightTextColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          RPGButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAccountCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_isLoadingUserData) {
      return RPGCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Text(
                'Carregando informações da conta...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentUsername == null || _userProgress == null) {
      return RPGCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Não foi possível carregar as informações da conta',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Parse dates
    DateTime? createdAt;
    DateTime? lastPlayed;
    try {
      if (_userProgress!['created_at'] != null) {
        createdAt = DateTime.parse(_userProgress!['created_at']);
      }
      if (_userProgress!['last_played'] != null) {
        lastPlayed = DateTime.parse(_userProgress!['last_played']);
      }
    } catch (e) {
      print('Error parsing dates: $e');
    }

    return RPGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Informações da Conta',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildAccountInfoItem(
                  context,
                  theme,
                  colorScheme,
                  '👤',
                  'Usuário',
                  _currentUsername!,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccountInfoItem(
                  context,
                  theme,
                  colorScheme,
                  '🆔',
                  'Nível da Conta',
                  '${_userProgress!['current_level'] ?? 1}',
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildAccountInfoItem(
                  context,
                  theme,
                  colorScheme,
                  '📅',
                  'Conta Criada',
                  createdAt != null 
                      ? _formatDate(createdAt)
                      : 'Data não disponível',
                  colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccountInfoItem(
                  context,
                  theme,
                  colorScheme,
                  '🕐',
                  'Última Sessão',
                  lastPlayed != null 
                      ? _formatDate(lastPlayed)
                      : 'Não disponível',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 semana atrás' : '$weeks semanas atrás';
    } else {
      return '${date.day}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: RPGButton(
        onPressed: () => _showLogoutDialog(context),
        color: colorScheme.secondary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white),
            const SizedBox(width: 8),
            Text('Sair da Conta', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RPGDialog(
        title: 'Sair da Conta',
        content: 'Tem certeza de que deseja sair da sua conta?',
        child: Column(
          children: [
            Icon(
              Icons.logout,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Você será redirecionado para a tela de login. Seu progresso será mantido seguro.',
              style: TextStyle(color: AppTheme.lightTextColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RPGButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RPGButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () async {
                    Navigator.pop(context);
                    await _logout();
                  },
                  child: const Text('Sair', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Clear current user from storage
      final prefs = await _storageService.loadData('current_user');
      if (prefs != null) {
        // You might want to update last_played timestamp before logout
        if (_currentUsername != null) {
          final currentProgress = await _storageService.loadData('user_progress_$_currentUsername');
          if (currentProgress != null) {
            final updatedProgress = Map<String, dynamic>.from(currentProgress);
            updatedProgress['last_played'] = DateTime.now().toIso8601String();
            await _storageService.saveData('user_progress_$_currentUsername', updatedProgress);
          }
        }
      }
      
      // Navigate to login page
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair da conta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResetDialog(BuildContext context, GameService gameService) {
    showDialog(
      context: context,
      builder: (context) => RPGDialog(
        title: 'Reiniciar Progresso',
        content: 'Tem certeza de que deseja reiniciar todo o seu progresso? Esta ação não pode ser desfeita.',
        child: Column(
          children: [
            Icon(
              Icons.warning,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Tem certeza de que deseja reiniciar todo o seu progresso? Esta ação não pode ser desfeita.',
              style: TextStyle(color: AppTheme.lightTextColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RPGButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RPGButton(
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    Navigator.pop(context);
                    final success = await gameService.resetProgressKeepPlayer();
                    if (success && context.mounted) {
                      // Ensure per-user progress is fresh and navigate to dashboard
                      try {
                        final storageService = StorageService();
                        final currentUser = await storageService.loadData('current_user');
                        if (currentUser != null && currentUser.toString().isNotEmpty) {
                          await gameService.saveUserProgress(currentUser.toString());
                        }
                      } catch (_) {}

                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const ProgressDashboardPage()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Reiniciar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}