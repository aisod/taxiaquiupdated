import 'package:flutter/material.dart';

/// Business represents the player's company in the simulation
class Business {
  final String name;
  final BusinessType type;
  double cashBalance;
  double revenue;
  double expenses;
  double taxLiability;
  List<TaxPayment> taxHistory;
  List<BusinessEvent> eventHistory;
  int monthsInOperation;
  Map<String, double> taxRates;
  
  Business({
    required this.name,
    required this.type,
    this.cashBalance = 500000, // 500,000 Kz starting capital
    this.revenue = 0,
    this.expenses = 0,
    this.taxLiability = 0,
    this.taxHistory = const [],
    this.eventHistory = const [],
    this.monthsInOperation = 0,
    this.taxRates = const {
      'iva': 0.14,      // VAT
      'irt': 0.0,       // Income tax (varies by income)
      'property': 0.05, // Property tax
      'import': 0.10,   // Import duties
    },
  });

  /// Calculates profit after expenses but before taxes
  double get grossProfit => revenue - expenses;
  
  /// Calculates profit after all expenses and taxes
  double get netProfit => grossProfit - taxLiability;
  
  /// Determines the current tax bracket for IRT
  double calculateIRTRate() {
    if (grossProfit <= 840000) return 0.0;      // Up to 70,000 Kz monthly
    if (grossProfit <= 1680000) return 0.10;    // Up to 140,000 Kz monthly
    if (grossProfit <= 2400000) return 0.13;    // Up to 200,000 Kz monthly
    if (grossProfit <= 3600000) return 0.16;    // Up to 300,000 Kz monthly
    return 0.24;                               // Above 300,000 Kz monthly
  }
  
  /// Updates tax rates based on business type and performance
  void updateTaxRates() {
    taxRates = {
      'iva': 0.14,                // Fixed VAT rate
      'irt': calculateIRTRate(),  // Progressive income tax
      'property': type == BusinessType.retail ? 0.04 : 0.05, // Lower for retail
      'import': type == BusinessType.import ? 0.08 : 0.10,   // Lower for import businesses
    };
  }

  /// Creates a copy of the business with updated values
  Business copyWith({
    String? name,
    BusinessType? type,
    double? cashBalance,
    double? revenue,
    double? expenses,
    double? taxLiability,
    List<TaxPayment>? taxHistory,
    List<BusinessEvent>? eventHistory,
    int? monthsInOperation,
    Map<String, double>? taxRates,
  }) {
    return Business(
      name: name ?? this.name,
      type: type ?? this.type,
      cashBalance: cashBalance ?? this.cashBalance,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      taxLiability: taxLiability ?? this.taxLiability,
      taxHistory: taxHistory ?? this.taxHistory,
      eventHistory: eventHistory ?? this.eventHistory,
      monthsInOperation: monthsInOperation ?? this.monthsInOperation,
      taxRates: taxRates ?? this.taxRates,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString(),
      'cashBalance': cashBalance,
      'revenue': revenue,
      'expenses': expenses,
      'taxLiability': taxLiability,
      'taxHistory': taxHistory.map((tax) => tax.toJson()).toList(),
      'eventHistory': eventHistory.map((event) => event.toJson()).toList(),
      'monthsInOperation': monthsInOperation,
      'taxRates': taxRates,
    };
  }
  
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      name: json['name'] ?? '',
      type: BusinessType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => BusinessType.retail,
      ),
      cashBalance: json['cashBalance'] ?? 500000,
      revenue: json['revenue'] ?? 0,
      expenses: json['expenses'] ?? 0,
      taxLiability: json['taxLiability'] ?? 0,
      taxHistory: (json['taxHistory'] as List?)
          ?.map((e) => TaxPayment.fromJson(e))
          .toList() ?? [],
      eventHistory: (json['eventHistory'] as List?)
          ?.map((e) => BusinessEvent.fromJson(e))
          .toList() ?? [],
      monthsInOperation: json['monthsInOperation'] ?? 0,
      taxRates: Map<String, double>.from(json['taxRates'] ?? {}),
    );
  }
}

/// Available business types with different tax implications
enum BusinessType {
  retail,     // Retail store (standard IVA)
  service,    // Service provider (different tax structure)
  import,     // Import/export (customs duties)
  production, // Manufacturing (tax incentives)
}

/// Represents a tax payment made by the player
class TaxPayment {
  final String taxType;
  final double amount;
  final DateTime datePaid;
  final bool onTime;
  final String description;
  
  TaxPayment({
    required this.taxType,
    required this.amount,
    required this.datePaid,
    required this.onTime,
    required this.description,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'taxType': taxType,
      'amount': amount,
      'datePaid': datePaid.toIso8601String(),
      'onTime': onTime,
      'description': description,
    };
  }
  
