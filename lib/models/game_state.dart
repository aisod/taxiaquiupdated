class Player {
  final String name;
  final int level;
  final int xp;
  final int currentModule;
  final List<int> completedQuestions;
  final List<String> achievements;
  final String avatarType;

  Player({
    required this.name,
    this.level = 1,
    this.xp = 0,
    this.currentModule = 1,
    this.completedQuestions = const [],
    this.achievements = const [],
    this.avatarType = 'warrior',
  });

  Player copyWith({
    String? name,
    int? level,
    int? xp,
    int? currentModule,
    List<int>? completedQuestions,
    List<String>? achievements,
    String? avatarType,
  }) {
    return Player(
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      currentModule: currentModule ?? this.currentModule,
      completedQuestions: completedQuestions ?? this.completedQuestions,
      achievements: achievements ?? this.achievements,
      avatarType: avatarType ?? this.avatarType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'xp': xp,
      'currentModule': currentModule,
      'completedQuestions': completedQuestions,
      'achievements': achievements,
      'avatarType': avatarType,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] ?? '',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      currentModule: json['currentModule'] ?? 1,
      completedQuestions: List<int>.from(json['completedQuestions'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      avatarType: json['avatarType'] ?? 'warrior',
    );
  }

  String get title {
    if (level >= 20) return 'Lenda da AGT';
    if (level >= 16) return 'Mestre dos Tributos';
    if (level >= 11) return 'Cavaleiro Aduaneiro';
    if (level >= 6) return 'Guardião dos Impostos';
    return 'Aprendiz Fiscal';
  }

  int get xpToNextLevel => (level * 500) - xp;
  double get levelProgress => (xp % 500) / 500.0;
}

class Question {
  final int id;
  final int module;
  final String text;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final int xpReward;

  Question({
    required this.id,
    required this.module,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.xpReward = 150,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final int xpBonus;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.xpBonus = 0,
  });

  Achievement copyWith({bool? unlocked}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      xpBonus: xpBonus,
    );
  }
}

class GameAnswer {
  final int questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int attempts;
  final int xpEarned;

  GameAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.attempts,
    required this.xpEarned,
  });
}