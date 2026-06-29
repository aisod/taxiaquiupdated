import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import 'character_creation_page.dart';
import 'landing_page.dart';
import 'progress_dashboard_page.dart';
import 'tutorial_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storageService = StorageService();
  String? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  Future<void> _loadCurrentUser() async {
    final user = await _storageService.loadData('current_user');
    if (mounted) {
      setState(() {
        _currentUser = user?.toString();
      });

      // Load user progress if user exists
      if (_currentUser != null && _currentUser!.isNotEmpty) {
        final gameService = context.read<GameService>();
        await gameService.loadUserProgress(_currentUser!);

        // Don't auto-navigate anymore - let user see HomePage and choose what to do
      }
    }
  }

  Future<void> _logout() async {
    // Clear current user data
    await _storageService.saveData('current_user', '');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (route) => false,
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _currentUser != null
          ? AppBar(
              // ... (código do AppBar mantido exatamente igual)
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.onPrimary,
                    child: Icon(
                      Icons.person,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Caça Taxas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _currentUser ?? 'Jogador',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Sair do Jogo'),
                          content: Text(
                              'Tem certeza que deseja sair, $_currentUser?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _logout();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Sair'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sair',
                ),
              ],
            )
          : null,
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
          // ADICIONADO: Center para centralizar na horizontal
          child: Center(
            // ADICIONADO: ConstrainedBox para limitar a 800px
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Consumer<GameService>(
                builder: (context, gameService, child) {
                  if (gameService.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return _buildWelcomeScreen(context, theme, colorScheme);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildWelcomeScreen(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // App Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/JUSTINO_AGT_CARTOON_2.png',
                width: 180,
                height: 190,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 32),

            // App Title
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Caça Taxas',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width > 400 ? 48 : 40,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Jogo Educativo sobre Impostos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Embarque numa aventura épica pelo Reino Fiscal! Aprenda sobre impostos e direitos aduaneiros de Angola enquanto ganha XP e desbloqueia conquistas.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Scroll hint
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Funcionalidades',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.swipe,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Deslize →',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Feature Cards
            SizedBox(
              height: 200, // Fixed height for the horizontal scroll view
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics:
                    const BouncingScrollPhysics(), // Add bouncing scroll effect
                children: [
                  _buildFeatureCard(
                    context,
                    icon: '📚',
                    title: '20 Questões',
                    description:
                        'Aprenda sobre impostos fiscais e direitos aduaneiros',
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  _buildFeatureCard(
                    context,
                    icon: '⚔️',
                    title: 'Sistema RPG',
                    description: 'Ganhe XP, suba de nível, conquiste títulos',
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 16),
                  _buildFeatureCard(
                    context,
                    icon: '🏆',
                    title: 'Conquistas',
                    description: 'Desbloqueie medalhas e troféus especiais',
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 16), // Extra spacing at the end
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Start Button botao começar aventura
            SizedBox(
              width: 300,//double.infinity
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentUser != null && _currentUser!.isNotEmpty) {
                    final gameService = context.read<GameService>();
                    await gameService.loadUserProgress(_currentUser!);

                    if (!gameService.hasPlayer) {
                      // No character exists, go to character creation
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CharacterCreationPage(),
                        ),
                      );
                    } else {
                      // Character exists, check if they have progress (tutorial completed)
                      final player = gameService.player;
                      if (player != null &&
                          (player.completedQuestions.isNotEmpty ||
                              player.xp > 0)) {
                        // User has progress, go to progress dashboard
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProgressDashboardPage(),
                          ),
                        );
                      } else {
                        // Character exists but no progress, go to tutorial
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TutorialPage(),
                          ),
                        );
                      }
                    }
                  } else {
                    // No user, go to character creation to create one
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterCreationPage(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Começar Aventura',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Mascot images
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/1.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.image,
                          color: colorScheme.primary,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/2.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.image,
                          color: colorScheme.secondary,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/3-2.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.image,
                          color: colorScheme.tertiary,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 200, // Increased width to ensure scrolling is needed
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 180, // Fixed height to ensure consistent card sizing
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