  factory TaxPayment.fromJson(Map<String, dynamic> json) {
    return TaxPayment(
      taxType: json['taxType'] ?? '',
      amount: json['amount'] ?? 0.0,
      datePaid: DateTime.parse(json['datePaid']),
      onTime: json['onTime'] ?? false,
      description: json['description'] ?? '',
    );
  }
}

/// Business events that can occur during gameplay
class BusinessEvent {
  final String title;
  final String description;
  final EventType type;
  final Map<String, dynamic> effects;
  final DateTime dateOccurred;
  final List<String> choices;
  final String playerChoice;
  
  BusinessEvent({
    required this.title,
    required this.description,
    required this.type,
    required this.effects,
    required this.dateOccurred,
    this.choices = const [],
    this.playerChoice = '',
  });
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString(),
      'effects': effects,
      'dateOccurred': dateOccurred.toIso8601String(),
      'choices': choices,
      'playerChoice': playerChoice,
    };
  }
  
  factory BusinessEvent.fromJson(Map<String, dynamic> json) {
    return BusinessEvent(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: EventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => EventType.taxChange,
      ),
      effects: Map<String, dynamic>.from(json['effects'] ?? {}),
      dateOccurred: DateTime.parse(json['dateOccurred']),
      choices: List<String>.from(json['choices'] ?? []),
      playerChoice: json['playerChoice'] ?? '',
    );
  }
}

/// Types of events that can affect the business
enum EventType {
  taxChange,      // Changes to tax laws
  audit,          // Tax audit by authorities
  opportunity,    // Business opportunity
  marketChange,   // Market conditions changing
  randomEvent,    // Random event (good or bad)
}

/// Player profile for the simulation game
class SimulationPlayer {
  final String name;
  final String avatarType;
  final int level;
  final int xp;
  final List<String> achievements;
  final Business business;
  
  SimulationPlayer({
    required this.name,
    required this.avatarType,
    this.level = 1,
    this.xp = 0,
    this.achievements = const [],
    required this.business,
  });
  
  SimulationPlayer copyWith({
    String? name,
    String? avatarType,
    int? level,
    int? xp,
    List<String>? achievements,
    Business? business,
  }) {
    return SimulationPlayer(
      name: name ?? this.name,
      avatarType: avatarType ?? this.avatarType,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      achievements: achievements ?? this.achievements,
      business: business ?? this.business,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarType': avatarType,
      'level': level,
      'xp': xp,
      'achievements': achievements,
      'business': business.toJson(),
    };
  }
  
  factory SimulationPlayer.fromJson(Map<String, dynamic> json) {
    return SimulationPlayer(
      name: json['name'] ?? '',
      avatarType: json['avatarType'] ?? 'merchant',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      business: Business.fromJson(json['business'] ?? {}),
    );
  }
  
  String get title {
    if (level >= 20) return 'Magnata Fiscal';
    if (level >= 16) return 'Empresário Exemplar';
    if (level >= 11) return 'Tycoon Angolano';
    if (level >= 6) return 'Comerciante Próspero';
    return 'Empreendedor Iniciante';
  }
  
  int get xpToNextLevel => (level * 500) - xp;
  double get levelProgress => (xp % 500) / 500.0;
}

/// Represents a tax filing that the player must complete
class TaxFiling {
  final String taxType;
  final DateTime dueDate;
  final double estimatedAmount;
  bool filed;
  DateTime? filingDate;
  double? filedAmount;
  String explanation;
  
  TaxFiling({
    required this.taxType,
    required this.dueDate,
    required this.estimatedAmount,
    this.filed = false,
    this.filingDate,
    this.filedAmount,
    this.explanation = '',
  });
  
  /// Checks if the filing is overdue
  bool get isOverdue => !filed && DateTime.now().isAfter(dueDate);
  
  /// Calculates late penalties if applicable
  double calculatePenalty() {
    if (!isOverdue) return 0;
    
    // Calculate days late
    final daysLate = DateTime.now().difference(dueDate).inDays;
    
    // Angola typically charges 2% for the first 30 days, then 1% per month
    if (daysLate <= 30) {
      return estimatedAmount * 0.02;
    } else {
      final monthsLate = (daysLate / 30).ceil();
      return estimatedAmount * (0.02 + (monthsLate - 1) * 0.01);
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'taxType': taxType,
      'dueDate': dueDate.toIso8601String(),
      'estimatedAmount': estimatedAmount,
      'filed': filed,
      'filingDate': filingDate?.toIso8601String(),
      'filedAmount': filedAmount,
      'explanation': explanation,
    };
  }
  
  factory TaxFiling.fromJson(Map<String, dynamic> json) {
    return TaxFiling(
      taxType: json['taxType'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      estimatedAmount: json['estimatedAmount'] ?? 0.0,
      filed: json['filed'] ?? false,
      filingDate: json['filingDate'] != null ? DateTime.parse(json['filingDate']) : null,
      filedAmount: json['filedAmount'],
      explanation: json['explanation'] ?? '',
    );
  }
}