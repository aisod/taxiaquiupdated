import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import '../data/questions_data.dart';
import 'quiz_page.dart';
import 'home_page.dart';
import 'progress_dashboard_page.dart';

class ResultsPage extends StatefulWidget {
  final int module;

  const ResultsPage({super.key, required this.module});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _buttonsAnimationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _statsSlideAnimation;
  late Animation<double> _statsFadeAnimation;
  late Animation<Offset> _buttonsSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveUserProgress();
      _startAnimations();
    });
  }

  void _setupAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.elasticOut,
    ));

    _statsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _statsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeInOut,
    ));

    _buttonsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeOutBack,
    ));

    _buttonsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _mainAnimationController.forward();
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _statsAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _buttonsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _statsAnimationController.dispose();
    _buttonsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _saveUserProgress() async {
    final gameService = context.read<GameService>();
    final storageService = StorageService();
    final currentUser = await storageService.loadData('current_user');
    
    if (currentUser != null && gameService.player != null) {
      // Calculate score based on XP or completed questions
      final questions = QuestionsData.getQuestionsByModule(widget.module);
      final completed = questions.where(
        (q) => gameService.player!.completedQuestions.contains(q.id),
      ).length;
      final score = completed * 10; // 10 points per completed question
      
      await gameService.updateUserProgressAfterQuiz(
        currentUser.toString(),
        widget.module,
        score,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTabletOrLarger = size.width > 768;
    final isLargeScreen = size.width > 1024;

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
              final player = gameService.player;
              if (player == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final questions = QuestionsData.getQuestionsByModule(widget.module);
              final completed = questions.where(
                (q) => player.completedQuestions.contains(q.id),
              ).length;
              final total = questions.length;
              final percentage = total > 0 ? (completed / total * 100).round() : 0;
              final moduleTitle = widget.module == 1 ? 'Impostos Fiscais' : 'Direitos Aduaneiros';

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 800 : (isTabletOrLarger ? 600 : double.infinity),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: Column(
                        children: [
                          // Header
                          SizedBox(
                            height: kToolbarHeight,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomePage()),
                                    (route) => false,
                                  ),
                                  icon: Icon(
                                    Icons.home,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Resultados',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 18 : null,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 24 : 48),

                          // Results Card
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(
                                    minHeight: isSmallScreen ? 400 : 500,
                                  ),
                                  padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                                    boxShadow: isTabletOrLarger ? [
                                      BoxShadow(
                                        color: colorScheme.shadow.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ] : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Celebration
                                      Text(
                                        '🎉',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 60 : (isTabletOrLarger ? 100 : 80),
                                        ),
                                      ),
                                      
                                      SizedBox(height: isSmallScreen ? 16 : 24),

                                      // Title
                                      Text(
                                        'Parabéns!',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 24 : (isTabletOrLarger ? 36 : null),
                                        ),
                                      ),

                                      SizedBox(height: isSmallScreen ? 12 : 16),

                                      // Module completed
                                      Text(
                                        'Módulo Concluído: $moduleTitle',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                          fontSize: isSmallScreen ? 16 : (isTabletOrLarger ? 20 : null),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      SizedBox(height: isSmallScreen ? 24 : 32),

                                      // Animated Stats
                                      SlideTransition(
                                        position: _statsSlideAnimation,
                                        child: FadeTransition(
                                          opacity: _statsFadeAnimation,
                                          child: isSmallScreen
                                            ? // Vertical layout for small screens
                                            Column(
                                              children: [
                                                _buildStatCard(
                                                  context,
                                                  icon: '📊',
                                                  label: 'Questões',
                                                  value: '$completed/$total',
                                                  theme: theme,
                                                  colorScheme: colorScheme,
                                                  isSmallScreen: isSmallScreen,
                                                  isTabletOrLarger: isTabletOrLarger,
                                                ),
                                                const SizedBox(height: 12),
                                                _buildStatCard(
                                                  context,
                                                  icon: '🎯',
                                                  label: 'Aproveitamento',
                                                  value: '$percentage%',
                                                  theme: theme,
                                                  colorScheme: colorScheme,
                                                  isSmallScreen: isSmallScreen,
                                                  isTabletOrLarger: isTabletOrLarger,
                                                ),
                                                const SizedBox(height: 12),
                                                _buildStatCard(
                                                  context,
                                                  icon: '⭐',
                                                  label: 'Nível',
                                                  value: '${player.level}',
                                                  theme: theme,
                                                  colorScheme: colorScheme,
                                                  isSmallScreen: isSmallScreen,
                                                  isTabletOrLarger: isTabletOrLarger,
                                                ),
                                              ],
                                            )
                                            : // Horizontal layout for larger screens
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Flexible(
                                                  child: _buildStatCard(
                                                    context,
                                                    icon: '📊',
                                                    label: 'Questões',
                                                    value: '$completed/$total',
                                                    theme: theme,
                                                    colorScheme: colorScheme,
                                                    isSmallScreen: isSmallScreen,
                                                    isTabletOrLarger: isTabletOrLarger,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: _buildStatCard(
                                                    context,
                                                    icon: '🎯',
                                                    label: 'Aproveitamento',
                                                    value: '$percentage%',
                                                    theme: theme,
                                                    colorScheme: colorScheme,
                                                    isSmallScreen: isSmallScreen,
                                                    isTabletOrLarger: isTabletOrLarger,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: _buildStatCard(
                                                    context,
                                                    icon: '⭐',
                                                    label: 'Nível',
                                                    value: '${player.level}',
                                                    theme: theme,
                                                    colorScheme: colorScheme,
                                                    isSmallScreen: isSmallScreen,
                                                    isTabletOrLarger: isTabletOrLarger,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ),
                                      ),

                                      SizedBox(height: isSmallScreen ? 24 : 32),

                                      // Animated Points Display
                                      SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.3),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: _statsAnimationController,
                                          curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                                        )),
                                        child: FadeTransition(
                                          opacity: Tween<double>(
                                            begin: 0.0,
                                            end: 1.0,
                                          ).animate(CurvedAnimation(
                                            parent: _statsAnimationController,
                                            curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
                                          )),
                                          child: Container(
                                            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Pontos Totais',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isSmallScreen ? 14 : (isTabletOrLarger ? 18 : null),
                                                  ),
                                                ),
                                                SizedBox(height: isSmallScreen ? 6 : 8),
                                                Text(
                                                  '${player.xp} Pontos',
                                                  style: theme.textTheme.headlineSmall?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isSmallScreen ? 20 : (isTabletOrLarger ? 28 : null),
                                                  ),
                                                ),
                                                SizedBox(height: isSmallScreen ? 12 : 16),
                                                LinearProgressIndicator(
                                                  value: (player.xp % 500) / 500,
                                                  backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                                                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                                                  minHeight: isTabletOrLarger ? 8 : 4,
                                                ),
                                                SizedBox(height: isSmallScreen ? 6 : 8),
                                                Text(
                                                  '${500 - (player.xp % 500)} Pontos para o próximo nível',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                                    fontSize: isSmallScreen ? 12 : (isTabletOrLarger ? 16 : null),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Animated Action Buttons
                          SlideTransition(
                            position: _buttonsSlideAnimation,
                            child: FadeTransition(
                              opacity: _buttonsFadeAnimation,
                              child: isSmallScreen
                                ? // Vertical layout for small screens
                                Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ProgressDashboardPage(), // This will show module selection
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: colorScheme.primary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.refresh, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Outro Módulo',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => const HomePage()),
                                            (route) => false,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.home, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Página Inicial',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : // Horizontal layout for larger screens
                              Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: isTabletOrLarger ? 56 : 48,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const ProgressDashboardPage(), // This will show module selection
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: colorScheme.primary),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(isTabletOrLarger ? 28 : 24),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.refresh, size: isTabletOrLarger ? 24 : 20),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  'Outro Módulo',
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isTabletOrLarger ? 16 : null,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: SizedBox(
                                        height: isTabletOrLarger ? 56 : 48,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => const HomePage()),
                                              (route) => false,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(isTabletOrLarger ? 28 : 24),
                                            ),
                                            elevation: 4,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.home, size: isTabletOrLarger ? 24 : 20),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  'Página Inicial',
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isTabletOrLarger ? 16 : null,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ),
                          ),
                          
                          // Add bottom padding for safe area
                          SizedBox(height: isSmallScreen ? 16 : 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
    bool isSmallScreen = false,
    bool isTabletOrLarger = false,
  }) {
    return Container(
      width: isSmallScreen ? double.infinity : null,
      padding: EdgeInsets.all(isSmallScreen ? 12 : (isTabletOrLarger ? 20 : 16)),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : (isTabletOrLarger ? 28 : 24),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : (isTabletOrLarger ? 8 : 8)),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : (isTabletOrLarger ? 24 : null),
            ),
          ),
          SizedBox(height: isSmallScreen ? 3 : 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: isSmallScreen ? 12 : (isTabletOrLarger ? 14 : null),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}