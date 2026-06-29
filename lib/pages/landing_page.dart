import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import 'character_creation_page.dart';
import 'home_page.dart'; // Added import for HomePage
import 'progress_dashboard_page.dart';
import 'tutorial_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  final _storageService = StorageService();
  String? _currentUser;
  Map<String, dynamic>? _userProgress;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      // Load current user
      final user = await _storageService.loadData('current_user');

      if (mounted) {
        setState(() {
          _currentUser = user?.toString();
        });

        // If user exists, load their progress
        if (_currentUser != null && _currentUser!.isNotEmpty) {
          final progress =
              await _storageService.loadData('user_progress_$_currentUser');

          if (mounted) {
            setState(() {
              _userProgress = progress;
            });
          }

          // Load game data for the current user
          final gameService = context.read<GameService>();
          await gameService.loadUserProgress(_currentUser!);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToApp() {
    final gameService = context.read<GameService>();
    final currentUser = _currentUser;

    // If we have a current user, try to load their progress and route accordingly
    if (currentUser != null && currentUser.isNotEmpty) {
      () async {
        await gameService.loadUserProgress(currentUser);

        if (!mounted) return;

        if (!gameService.hasPlayer) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CharacterCreationPage()),
          );
          return;
        }

        final player = gameService.player;
        final hasProgress = player != null && (player.completedQuestions.isNotEmpty || player.xp > 0);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => hasProgress
                ? const ProgressDashboardPage()
                : const TutorialPage(),
          ),
        );
      }();
      return;
    }

    // No user yet; go to character creation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CharacterCreationPage()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.secondary.withValues(alpha: 0.05),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingScreen(colorScheme)
              : _buildLandingContent(context, theme, colorScheme, size),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Carregando...',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandingContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Size size,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // App Logo with Animation
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/JUSTINHO-2.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            size: 80,
                            color: colorScheme.onPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App Title (UPPERCASE)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'SUPER-HERÓI TRIBUTÁRIO',//CAÇA TAXAS
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: size.width > 400 ? 42 : 36,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Continue/Start Button
                SizedBox(
                  width: 300,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentUser != null && _currentUser!.isNotEmpty
                              ? Icons.play_circle_filled
                              : Icons.rocket_launch,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _currentUser != null && _currentUser!.isNotEmpty
                              ? 'Continuar Jogo'
                              : 'Começar Aventura',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
