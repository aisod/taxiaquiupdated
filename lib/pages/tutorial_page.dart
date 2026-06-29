import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../theme.dart';
import 'progress_dashboard_page.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'title': 'Bem-vindo ao Reino Fiscal!',
      'description':
          'Você acabou de se juntar à elite dos Heróis Fiscais de Angola. Sua missão é dominar o conhecimento sobre impostos e direitos aduaneiros!',
      'icon': 'assets/images/JUSTINHO-2.png',
      'color': AppTheme.primaryBlue,
    },
    {
      'title': 'Sistema de Pontos e Níveis',
      'description':
          'Responda questões corretamente para ganhar XP:\n• 1ª tentativa: 150 XP\n• 2ª tentativa: 100 XP\n• 3ª tentativa: 50 XP\n\nCada 500 XP você sobe um nível!',
      'icon': '⭐',
      'color': AppTheme.secondaryPurple,
    },
    {
      'title': 'Módulos de Aprendizagem',
      'description':
          'Explore três módulos épicos:\n\n🧒 Justinho e Os Impostos\n(Educação Fiscal e Cidadania)\n\n💰 Impostos Fiscais\n(IVA, IRT, Imposto Predial, etc.)\n\n🚢 Direitos Aduaneiros\n(Importação, Exportação, Regimes Especiais)',
      'icon': '📚',
      'color': AppTheme.primaryBlue,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Consumer<GameService>(
                          builder: (context, gameService, child) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary,
                              ),
                              child: const Center(
                                child: Text(
                                  '⚔️',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tutorial',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Aprenda os fundamentos do jogo',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _skipTutorial,
                          child: Text(
                            'Pular',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: List.generate(
                        _tutorialSteps.length,
                        (index) => Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: index <= _currentStep
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tutorial Content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      itemCount: _tutorialSteps.length,
                      itemBuilder: (context, index) {
                        return _buildTutorialStep(
                          context,
                          _tutorialSteps[index],
                          index,
                        );
                      },
                    ),
                  ),

                  // Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // CENTRALIZA OS BOTÕES
                      children: [
                        if (_currentStep > 0)
                          SizedBox(
                            width: 300, // Largura menor para o botão voltar não empurrar muito o centro
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'Anterior',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        
                        // --- BOTÃO PRÓXIMO CENTRALIZADO COM 400 de pois 300 DE WIDTH ---
                        SizedBox(
                          width: 300,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentStep == _tutorialSteps.length - 1
                                      ? Icons.play_arrow
                                      : Icons.arrow_forward,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _currentStep == _tutorialSteps.length - 1
                                        ? 'Começar Jogo'
                                        : 'Próximo',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildTutorialStep(
    BuildContext context,
    Map<String, dynamic> step,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: (step['icon'] as String).contains('assets/')
                  ? Image.asset(
                      step['icon'] as String,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (step['color'] as Color).withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          step['icon'] as String,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            Text(
              step['title'] as String,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  step['description'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
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

  void _nextStep() {
    if (_currentStep < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipTutorial() {
    _finishTutorial();
  }

  void _finishTutorial() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProgressDashboardPage()),
    );
  }
}