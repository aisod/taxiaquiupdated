import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../models/simulation_models.dart';
import '../widgets/rpg_ui_components.dart';
import '../theme.dart';


class BusinessSimulationPage extends StatefulWidget {
  const BusinessSimulationPage({super.key});

  @override
  State<BusinessSimulationPage> createState() => _BusinessSimulationPageState();
}

class _BusinessSimulationPageState extends State<BusinessSimulationPage> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  // Use theme colors for background
  List<Color> get _backgroundColors => [
    AppTheme.primaryBlue, // Use theme primary color
    AppTheme.secondaryPurple, // Use theme secondary color
  ];

  // Current level the player is viewing (for scrolling the board)
  double _scrollPosition = 0;
  
  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationService>(
      builder: (context, simulationService, _) {
        final business = simulationService.business;
        final player = simulationService.player;
        
        if (business == null || player == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Calculate the current position on the board based on months in operation
        final currentLevel = business.monthsInOperation;
        
        return AnimatedBuilder(
          animation: _backgroundAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(_backgroundColors[0], _backgroundColors[1], 
                        _backgroundAnimationController.value) ?? _backgroundColors[0],
                    Color.lerp(_backgroundColors[1], _backgroundColors[0], 
                        _backgroundAnimationController.value) ?? _backgroundColors[1],
                  ],
                ),
              ),
              child: child,
            );
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      // Player avatar in rounded container like reference
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: RPGAvatar(
                              avatarType: player.avatarType,
                              glowing: false,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Lives indicator - represented as heart
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '5',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Plus icon button for adding lives
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Completion badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBackground, // Use theme background
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Completo',
                          style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Coins counter
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBackground, // Use theme background
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.attach_money, color: Colors.amber, size: 20),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(business.cashBalance / 1000).floor()}',
                              style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Plus icon button for adding coins
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Settings gear
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryPurple, // Light blue color like in reference
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.settings, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                // Horizontal divider like in reference
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                
                // Main game board with scrollable path
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2A557), // Golden wood color like reference
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildGameBoard(simulationService, currentLevel),
                      ),
                    ),
                  ),
                ),
                
                // Bottom navigation bar
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DBEC4), // Light teal color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavButton(Icons.email, '11', 'Mensagem', false),
                      _buildNavButton(Icons.check_box, '', 'Tarefas', true),
                      _buildNavButton(Icons.home, '', 'Início', false),
                      _buildNavButton(Icons.people, '3', 'Social', false),
                      _buildNavButton(Icons.grid_view, '', '123', false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Bottom navigation button
  Widget _buildNavButton(IconData icon, String badge, String label, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon, 
              color: selected ? Colors.green : Colors.white, 
              size: 24
            ),
            if (badge.isNotEmpty)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
  
  Widget _buildGameBoard(SimulationService simulationService, int currentLevel) {
    final levelNodes = _generateLevelNodes(60); // Generate 60 levels in the game
    
    return Stack(
      children: [
        // Game path with nodes
        _buildGamePath(),
        
        // Overlay level nodes on path
        ...levelNodes.map((node) => _buildLevelNode(node, simulationService, currentLevel)).toList(),
        
        // Player character on current node
        _buildPlayerCharacter(simulationService, levelNodes[currentLevel.clamp(0, levelNodes.length - 1)]),
      ],
    );
  }
  
  Widget _buildGamePath() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Path elements like furniture, plants, etc.
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1517323197145-72f28d311d51?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjB8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjB8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Path row 1
          Row(
            children: [
              for (int i = 0; i < 6; i++)
                Expanded(
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          
          // Decorative element
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1470690096659-6f59b9b39fd1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjF8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Path row 2 (reverse direction)
          Row(
            children: [
              for (int i = 0; i < 6; i++)
                Expanded(
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          
          // Decorative element
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1711985220370-07ead417d683?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjF8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1603373362818-a7d8817ce7ca?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjJ8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Path row 3
          Row(
            children: [
              for (int i = 0; i < 6; i++)
                Expanded(
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          
          // Decorative element
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1635282037653-707173ae1753?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjJ8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1513358130276-442a18340285?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjN8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Path row 4 (reverse direction)
          Row(
            children: [
              for (int i = 0; i < 6; i++)
                Expanded(
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          
          // Decorative element
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.network(
                      "https://images.unsplash.com/photo-1576503918400-0b982e6a98bf?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgyMjN8&ixlib=rb-4.1.0&q=80&w=1080",
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Add a final row with stars for goals
          Row(
            children: [
              for (int i = 0; i < 6; i++)
                Expanded(
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 24),
                        Icon(Icons.star, color: Colors.amber, size: 24),
                        Icon(Icons.star, color: Colors.amber, size: 24),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Generate positions for each level node
  List<Map<String, dynamic>> _generateLevelNodes(int count) {
    final List<Map<String, dynamic>> nodes = [];
    
    // Starting position
    double x = 50;
    double y = 660;
    bool movingRight = true;
    
    for (int i = 0; i < count; i++) {
      nodes.add({
        'level': i,
        'x': x,
        'y': y,
        'type': _getLevelType(i),
      });
      
      // Calculate next position along the path
      if (i % 6 == 5) {
        // Move up to next row
        y -= 80;
        movingRight = !movingRight; // Change direction
      } else {
        // Move horizontally
        x += movingRight ? 60 : -60;
      }
    }
    
    return nodes;
  }
  
  String _getLevelType(int level) {
    // Different level types based on what happens there
    if (level % 10 == 0) return 'milestone'; // Major milestone
    if (level % 5 == 0) return 'tax'; // Tax payment
    if (level % 7 == 0) return 'event'; // Random business event
    if (level % 3 == 0) return 'bonus'; // Bonus opportunity
    return 'normal'; // Regular business operations
  }
  
  Widget _buildLevelNode(Map<String, dynamic> node, SimulationService simulationService, int currentLevel) {
    final level = node['level'];
    final isCompleted = level < currentLevel;
    final isCurrent = level == currentLevel;
    
    Color nodeColor;
    IconData? nodeIcon;
    
    // Determine node appearance based on type
    switch (node['type']) {
      case 'milestone':
        nodeColor = AppTheme.primaryBlue;
        nodeIcon = Icons.flag;
        break;
      case 'tax':
        nodeColor = AppTheme.error;
        nodeIcon = Icons.account_balance;
        break;
      case 'event':
        nodeColor = AppTheme.secondaryPurple;
        nodeIcon = Icons.event;
        break;
      case 'bonus':
        nodeColor = AppTheme.warning;
        nodeIcon = Icons.card_giftcard;
        break;
      default:
        nodeColor = AppTheme.success;
        nodeIcon = Icons.business;
    }
    
    return Positioned(
      left: node['x'],
      top: node['y'],
      child: GestureDetector(
        onTap: () => _handleNodeTap(level, simulationService),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.grey : nodeColor,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: Colors.white, width: 3) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isCompleted 
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Icon(nodeIcon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlayerCharacter(SimulationService simulationService, Map<String, dynamic> currentNode) {
    final player = simulationService.player!;
    
    return Positioned(
      left: currentNode['x'] - 10,
      top: currentNode['y'] - 30,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.purpleAccent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: RPGAvatar(
              avatarType: player.avatarType,
              glowing: false,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleNodeTap(int level, SimulationService simulationService) {
    final currentLevel = simulationService.business!.monthsInOperation;
    
    // Can't go to future nodes
    if (level > currentLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você ainda não chegou a este nível!'))
      );
      return;
    }
    
    // Show dialog with level details
    _showLevelDialog(level, simulationService);
  }
  
  void _showLevelDialog(int level, SimulationService simulationService) {
    final levelType = _getLevelType(level);
    String title;
    String description;
    List<Widget> actions = [];
    
    switch (levelType) {
      case 'milestone':
        title = 'Marco Importante!';
        description = 'Parabéns! Você alcançou um marco importante na sua jornada empresarial.';
        actions = [
          _buildLevelActionButton('Ver Prêmio', Icons.card_giftcard, () {
            Navigator.pop(context);
            _advanceMonth(simulationService);
          }),
        ];
        break;
      case 'tax':
        title = 'Tempo de Impostos';
        description = 'É hora de declarar e pagar seus impostos. Manter-se em dia com as obrigações fiscais é essencial para um negócio próspero.';
        actions = [
          _buildLevelActionButton('Declarar Impostos', Icons.account_balance, () {
            Navigator.pop(context);
            _showTaxDialog(simulationService);
          }),
        ];
        break;
      case 'event':
        title = 'Evento de Negócios';
        description = 'Um evento importante está acontecendo que pode afetar seu negócio. Tome uma decisão sábia!';
        actions = [
          _buildLevelActionButton('Ver Evento', Icons.event, () {
            Navigator.pop(context);
            _showEventDialog(simulationService);
          }),
        ];
        break;
      case 'bonus':
        title = 'Oportunidade de Bônus';
        description = 'Uma oportunidade especial surgiu! Aproveite para ganhar recursos extras para seu negócio.';
        actions = [
          _buildLevelActionButton('Obter Bônus', Icons.card_giftcard, () {
            Navigator.pop(context);
            _showBonusDialog(simulationService);
          }),
        ];
        break;
      default:
        title = 'Operações de Negócios';
        description = 'Gerencie as operações diárias do seu negócio e tome decisões que afetarão seu crescimento.';
        actions = [
          _buildLevelActionButton('Gerenciar', Icons.business, () {
            Navigator.pop(context);
            _showBusinessDialog(simulationService);
          }),
        ];
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: RPGText(
          text: title,
          style: TextStyle(color: AppTheme.goldAccent, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              description,
              style: TextStyle(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar', style: TextStyle(color: AppTheme.lightTextColor)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelActionButton(String label, IconData icon, VoidCallback onPressed) {
    return RPGButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.darkTextColor),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: AppTheme.darkTextColor)),
        ],
      ),
    );
  }
  
  void _showTaxDialog(SimulationService simulationService) {
    final pendingFilings = simulationService.pendingFilings;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: RPGText(
          text: 'Declaração de Impostos',
          style: TextStyle(color: AppTheme.goldAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha qual imposto você quer declarar:',
              style: TextStyle(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.maxFinite,
              height: 200,
              child: pendingFilings.isEmpty
                ? Center(child: Text('Não há impostos pendentes!', style: TextStyle(color: AppTheme.lightTextColor)))
                : ListView.builder(
                  itemCount: pendingFilings.length,
                  itemBuilder: (context, index) {
                    final filing = pendingFilings[index];
                    return Card(
                      color: AppTheme.darkBackground,
                      child: ListTile(
                        title: Text(filing.taxType, style: TextStyle(color: AppTheme.lightTextColor)),
                        subtitle: Text('${filing.estimatedAmount.toStringAsFixed(0)} Kz', style: TextStyle(color: AppTheme.goldAccent)),
                        trailing: RPGButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fileTax(filing, simulationService);
                          },
                          padding: EdgeInsets.all(8),
                          child: Text('Pagar', style: TextStyle(color: AppTheme.darkTextColor)),
                        ),
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar', style: TextStyle(color: AppTheme.lightTextColor)),
          ),
        ],
      ),
    );
  }
  
  void _fileTax(TaxFiling filing, SimulationService simulationService) {
    simulationService.submitTaxFiling(filing, filing.estimatedAmount);
    
    // Show a confetti animation or success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imposto ${filing.taxType} pago com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _showEventDialog(SimulationService simulationService) {
    final event = simulationService.currentEvents.isNotEmpty 
        ? simulationService.currentEvents.first 
        : null;
    
    if (event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não há eventos ativos no momento!')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: RPGText(
          text: event.title,
          style: TextStyle(color: AppTheme.goldAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.description,
              style: TextStyle(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 16),
            if (event.choices.isNotEmpty)
              Column(
                children: event.choices.map((choice) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RPGButton(
                      onPressed: () {
                        Navigator.pop(context);
                        simulationService.makeBusinessDecision(event, choice);
                      },
                      child: Text(choice, style: TextStyle(color: AppTheme.darkTextColor)),
                    ),
                  ),
                ).toList(),
              )
            else
              RPGButton(
                onPressed: () {
                  Navigator.pop(context);
                  simulationService.makeBusinessDecision(event, 'acknowledge');
                },
                child: Text('Entendido', style: TextStyle(color: AppTheme.darkTextColor)),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showBonusDialog(SimulationService simulationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: RPGText(
          text: 'Bônus de Negócio!',
          style: TextStyle(color: AppTheme.goldAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha seu bônus:',
              style: TextStyle(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBonusOption(
                  'Dinheiro', 
                  Icons.attach_money, 
                  Colors.green,
                  () {
                    Navigator.pop(context);
                    simulationService.addBusinessBonus('cash', 50000);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Você ganhou 50.000 Kz!')),
                    );
                  },
                ),
                _buildBonusOption(
                  'Isenção Fiscal', 
                  Icons.account_balance, 
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    simulationService.addBusinessBonus('tax_exemption', 0.05);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Você ganhou uma isenção fiscal de 5%!')),
                    );
                  },
                ),
                _buildBonusOption(
                  'Marketing', 
                  Icons.trending_up, 
                  Colors.orange,
                  () {
                    Navigator.pop(context);
                    simulationService.addBusinessBonus('marketing', 0.1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Você ganhou um impulso de marketing de 10%!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBonusOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: AppTheme.lightTextColor)),
        ],
      ),
    );
  }
  
  void _showBusinessDialog(SimulationService simulationService) {
    final business = simulationService.business!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: RPGText(
          text: 'Gerenciar ${business.name}',
          style: TextStyle(color: AppTheme.goldAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha uma ação para seu negócio:',
              style: TextStyle(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 16),
            _buildBusinessAction(
              'Investir',
              Icons.trending_up,
              'Invista dinheiro para aumentar seus lucros',
              () {
                Navigator.pop(context);
                _advanceMonth(simulationService);
              },
            ),
            const SizedBox(height: 8),
            _buildBusinessAction(
              'Expandir',
              Icons.store,
              'Expanda seu negócio para novos mercados',
              () {
                Navigator.pop(context);
                _advanceMonth(simulationService);
              },
            ),
            const SizedBox(height: 8),
            _buildBusinessAction(
              'Marketing',
              Icons.campaign,
              'Invista em marketing para aumentar suas vendas',
              () {
                Navigator.pop(context);
                _advanceMonth(simulationService);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar', style: TextStyle(color: AppTheme.lightTextColor)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBusinessAction(String title, IconData icon, String description, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.goldAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppTheme.lightTextColor, fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(color: AppTheme.lightTextColor.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.goldAccent, size: 16),
          ],
        ),
      ),
    );
  }
  
  // Helper methods
  void _advanceMonth(SimulationService simulationService) {
    simulationService.advanceMonth();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Avançando para o próximo mês...')),
    );
  }
}