import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/simulation_models.dart';
import 'storage_service.dart';

class SimulationService extends ChangeNotifier {
  SimulationPlayer? _player;
  Business? _business;
  List<TaxFiling> _pendingFilings = [];
  List<BusinessEvent> _currentEvents = [];
  bool _isLoading = false;
  int _gameMonth = 1;
  int _gameYear = 2023;
  
  // Game state
  bool _isBusinessClosed = false;
  bool _isAuditInProgress = false;
  bool _isGamePaused = false;
  
  // Getters
  SimulationPlayer? get player => _player;
  Business? get business => _business;
  List<TaxFiling> get pendingFilings => _pendingFilings;
  List<BusinessEvent> get currentEvents => _currentEvents;
  bool get isLoading => _isLoading;
  bool get hasPlayer => _player != null;
  int get gameMonth => _gameMonth;
  int get gameYear => _gameYear;
  bool get isBusinessClosed => _isBusinessClosed;
  bool get isAuditInProgress => _isAuditInProgress;
  

  
  // Method to add a business bonus (for board game rewards)
  void addBusinessBonus(String bonusType, double value) {
    if (_business == null) return;
    
    switch (bonusType) {
      case 'cash':
        _business = _business!.copyWith(
          cashBalance: _business!.cashBalance + value,
        );
        break;
      case 'tax_exemption':
        // Apply a tax discount for the next month
        final updatedRates = Map<String, double>.from(_business!.taxRates);
        updatedRates.forEach((key, rate) {
          updatedRates[key] = rate * (1 - value);
        });
        _business = _business!.copyWith(taxRates: updatedRates);
        break;
      case 'marketing':
        // Increase revenue for the next month
        _business = _business!.copyWith(
          revenue: _business!.revenue * (1 + value),
        );
        break;
    }
    
    notifyListeners();
    saveState();
  }
  
  // Initialize a new player
  Future<void> initializePlayer(SimulationPlayer player) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _player = player;
      _business = player.business;
      
      // Generate initial tax filings
      _generateInitialTaxFilings();
      
      // Generate initial events
      _generateInitialEvents();
      
