import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/game_state.dart';
import '../data/questions_data.dart';
import 'results_page.dart';
import 'progress_dashboard_page.dart';



class QuizPage extends StatefulWidget {
  final int? moduleId;
  
  const QuizPage({super.key, this.moduleId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int? _selectedModule;
  int? _selectedAnswer;
  bool _isAnswering = false;
  bool _showExplanation = false;
  GameAnswer? _lastAnswer;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  String _currentQuestionAvatar = '';

  // Animation controllers
  late AnimationController _questionSlideController;
  late AnimationController _optionsSlideController;
  
  // Animations
  late Animation<Offset> _questionSlideAnimation;
  late Animation<Offset> _optionsSlideAnimation;
  late Animation<double> _questionFadeAnimation;
  late Animation<double> _optionsFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _questionSlideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _optionsSlideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize slide animations
    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _questionSlideController,
      curve: Curves.easeOutCubic,
    ));
    
    _optionsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _optionsSlideController,
      curve: Curves.easeOutBack,
    ));
    
    // Initialize fade animations
    _questionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionSlideController,
      curve: Curves.easeInOut,
    ));
    
    _optionsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _optionsSlideController,
      curve: Curves.easeInOut,
    ));

    if (widget.moduleId != null) {
      _selectedModule = widget.moduleId;
      // Auto-start the module if moduleId is provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startModule(widget.moduleId!);
      });
    }
  }

  @override
  void dispose() {
    _questionSlideController.dispose();
    _optionsSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

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
          child: _selectedModule == null
              ? _buildModuleSelection(context, theme, colorScheme, size)
              : Consumer<GameService>(
                  builder: (context, gameService, child) {
                    // Use local questions list instead of gameService.currentQuestion
                    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final currentQuestion = _questions[_currentQuestionIndex];

                    return _showExplanation 
                        ? _buildExplanation(context, currentQuestion, theme, colorScheme, size)
                        : _buildQuestion(context, currentQuestion, theme, colorScheme, size);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildModuleSelection(BuildContext context, ThemeData theme, ColorScheme colorScheme, Size size) {
    final isSmallScreen = size.height < 700;
    
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height - MediaQuery.of(context).viewPadding.top - MediaQuery.of(context).viewPadding.bottom,
        ),
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
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProgressDashboardPage())),
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Módulos de Aprendizagem',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 18 : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Consumer<GameService>(
                      builder: (context, gameService, child) {
                        if (gameService.player == null) {
                          return const SizedBox(width: 48);
                        }
                        return _buildPointsLevelsDisplay(
                          context,
                          gameService.player!,
                          theme,
                          colorScheme,
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 24 : 48),

              // Module cards
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Module 1 - Fiscal Taxes
                    _buildModuleCard(
                      context,
                      module: 1,
                      title: 'Impostos Fiscais',
                      description: 'IVA, IRT, Imposto Predial, etc.',
                      icon: '💰',
                      color: colorScheme.primary,
                      theme: theme,
                      colorScheme: colorScheme,
                      isSmallScreen: isSmallScreen,
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // Module 2 - Customs Rights  
                    _buildModuleCard(
                      context,
                      module: 2,
                      title: 'Direitos Aduaneiros',
                      description: 'Importação, Exportação, Regimes Especiais',
                      icon: '🚢',
                      color: colorScheme.primary,
                      theme: theme,
                      colorScheme: colorScheme,
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
              ),
              
              // Add bottom padding for safe area
              SizedBox(height: isSmallScreen ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required int module,
    required String title,
    required String description,
    required String icon,
    required Color color,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: () => _startModule(module),
      child: Container(
        width: double.infinity, //double.infinity
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: isSmallScreen ? 36 : 48),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 20 : null,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: isSmallScreen ? 13 : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16, 
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Começar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 13 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
          //começa aqui
  Widget _buildQuestion(BuildContext context, Question question, ThemeData theme, ColorScheme colorScheme, Size size) {
    final isSmallScreen = size.height < 700;
    final isVerySmallScreen = size.height < 600;
    final padding = isSmallScreen ? 16.0 : 24.0;
    
    return Column(
      children: [
        // Header inicia aqui
      Center( // Adicionado para centralizar na tela
  child: Container(
    constraints: const BoxConstraints(maxWidth: 800), // Define o limite de 800px
    padding: EdgeInsets.all(padding),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ProgressDashboardPage())),
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.primary,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Questão ${_currentQuestionIndex + 1} de ${_questions.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : null,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ],
          ),
        ),
        Consumer<GameService>(
          builder: (context, gameService, child) {
            if (gameService.player == null) {
              return const SizedBox(width: 48);
            }
            return _buildPointsLevelsDisplay(
              context,
              gameService.player!,
              theme,
              colorScheme,
            );
          },
        ),
      ],
    ),
  ),
),
//termina aqui o header

        // Question Content - Make it flexible and scrollable
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                children: [
                  // Animated Question Card
                  SlideTransition(
                    position: _questionSlideAnimation,
                    child: FadeTransition(
                      opacity: _questionFadeAnimation,
                      child: Container(
                        width: 800, //double.infinity
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            // Random mascot image in question card
                            Container(
                              width: isSmallScreen ? 10 : 80,
                              height: isSmallScreen ? 60 : 80,
                              margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 30 : 40),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 30 : 40),
                                child: Image.asset(
                                  _currentQuestionAvatar.isNotEmpty 
                                      ? _currentQuestionAvatar 
                                      : 'assets/images/3-2.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              question.text,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                height: 1.5,
                                fontSize: isSmallScreen ? 16 : null,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Animated Answer Options
                 // Substitua o bloco de Animated Answer inicia qui o conteiner das opcoes:

  // Animated Answer Options
  Center( // <-- Adicionado para centralizar na tela
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800), // <-- Define o limite de 800px
      child: SlideTransition(
        position: _optionsSlideAnimation,
        child: FadeTransition(
          opacity: _optionsFadeAnimation,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: isVerySmallScreen ? 200 : (isSmallScreen ? 280 : 350),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: isVerySmallScreen 
                  ? const AlwaysScrollableScrollPhysics() 
                  : const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedAnswer == index;
                final letter = String.fromCharCode(65 + index); // A, B, C, D
                
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  curve: Curves.easeOutBack,
                  margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                  child: GestureDetector(
                    onTap: _isAnswering ? null : () {
                      setState(() {
                        _selectedAnswer = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? colorScheme.primary.withValues(alpha: 0.1) 
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? colorScheme.primary 
                              : colorScheme.outline.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 28 : 32,
                            height: isSmallScreen ? 28 : 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isSelected ? Colors.white : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 13 : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: isSmallScreen ? 14 : null,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                              size: isSmallScreen ? 20 : 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  ),
  //termina aqui o conteirner das opocoes
                ],
              ),
            ),
          ),
        ),

        // Submit Button
        Padding(
          padding: EdgeInsets.all(padding),
          child: SizedBox(
            width:300, //double.infinity
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: _selectedAnswer != null && !_isAnswering ? _submitAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
                ),
                elevation: 8,
              ),
              child: _isAnswering
                  ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: isSmallScreen ? 2 : 3,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: isSmallScreen ? 20 : 24),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(
                          'Enviar Resposta', //aqui
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : null,
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

  Widget _buildExplanation(BuildContext context, Question question, ThemeData theme, ColorScheme colorScheme, Size size) {
    final isCorrect = _lastAnswer?.isCorrect ?? false;
    final xpEarned = _lastAnswer?.xpEarned ?? 0;
    final isSmallScreen = size.height < 700;
    final padding = isSmallScreen ? 16.0 : 24.0;

    return Column(
      children: [
        // Header começa aqui o header do respostas certa s e incorretas
        Center(
  child: Container(
    constraints: const BoxConstraints(maxWidth: 800), // Define o limite de 800px
    padding: EdgeInsets.all(padding),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ProgressDashboardPage())),
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.primary,
          ),
        ),
        Expanded(
          child: Text(
            'Resultado',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Consumer<GameService>(
          builder: (context, gameService, child) {
            if (gameService.player == null) {
              return const SizedBox(width: 48);
            }
            return _buildPointsLevelsDisplay(
              context,
              gameService.player!,
              theme,
              colorScheme,
                  );
                },
              ),
            ],
          ),
        ),
      ),
        // Result - Make it scrollable with animations
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                children: [
                  // Animated Result Card começa aqui o conteiner de resposta certa e erra
                  SlideTransition(
                    position: _questionSlideAnimation,
                    child: FadeTransition(
                      opacity: _questionFadeAnimation,
                      child: Container(
                        width: 800,
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                        decoration: BoxDecoration(
                          color: isCorrect 
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              size: isSmallScreen ? 48 : 64,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Text(
                              isCorrect ? 'Resposta Correta!' : 'Resposta Incorreta',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 18 : null,
                              ),
                            ),
                            if (isCorrect) ...[
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.bounceOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 12 : 16, 
                                  vertical: isSmallScreen ? 6 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '+$xpEarned Pontos',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 14 : null,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Animated Correct Answer conteiner donde vem a resposta correta apois ser respondida
                  SlideTransition(
                    position: _optionsSlideAnimation,
                    child: FadeTransition(
                      opacity: _optionsFadeAnimation,
                      child: Container(
                        width:800, 
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resposta Correta:',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : null,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            Text(
                              '${String.fromCharCode(65 + question.correctAnswer)}) ${question.options[question.correctAnswer]}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: isSmallScreen ? 14 : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Animated Explanation
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _optionsSlideController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
                    )),
                    child: FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: _optionsSlideController,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
                      )),
                      // 
                      child: Container( 
                        width: 800, //conteiner da explicacao das respostas
                        constraints: BoxConstraints(
                          minHeight: isSmallScreen ? 120 : 150,
                          maxHeight: isSmallScreen ? 200 : 300,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explicação:',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : null,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  question.explanation,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    height: 1.5,
                                    fontSize: isSmallScreen ? 14 : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //outra parte;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  // Add bottom spacing
                  SizedBox(height: isSmallScreen ? 16 : 24),
                ],
              ),
            ),
          ),
        ),

        // Next Button aqui começa o codigo do botao proxima quesstao
        Padding(
          padding: EdgeInsets.all(padding),
          child: SizedBox(
            width: 300,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _currentQuestionIndex < _questions.length - 1 
                        ? Icons.arrow_forward 
                        : Icons.emoji_events,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    _currentQuestionIndex < _questions.length - 1 
                        ? 'Próxima Questão' 
                        : 'Ver Resultados',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : null,
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

  void _startModule(int module) async {
    final gameService = context.read<GameService>();
    
    // Make sure game service is initialized and has a player
    if (!gameService.hasPlayer) {
      await gameService.initialize();
    }
    
    // Get questions for this module
    final questions = QuestionsData.getQuestionsByModule(module);
    
    if (questions.isEmpty) {
      // Show error if no questions found
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma questão encontrada para este módulo.'),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _selectedModule = module;
      _questions = questions;
      _currentQuestionIndex = 0;
      // Get random avatar for first question
      _currentQuestionAvatar = QuestionsData.getRandomAvatar();
    });
    
    // Start quiz in game service
    gameService.startQuiz(module);
    
    // Trigger entrance animations for the first question
    _animateQuestionEntrance();
  }

  void _submitAnswer() async {
    if (_selectedAnswer == null || _isAnswering) return;

    setState(() {
      _isAnswering = true;
    });

    try {
      final gameService = context.read<GameService>();
      final currentQuestion = _questions[_currentQuestionIndex];
      final answer = await gameService.answerQuestion(_selectedAnswer!, question: currentQuestion);
      
      setState(() {
        _lastAnswer = answer;
        _showExplanation = true;
        _isAnswering = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar resposta: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isAnswering = false;
      });
    }
  }

  void _nextQuestion() {
    // Check if there are more questions in the local list
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      setState(() {
        _selectedAnswer = null;
        _showExplanation = false;
        _lastAnswer = null;
        // Get new random avatar for next question
        _currentQuestionAvatar = QuestionsData.getRandomAvatar();
      });
      // Trigger entrance animations for the new question
      _animateQuestionEntrance();
    } else {
      // Module completed - navigate to results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(module: _selectedModule!),
        ),
      );
    }
  }

  void _animateQuestionEntrance() {
    // Reset animations to initial state
    _questionSlideController.reset();
    _optionsSlideController.reset();
    
    // Start question animation first
    _questionSlideController.forward();
    
    // Start options animation with a slight delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _optionsSlideController.forward();
      }
    });
  }

  Widget _buildPointsLevelsDisplay(
    BuildContext context,
    Player player,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Level Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                'Nível ${player.level}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Points Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '${player.xp} Pontos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}