import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import 'tutorial_page.dart';
import 'progress_dashboard_page.dart';

class CharacterCreationPage extends StatefulWidget {
  const CharacterCreationPage({super.key});

  @override
  State<CharacterCreationPage> createState() => _CharacterCreationPageState();
}

class _CharacterCreationPageState extends State<CharacterCreationPage> {
  final _nameController = TextEditingController();
  String _selectedHero = 'warrior';
  bool _isMeeting = false;
  bool _isCheckingExistingHero = true;
  bool _navigatedAway = false;

  final List<Map<String, dynamic>> _heroOptions = [
    {
      'type': 'warrior',
      'name': 'Guerreiro Fiscal',
      'description': 'Um herói especialista em combater a evasão fiscal',
      'iconData': Icons.security,
    },
    {
      'type': 'mage',
      'name': 'Mago dos Impostos',
      'description': 'Um herói mestre em cálculos e fórmulas fiscais',
      'iconData': Icons.calculate,
    },
    {
      'type': 'guardian',
      'name': 'Guardião Aduaneiro',
      'description': 'Um herói protetor das fronteiras comerciais',
      'iconData': Icons.shield,
    },
    {
      'type': 'scholar',
      'name': 'Sábio da AGT',
      'description': 'Um herói conhecedor das leis e regulamentos',
      'iconData': Icons.school,
    },
  ];

  final List<String> _nameSuggestions = [
    'Herói Fiscal',
    'Defensor AGT',
    'Mestre Tributário',
    'Guardião do Reino',
    'Sábio Aduaneiro',
    'Cavaleiro da Lei',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkExistingHero();
  }

  Future<void> _checkExistingHero() async {
    try {
      final storageService = StorageService();
      final currentUser = await storageService.loadData('current_user');

      if (currentUser != null && currentUser.toString().isNotEmpty) {
        final existingProgress = await storageService
            .loadData('user_progress_${currentUser.toString()}');

        if (existingProgress != null) {
          final hasPlayerName = existingProgress['player_name'] != null &&
              existingProgress['player_name'].toString().trim().isNotEmpty;

          if (hasPlayerName && mounted) {
            final gameService = context.read<GameService>();
            await gameService.loadUserProgress(currentUser.toString());

            if (!mounted) return;
            _navigatedAway = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProgressDashboardPage()),
            );
            return;
          }
        }
      } else {
        const defaultUser = 'player';
        await storageService.saveData('current_user', defaultUser);

        final initialProgress = {
          'username': defaultUser,
          'total_score': 0,
          'modules_completed': [],
          'current_level': 1,
          'achievements': [],
          'created_at': DateTime.now().toIso8601String(),
          'last_played': DateTime.now().toIso8601String(),
        };
        await storageService.saveData(
            'user_progress_$defaultUser', initialProgress);
      }
    } catch (e) {
      debugPrint('Error checking existing hero: $e');
    } finally {
      if (mounted && !_navigatedAway) {
        setState(() {
          _isCheckingExistingHero = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingExistingHero) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Cabeçalho (Header)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                    ),
                    Expanded(
                      child: Text(
                        'Conheça o Teu Herói',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // --- BLOCO DO NOME CENTRALIZADO ---
                      Center(
                        child: Container(
                          width: 800, // Largura fixa solicitada double.infinity conteiner1
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                // Substituído Icon por Image.asset
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12), // Deixa os cantos arredondados
                                  child: Image.asset(
                                    'assets/images/JUSTINHO-2.png', // Caminho da sua imagem
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Text(
                                  'Nome do Teu Herói',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Como quer ser chamado, herói?',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: colorScheme.outline),
                                  ),
                                  prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sugestões:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _nameSuggestions.map((suggestion) {
                                  return GestureDetector(
                                    onTap: () => _nameController.text = suggestion,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: colorScheme.primary),
                                        color: colorScheme.primary.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        suggestion,
                                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- BLOCO DE SELEÇÃO DE CLASSE CENTRALIZADO ---
                      Center(
                        child: Container(
                          width: 800, // Largura fixa solicitada  double.infinity conteniner2
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.face, color: colorScheme.primary, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Quem é o Teu Herói?',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ...(_heroOptions.map((heroOption) {
                                final isSelected = _selectedHero == heroOption['type'];
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedHero = heroOption['type']!),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      color: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.2),
                                          ),
                                          child: Icon(
                                            heroOption['iconData']!,
                                            size: 24,
                                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                heroOption['name']!,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                heroOption['description']!,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Botão de Criar (Também centralizado e responsivo)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: SizedBox(
                    width: 400, // Largura controlada para o botão double.infinity /boato ocnhecer meu heroi
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isMeeting ? null : _meetHero,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 8,
                      ),
                      child: _isMeeting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.handshake, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'Conhecer Meu Herói',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _meetHero() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Por favor, diga-nos como quer ser chamado, herói!');
      return;
    }

    if (name.length < 2) {
      _showSnackBar('O nome deve ter pelo menos 2 caracteres!');
      return;
    }

    setState(() => _isMeeting = true);

    try {
      final gameService = context.read<GameService>();
      final success = await gameService.createPlayer(name, _selectedHero);

      if (success && mounted) {
        final storageService = StorageService();
        final currentUser = await storageService.loadData('current_user');
        if (currentUser != null) {
          await gameService.saveUserProgress(currentUser.toString());
        }

        if (!mounted) return;
        _navigatedAway = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TutorialPage()),
        );
      } else if (mounted) {
        _showSnackBar('Erro ao conhecer o herói. Tente novamente!');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro inesperado: $e');
    } finally {
      if (mounted && !_navigatedAway) {
        setState(() => _isMeeting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}