      await saveState();
    } catch (e) {
      print('Error initializing player: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Generate initial tax filings for a new business
  void _generateInitialTaxFilings() {
    final now = DateTime.now();
    
    // IVA (VAT) filing - monthly
    _pendingFilings.add(TaxFiling(
      taxType: 'IVA (Imposto sobre Valor Acrescentado)',
      dueDate: DateTime(now.year, now.month + 1, 15),
      estimatedAmount: _business!.revenue * _business!.taxRates['iva']!,
      explanation: 'O IVA é cobrado sobre o valor acrescentado em cada etapa da produção e distribuição de bens e serviços. A taxa padrão em Angola é de 14%.',
    ));
    
    // IRT (Income tax) - quarterly for simplicity
    if (now.month % 3 == 0) {
      _pendingFilings.add(TaxFiling(
        taxType: 'IRT (Imposto sobre o Rendimento do Trabalho)',
        dueDate: DateTime(now.year, now.month + 1, 30),
        estimatedAmount: _business!.grossProfit * _business!.taxRates['irt']!,
        explanation: 'O IRT é um imposto que incide sobre os rendimentos do trabalho. As taxas variam de 0% a 24%, dependendo do nível de renda.',
      ));
    }
  }
  
  // Generate initial business events
  void _generateInitialEvents() {
    final now = DateTime.now();
    
    // Welcome event
    _currentEvents.add(BusinessEvent(
      title: 'Bem-vindo ao seu novo negócio!',
      description: 'Você acaba de abrir seu negócio em Angola. Prepare-se para gerenciar operações, impostos e muito mais enquanto constrói seu império!',
      type: EventType.opportunity,
      effects: {'morale': 10},
      dateOccurred: now,
    ));
    
    // Tax introduction event
    _currentEvents.add(BusinessEvent(
      title: 'Sistema Tributário de Angola',
      description: 'É importante conhecer os principais impostos: IVA (14%), IRT (imposto de renda), Imposto Predial, e Direitos Aduaneiros para importações. Mantenha suas obrigações fiscais em dia!',
      type: EventType.taxChange,
      effects: {'knowledge': 5},
      dateOccurred: now,
      choices: ['Aprender mais', 'Contratar contador'],
    ));
  }
  
  // Save current game state to local storage
  Future<void> saveState() async {
    if (_player == null || _business == null) return;
    
    try {
      // Update business in player object
      _player = _player!.copyWith(business: _business);
      
      // Save player data to storage
      final storage = StorageService();
      await storage.saveData('player_data', _player!.toJson());
      
      // Save game state data
      final gameState = {
        'gameMonth': _gameMonth,
        'gameYear': _gameYear,
        'pendingFilings': _pendingFilings.map((filing) => filing.toJson()).toList(),
        'currentEvents': _currentEvents.map((event) => event.toJson()).toList(),
        'isBusinessClosed': _isBusinessClosed,
        'isAuditInProgress': _isAuditInProgress,
        'isGamePaused': _isGamePaused,
      };
      
      await storage.saveData('game_state', gameState);
    } catch (e) {
      print('Error saving game state: $e');
    }
  }
  
  // Load saved game state from local storage
  Future<void> loadState() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final storage = StorageService();
      
      // Load player data
      final playerData = await storage.getData('player_data');
      if (playerData != null) {
        _player = SimulationPlayer.fromJson(playerData);
        _business = _player!.business;
      }
      
      // Load game state data
      final gameStateData = await storage.getData('game_state');
      if (gameStateData != null) {
        _gameMonth = gameStateData['gameMonth'] ?? 1;
        _gameYear = gameStateData['gameYear'] ?? 2023;
        _isBusinessClosed = gameStateData['isBusinessClosed'] ?? false;
        _isAuditInProgress = gameStateData['isAuditInProgress'] ?? false;
        _isGamePaused = gameStateData['isGamePaused'] ?? false;
        
        // Load pending filings
        _pendingFilings = (gameStateData['pendingFilings'] as List?)
            ?.map((e) => TaxFiling.fromJson(e))
            .toList() ?? [];
            
        // Load current events
        _currentEvents = (gameStateData['currentEvents'] as List?)
            ?.map((e) => BusinessEvent.fromJson(e))
            .toList() ?? [];
      }
    } catch (e) {
      print('Error loading game state: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  

  

  

  
  String get currentDate => '$_gameMonth/$_gameYear';
  
  // Initialize simulation service
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load saved game data if available
      _player = await StorageService.loadSimulationPlayer();
      if (_player != null) {
        _business = _player!.business;
        _generatePendingFilings();
      }
    } catch (e) {
      print('Error initializing simulation: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Create new player and business
  Future<bool> createBusinessAndPlayer(String playerName, String avatarType, String businessName, BusinessType businessType) async {
    try {
      // Create new business
      final business = Business(
        name: businessName,
        type: businessType,
      );
      
      // Create new player with business
      _player = SimulationPlayer(
        name: playerName,
        avatarType: avatarType,
        business: business,
      );
      
      _business = business;
      
      // Generate initial tax filings
      _generatePendingFilings();
      
      // Save to storage
      await StorageService.saveSimulationPlayer(_player!);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating business: $e');
      return false;
    }
  }
  
  // Advance game by one month
  Future<void> advanceMonth() async {
    if (_business == null || _isGamePaused) return;
    
    // Update game calendar
    _gameMonth++;
    if (_gameMonth > 12) {
      _gameMonth = 1;
      _gameYear++;
    }
    
    // Update business stats
    _business!.monthsInOperation++;
    
    // Generate monthly revenue and expenses
    final baseRevenue = _generateMonthlyRevenue();
    final baseExpenses = _generateMonthlyExpenses();
    
    // Apply any event effects
    double revenueMultiplier = 1.0;
    double expensesMultiplier = 1.0;
    
    for (final event in _currentEvents) {
      if (event.effects.containsKey('revenueMultiplier')) {
        revenueMultiplier *= event.effects['revenueMultiplier'];
      }
      if (event.effects.containsKey('expensesMultiplier')) {
        expensesMultiplier *= event.effects['expensesMultiplier'];
      }
    }
    
    final adjustedRevenue = baseRevenue * revenueMultiplier;
    final adjustedExpenses = baseExpenses * expensesMultiplier;
    
    // Update business finances
    _business = _business!.copyWith(
      revenue: _business!.revenue + adjustedRevenue,
      expenses: _business!.expenses + adjustedExpenses,
      cashBalance: _business!.cashBalance + adjustedRevenue - adjustedExpenses,
    );
    
    // Calculate taxes
    _calculateTaxes();
    
    // Check for bankruptcy
    if (_business!.cashBalance < 0) {
      _isBusinessClosed = true;
      _addBusinessEvent(
        'Falência',
        'Sua empresa faliu devido à falta de fundos. Você pode começar um novo negócio ou tentar restaurar este.',
        EventType.marketChange,
        {'businessClosed': true},
      );
    }
    
    // Trigger random events (30% chance each month)
    if (Random().nextDouble() < 0.3) {
      _triggerRandomEvent();
    }
    
    // Check for tax filings due this month
    _checkDueFilings();
    
    // Random tax audit (5% chance each month)
    if (Random().nextDouble() < 0.05) {
      _triggerTaxAudit();
    }
    
    // Update player with new business data
    _player = _player!.copyWith(business: _business);
    
    // Save game
    await StorageService.saveSimulationPlayer(_player!);
    
    notifyListeners();
  }
  
  // Generate monthly revenue based on business type and months in operation
  double _generateMonthlyRevenue() {
    if (_business == null) return 0;
    
    // Base revenue depends on business type
    double baseRevenue = 0;
    switch (_business!.type) {
      case BusinessType.retail:
        baseRevenue = 350000; // 350,000 Kz base for retail
        break;
      case BusinessType.service:
        baseRevenue = 300000; // 300,000 Kz base for service
        break;
      case BusinessType.import:
        baseRevenue = 500000; // 500,000 Kz base for import/export
        break;
      case BusinessType.production:
        baseRevenue = 400000; // 400,000 Kz base for production
        break;
    }
    
    // Adjust based on months in operation (growth over time)
    final growthFactor = min(1.5, 1 + (_business!.monthsInOperation * 0.02));
    
    // Add some randomness (±20%)
    final randomFactor = 0.8 + (Random().nextDouble() * 0.4); // Between 0.8 and 1.2
    
    return baseRevenue * growthFactor * randomFactor;
  }
  
  // Generate monthly expenses
  double _generateMonthlyExpenses() {
    if (_business == null) return 0;
    
    // Base expenses depend on business type
    double baseExpenses = 0;
    switch (_business!.type) {
      case BusinessType.retail:
        baseExpenses = 250000; // 250,000 Kz base for retail
        break;
      case BusinessType.service:
        baseExpenses = 200000; // 200,000 Kz base for service
        break;
      case BusinessType.import:
        baseExpenses = 350000; // 350,000 Kz base for import/export
        break;
      case BusinessType.production:
        baseExpenses = 300000; // 300,000 Kz base for production
        break;
    }
    
    // Add some randomness (±15%)
    final randomFactor = 0.85 + (Random().nextDouble() * 0.3); // Between 0.85 and 1.15
    
    return baseExpenses * randomFactor;
  }
  
  // Calculate taxes based on business performance
  void _calculateTaxes() {
    if (_business == null) return;
    
    // Update tax rates based on current business performance
    _business!.updateTaxRates();
    
    // Monthly IVA calculation (14% of revenue)
    final monthlyIva = _business!.revenue * _business!.taxRates['iva']!;
    
    // Add to tax liability
    _business = _business!.copyWith(
      taxLiability: _business!.taxLiability + monthlyIva,
    );
  }
  
  // Generate tax filings that will be due
  void _generatePendingFilings() {
    if (_business == null) return;
    
    // Clear existing filings
    _pendingFilings = [];
    
    // IVA (Monthly)
    final ivaFiling = TaxFiling(
      taxType: 'IVA (Imposto sobre Valor Acrescentado)',
      dueDate: DateTime(_gameYear, _gameMonth + 1, 15), // Due on the 15th of next month
      estimatedAmount: _business!.revenue * _business!.taxRates['iva']!,
      explanation: 'O IVA é um imposto indireto que incide sobre o consumo de bens e serviços. A taxa padrão em Angola é de 14%. Empresas devem declarar e pagar mensalmente até o dia 15 do mês seguinte.',
    );
    
    // IRT (Quarterly)
    if (_gameMonth % 3 == 0) { // Every 3 months
      final irtFiling = TaxFiling(
        taxType: 'IRT (Imposto sobre os Rendimentos do Trabalho)',
        dueDate: DateTime(_gameYear, _gameMonth + 1, 30), // End of next month
        estimatedAmount: _business!.grossProfit * _business!.taxRates['irt']!,
        explanation: 'O IRT é um imposto que incide sobre os rendimentos do trabalho. Para empresas, aplica-se uma taxa progressiva sobre os lucros. A declaração e pagamento são feitos trimestralmente.',
      );
      _pendingFilings.add(irtFiling);
    }
    
    // Property Tax (Annual)
    if (_gameMonth == 12) { // December
      final propertyTaxFiling = TaxFiling(
        taxType: 'Imposto Predial',
        dueDate: DateTime(_gameYear + 1, 1, 31), // January 31 of next year
        estimatedAmount: 200000 * _business!.taxRates['property']!, // Assuming property value
        explanation: 'O Imposto Predial incide sobre imóveis urbanos, com taxas que variam de 0.1% a 0.5% sobre o valor patrimonial. Este imposto é declarado e pago anualmente.',
      );
      _pendingFilings.add(propertyTaxFiling);
    }
    
    // Import Duties (only for import businesses, random)
    if (_business!.type == BusinessType.import && Random().nextDouble() < 0.3) {
      final importValue = 100000 + (Random().nextDouble() * 400000); // Random import value
      final importTaxFiling = TaxFiling(
        taxType: 'Direitos Aduaneiros',
        dueDate: DateTime(_gameYear, _gameMonth, 28), // End of current month
        estimatedAmount: importValue * _business!.taxRates['import']!,
        explanation: 'Direitos Aduaneiros são impostos que incidem sobre a importação de mercadorias. As taxas variam conforme o tipo de produto e podem ir de 2% até 70%. O pagamento é feito no momento do despacho aduaneiro.',
      );
      _pendingFilings.add(importTaxFiling);
    }
    
    // Always add IVA filing
    _pendingFilings.add(ivaFiling);
    
    notifyListeners();
  }
  
  // Check for filings that are due
  void _checkDueFilings() {
    final now = DateTime(_gameYear, _gameMonth, 15); // Mid-month checkpoint
    
    for (final filing in _pendingFilings) {
      if (now.isAfter(filing.dueDate) && !filing.filed) {
        // Filing is overdue, apply penalties
        final penalty = filing.calculatePenalty();
        
        _addBusinessEvent(
          'Multa Fiscal',
          'Você não submeteu a declaração de ${filing.taxType} a tempo. Uma multa de ${penalty.toStringAsFixed(2)} Kz foi aplicada.',
          EventType.taxChange,
          {'penalty': penalty},
        );
        
        // Deduct penalty from cash balance
        _business = _business!.copyWith(
          cashBalance: _business!.cashBalance - penalty,
        );
      }
    }
    
    // Generate new filings for the next period
    _generatePendingFilings();
  }
  
  // Handle filing submission by player
  Future<bool> submitTaxFiling(TaxFiling filing, double declaredAmount) async {
    if (_business == null) return false;
    
    // Mark filing as completed
    final filingIndex = _pendingFilings.indexOf(filing);
    if (filingIndex == -1) return false;
    
    _pendingFilings[filingIndex].filed = true;
    _pendingFilings[filingIndex].filedAmount = declaredAmount;
    _pendingFilings[filingIndex].filingDate = DateTime.now();
    
    // Deduct the tax amount from cash balance
    _business = _business!.copyWith(
      cashBalance: _business!.cashBalance - declaredAmount,
      taxLiability: _business!.taxLiability - declaredAmount,
    );
    
    // Add to tax history
    final newPayment = TaxPayment(
      taxType: filing.taxType,
      amount: declaredAmount,
      datePaid: DateTime.now(),
      onTime: !filing.isOverdue,
      description: 'Pagamento de ${filing.taxType} para o período ${_gameMonth-1}/$_gameYear',
    );
    
    List<TaxPayment> updatedHistory = List.from(_business!.taxHistory);
    updatedHistory.add(newPayment);
    
    _business = _business!.copyWith(taxHistory: updatedHistory);
    
    // Award XP for filing taxes correctly and on time
    int xpGained = 0;
    
    // Check if the declared amount is close to the estimated amount (±10%)
    final estimatedAmount = filing.estimatedAmount;
    final lowerBound = estimatedAmount * 0.9;
    final upperBound = estimatedAmount * 1.1;
    
    if (declaredAmount >= lowerBound && declaredAmount <= upperBound) {
      // Correct filing
      xpGained += 50;
      
      if (!filing.isOverdue) {
        // On-time bonus
        xpGained += 25;
      }
    } else if (declaredAmount < lowerBound) {
      // Underdeclared (potential audit risk)
      _addBusinessEvent(
        'Risco de Auditoria',
        'Você declarou um valor muito abaixo do esperado para ${filing.taxType}. Isso aumenta suas chances de ser auditado.',
        EventType.taxChange,
        {'auditRiskIncrease': 0.2},
      );
    }
    
    // Update player XP
    if (xpGained > 0) {
      final newXp = _player!.xp + xpGained;
      final newLevel = _calculateLevelFromXp(newXp);
      
      _player = _player!.copyWith(
        xp: newXp,
        level: newLevel,
        business: _business,
      );
      
      if (newLevel > _player!.level) {
        // Level up!
        _addBusinessEvent(
          'Nível Aumentado!',
          'Parabéns! Você alcançou o nível ${newLevel} com sua perícia em gestão fiscal!',
          EventType.opportunity,
          {'levelUp': newLevel},
        );
      }
    } else {
      _player = _player!.copyWith(business: _business);
    }
    
    // Save game
    await StorageService.saveSimulationPlayer(_player!);
    
    notifyListeners();
    return true;
  }
  
  // Calculate level based on XP
  int _calculateLevelFromXp(int xp) {
    return (xp / 500).floor() + 1;
  }
  
  // Trigger a random business event
  void _triggerRandomEvent() {
    if (_business == null) return;
    
    final eventType = Random().nextInt(5);
    
    switch (eventType) {
      case 0:
        // Tax law change
        _addBusinessEvent(
          'Mudança na Legislação Fiscal',
          'O governo angolano alterou a taxa de IVA temporariamente para estimular a economia.',
          EventType.taxChange,
          {'taxRateChange': -0.02}, // 2% reduction in tax rate
        );
        break;
      
      case 1:
        // Market opportunity
        _addBusinessEvent(
          'Oportunidade de Mercado',
          'Um novo contrato foi oferecido à sua empresa. Isso aumentará sua receita, mas também suas obrigações fiscais.',
          EventType.opportunity,
          {'revenueMultiplier': 1.2, 'taxLiabilityMultiplier': 1.1},
        );
        break;
      
      case 2:
        // Economic downturn
        _addBusinessEvent(
          'Desaceleração Econômica',
          'Uma recessão local está afetando os negócios em Angola. Suas receitas serão temporariamente reduzidas.',
          EventType.marketChange,
          {'revenueMultiplier': 0.8},
        );
        break;
      
      case 3:
        // Supplier issue
        _addBusinessEvent(
          'Problema com Fornecedor',
          'Seu principal fornecedor aumentou os preços. Seus custos aumentarão temporariamente.',
          EventType.randomEvent,
          {'expensesMultiplier': 1.15},
        );
        break;
      
      case 4:
        // Tax incentive
        _addBusinessEvent(
          'Incentivo Fiscal',
          'O governo angolano anunciou um programa de incentivos fiscais para empresas do seu setor.',
          EventType.taxChange,
          {'taxRateChange': -0.03}, // 3% tax rate reduction
        );
        break;
    }
  }
  
  // Trigger a tax audit
  void _triggerTaxAudit() {
    if (_business == null || _isAuditInProgress) return;
    
    _isAuditInProgress = true;
    
    _addBusinessEvent(
      'Auditoria Fiscal',
      'A Administração Geral Tributária (AGT) iniciou uma auditoria fiscal na sua empresa. Eles estão revisando suas declarações fiscais dos últimos períodos.',
      EventType.audit,
      {'auditInProgress': true},
    );
    
    // Check for underpayment in tax history
    bool foundUnderpayment = false;
    double totalPenalty = 0;
    
    for (final payment in _business!.taxHistory.take(5)) { // Check last 5 payments
      // 30% chance to find an issue with each payment
      if (Random().nextDouble() < 0.3) {
        foundUnderpayment = true;
        
        // Calculate penalty (20-50% of original payment)
        final penalty = payment.amount * (0.2 + (Random().nextDouble() * 0.3));
        totalPenalty += penalty;
      }
    }
    
    // Schedule audit result for next month
    Future.delayed(Duration(seconds: 10), () {
      if (foundUnderpayment) {
        _addBusinessEvent(
          'Resultado da Auditoria',
          'A auditoria encontrou irregularidades em suas declarações fiscais. Uma multa de ${totalPenalty.toStringAsFixed(2)} Kz foi aplicada.',
          EventType.audit,
          {'penalty': totalPenalty},
        );
        
        // Apply penalty
        _business = _business!.copyWith(
          cashBalance: _business!.cashBalance - totalPenalty,
        );
      } else {
        _addBusinessEvent(
          'Resultado da Auditoria',
          'A auditoria fiscal foi concluída sem encontrar irregularidades. Sua empresa está em conformidade com as leis fiscais de Angola.',
          EventType.audit,
          {'complianceBonus': 100}, // XP bonus for good compliance
        );
        
        // Award XP for passing audit
        _player = _player!.copyWith(
          xp: _player!.xp + 100,
          business: _business,
        );
      }
      
      _isAuditInProgress = false;
      notifyListeners();
    });
  }
  
  // Add a business event to history
  void _addBusinessEvent(String title, String description, EventType type, Map<String, dynamic> effects) {
    if (_business == null) return;
    
    final newEvent = BusinessEvent(
      title: title,
      description: description,
      type: type,
      effects: effects,
      dateOccurred: DateTime.now(),
    );
    
    // Add to current events
    _currentEvents.add(newEvent);
    
    // Add to business history
    List<BusinessEvent> updatedHistory = List.from(_business!.eventHistory);
    updatedHistory.add(newEvent);
    
    _business = _business!.copyWith(eventHistory: updatedHistory);
    
    notifyListeners();
  }
  
  // Player makes a business decision for an event
  Future<void> makeBusinessDecision(BusinessEvent event, String choice) async {
    if (_business == null) return;
    
    final eventIndex = _currentEvents.indexOf(event);
    if (eventIndex == -1) return;
    
    // Apply effects based on choice
    switch (choice) {
      case 'accept':
        // Apply full effects
        break;
      case 'reject':
        // Reduce or negate effects
        break;
      case 'negotiate':
        // Partial effects
        break;
    }
    
    // Remove from current events
    _currentEvents.removeAt(eventIndex);
    
    // Update event in history with player's choice
    for (int i = 0; i < _business!.eventHistory.length; i++) {
      if (_business!.eventHistory[i].title == event.title &&
          _business!.eventHistory[i].dateOccurred == event.dateOccurred) {
        final updatedEvent = BusinessEvent(
          title: event.title,
          description: event.description,
          type: event.type,
          effects: event.effects,
          dateOccurred: event.dateOccurred,
          choices: event.choices,
          playerChoice: choice,
        );
        
        List<BusinessEvent> updatedHistory = List.from(_business!.eventHistory);
        updatedHistory[i] = updatedEvent;
        
        _business = _business!.copyWith(eventHistory: updatedHistory);
        break;
      }
    }
    
    // Update player with new business data
    _player = _player!.copyWith(business: _business);
    
    // Save game
    await StorageService.saveSimulationPlayer(_player!);
    
    notifyListeners();
  }
  
  // Get educational content about a specific tax type
  String getTaxEducationalContent(String taxType) {
    switch (taxType) {
      case 'IVA':
        return '''
O Imposto sobre o Valor Acrescentado (IVA) em Angola:

• Taxa padrão: 14%
• Introduzido em: Outubro de 2019
• Substituiu: O Imposto de Consumo
• Declaração: Mensal (até dia 15 do mês seguinte)
• Isenções: Bens da cesta básica, medicamentos, serviços médicos

O IVA é um imposto indireto sobre o consumo, sendo cobrado no momento da venda. As empresas atuam como coletoras deste imposto, repassando-o ao governo. É importante manter registros detalhados de todas as transações sujeitas ao IVA para declarações precisas.''';
      
      case 'IRT':
        return '''
O Imposto sobre os Rendimentos do Trabalho (IRT) em Angola:

• Taxas: Progressivas de 0% a 25%
• Aplicação: Rendimentos do trabalho e lucros empresariais
• Isenção: Rendimentos até 70.000 Kz mensais
• Declaração: Trimestral para empresas

Para empresas, o IRT incide sobre os lucros com taxas progressivas. É essencial calcular corretamente o lucro tributável, aplicando as deduções permitidas por lei. O não cumprimento pode resultar em multas significativas.''';
      
      case 'Imposto Predial':
        return '''
O Imposto Predial em Angola:

• Taxas: Variam de 0,1% a 0,5% do valor patrimonial
• Incidência: Imóveis urbanos e rústicos
• Declaração: Anual
• Responsável: Proprietário do imóvel

Este imposto incide sobre o valor patrimonial dos imóveis. As taxas variam conforme o valor e a utilização do imóvel. Prédios recém-construídos podem beneficiar de isenções temporárias. O pagamento em atraso implica juros e multas.''';
      
      case 'Direitos Aduaneiros':
        return '''
Direitos Aduaneiros em Angola:

• Taxas: Variam de 2% a 70% dependendo do produto
• Base de cálculo: Valor CIF (Custo, Seguro e Frete)
• Declaração: No momento da importação
• Documentos necessários: Fatura comercial, conhecimento de embarque, certificado de origem

Os direitos aduaneiros são aplicados à importação de mercadorias. Certos produtos considerados essenciais podem ter taxas reduzidas ou isenções. É fundamental classificar corretamente as mercadorias para determinar a taxa aplicável.''';
      
      default:
        return 'Informação fiscal não disponível.';
    }
  }
  
  // Get tax tips based on business type
  List<String> getTaxTipsForBusiness() {
    if (_business == null) return [];
    
    List<String> tips = [
      'Mantenha registros detalhados de todas as transações para facilitar declarações fiscais.',
      'Fique atento aos prazos fiscais para evitar multas por atraso.',
      'Consulte um contabilista para otimizar legalmente sua carga tributária.',
    ];
    
    switch (_business!.type) {
      case BusinessType.retail:
        tips.addAll([
          'Empresas de varejo devem manter controle rigoroso do IVA coletado em cada venda.',
          'Verifique se produtos da cesta básica estão corretamente classificados para isenção de IVA.',
          'Mantenha inventário atualizado para justificar o IVA dedutível nas compras.',
        ]);
        break;
      
      case BusinessType.service:
        tips.addAll([
          'Empresas de serviços devem emitir faturas detalhando claramente os serviços prestados.',
          'Alguns serviços especializados podem ter tratamento fiscal diferenciado.',
          'Mantenha contratos de prestação de serviços bem documentados.',
        ]);
        break;
      
      case BusinessType.import:
        tips.addAll([
          'Importadores devem conhecer detalhadamente a Pauta Aduaneira de Angola.',
          'Custos de desembaraço aduaneiro devem ser incluídos nas despesas dedutíveis.',
          'Considere criar um fundo de reserva para flutuações nos direitos aduaneiros.',
        ]);
        break;
      
      case BusinessType.production:
        tips.addAll([
          'Empresas produtoras podem se beneficiar de incentivos fiscais para industrialização.',
          'Mantenha registro detalhado dos insumos para dedução correta do IVA.',
          'Investimentos em maquinário podem ter depreciação acelerada para fins fiscais.',
        ]);
        break;
    }
    
    return tips;
  }
}