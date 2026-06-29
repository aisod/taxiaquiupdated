import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../models/simulation_models.dart';
import '../widgets/rpg_ui_components.dart';
import '../theme.dart';


import 'business_simulation_page.dart';

class BusinessCreationPage extends StatefulWidget {
  const BusinessCreationPage({super.key});

  @override
  State<BusinessCreationPage> createState() => _BusinessCreationPageState();
}

class _BusinessCreationPageState extends State<BusinessCreationPage> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  // Use theme colors for background
  List<Color> get _backgroundColors => [
    AppTheme.primaryBlue, // Use theme primary color
    AppTheme.secondaryPurple, // Use theme secondary color
  ];
  
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  
  String _selectedAvatar = 'merchant';
  BusinessType _selectedBusinessType = BusinessType.retail;
  int _currentStep = 0;
  bool _isLoading = false;
  
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
    _playerNameController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          title: Text(
            'Crie seu Império de Negócios', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildCurrentStepContent(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCharacterSelectionStep();
      case 1:
        return _buildBusinessTypeSelectionStep();
      case 2:
        return _buildFinalDetailsStep();
      default:
        return Center(child: Text('Passo desconhecido'));
    }
  }
  
  Widget _buildCharacterSelectionStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Character selection header with card-like design
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightBackground, // Use theme background
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Escolha seu Personagem',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione um personagem para representar você no mundo dos negócios!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.brown.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Character options in a grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              _buildAvatarOption('merchant', 'Empresário'),
              _buildAvatarOption('executive', 'Executivo'),
              _buildAvatarOption('entrepreneur', 'Empreendedor'),
              _buildAvatarOption('manager', 'Gerente'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Player name input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _playerNameController,
              decoration: InputDecoration(
                labelText: 'Seu Nome',
                hintText: 'Como devemos te chamar?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Next button
          _buildColorfulButton(
            'Próximo',
            onPressed: () {
              if (_playerNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, digite seu nome!')),
                );
                return;
              }
              setState(() {
                _currentStep = 1;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarOption(String avatarType, String label) {
    final isSelected = _selectedAvatar == avatarType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = avatarType;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: RPGAvatar(
                avatarType: avatarType,
                glowing: false,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBusinessTypeSelectionStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Business type header with card-like design
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8D0A7), // Tan color like in reference
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Tipo de Negócio',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cada tipo de negócio tem diferentes regras fiscais e desafios!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.brown.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Business type options
          _buildBusinessTypeOption(
            BusinessType.retail,
            'Loja de Varejo',
            'Venda de produtos para consumidores finais. IVA padrão de 14%.',
            "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgzMjV8&ixlib=rb-4.1.0&q=80&w=1080",
          ),
          
          _buildBusinessTypeOption(
            BusinessType.service,
            'Prestador de Serviços',
            'Ofereça serviços para outras empresas ou consumidores. Impostos específicos para serviços.',
            "https://images.unsplash.com/photo-1514782831304-632d84503f6f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgzMjV8&ixlib=rb-4.1.0&q=80&w=1080",
          ),
          
          _buildBusinessTypeOption(
            BusinessType.import,
            'Importação/Exportação',
            'Importe e exporte produtos. Taxas alfandegárias e regras especiais.',
            "https://images.unsplash.com/photo-1728463102879-6fdb1f7c8090?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgzMjZ8&ixlib=rb-4.1.0&q=80&w=1080",
          ),
          
          _buildBusinessTypeOption(
            BusinessType.production,
            'Fábrica',
            'Produza seus próprios produtos. Incentivos fiscais para indústrias.',
            "https://images.unsplash.com/photo-1605812911011-7fdfff97d762?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDk5NjgzMjZ8&ixlib=rb-4.1.0&q=80&w=1080",
          ),
          
          const SizedBox(height: 24),
          
          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: _buildColorfulButton(
                  'Voltar',
                  color: Colors.grey.shade400,
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildColorfulButton(
                  'Próximo',
                  onPressed: () {
                    setState(() {
                      _currentStep = 2;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBusinessTypeOption(
    BusinessType type,
    String title,
    String description,
    String imageUrl,
  ) {
    final isSelected = _selectedBusinessType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBusinessType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: isSelected
                  ? Icon(Icons.check_circle, color: Colors.white)
                  : Icon(Icons.circle_outlined, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFinalDetailsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Business setup header with card-like design
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8D0A7), // Tan color like in reference
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Seu Império de Negócios',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quase pronto! Dê um nome ao seu negócio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.brown.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Business preview card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: RPGAvatar(
                        avatarType: _selectedAvatar,
                        glowing: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _playerNameController.text.isEmpty ? 'Seu Nome' : _playerNameController.text,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getBusinessTypeName(_selectedBusinessType),
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Business name input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Seu Negócio',
                      hintText: 'Ex: Loja do João, Serviços Tech, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Starting capital display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capital Inicial:',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '500.000 Kz',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: _buildColorfulButton(
                  'Voltar',
                  color: Colors.grey.shade400,
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildColorfulButton(
                  'Começar!',
                  onPressed: _createBusiness,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorfulButton(String label, {required VoidCallback onPressed, Color? color}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: color != null
            ? null
            : LinearGradient(
                colors: [
                  const Color(0xFF9C27B0),
                  const Color(0xFF673AB7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (color ?? Colors.purple).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getBusinessTypeName(BusinessType type) {
    switch (type) {
      case BusinessType.retail:
        return 'Loja de Varejo';
      case BusinessType.service:
        return 'Prestador de Serviços';
      case BusinessType.import:
        return 'Importação/Exportação';
      case BusinessType.production:
        return 'Fábrica';
      default:
        return 'Negócio';
    }
  }
  
  void _createBusiness() async {
    if (_businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, dê um nome ao seu negócio!')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final simulationService = Provider.of<SimulationService>(context, listen: false);
      
      // Create the business
      final business = Business(
        name: _businessNameController.text.trim(),
        type: _selectedBusinessType,
      );
      
      // Create the player profile
      final player = SimulationPlayer(
        name: _playerNameController.text.trim(),
        avatarType: _selectedAvatar,
        business: business,
      );
      
      // Initialize the game with the new player and business
      await simulationService.initializePlayer(player);
      
      // Navigate to the main game screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BusinessSimulationPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar negócio: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}