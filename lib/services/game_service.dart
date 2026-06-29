import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../data/questions_data.dart';
import 'storage_service.dart';

class GameService extends ChangeNotifier {
  Player? _player;
  List<Achievement> _achievements = [];
  Question? _currentQuestion;
  int _currentQuestionIndex = 0;
  int _attempts = 0;
  bool _isLoading = false;

  // Getters
  Player? get player => _player;
  List<Achievement> get achievements => _achievements;
  Question? get currentQuestion => _currentQuestion;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get attempts => _attempts;
  bool get isLoading => _isLoading;
  bool get hasPlayer => _player != null;

  // Initialize game service
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _player = await StorageService.loadPlayer();
      _achievements = await StorageService.loadAchievements();
      
      // If no achievements are loaded, initialize with default achievements
      if (_achievements.isEmpty) {
        _achievements = AchievementsData.allAchievements;
      }
    } catch (e) {
      print('Error initializing game: $e');
      // Initialize with default achievements on error
      _achievements = AchievementsData.allAchievements;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load game data (alias for initialize)
  Future<void> loadGame() async {
    await initialize();
  }

  // Create new player
  Future<bool> createPlayer(String name, String avatarType) async {
    try {
      _player = Player(
        name: name,
        avatarType: avatarType,
        level: 1,
        xp: 0,
        currentModule: 1,
        completedQuestions: [],
        achievements: [],
      );

      final success = await StorageService.savePlayer(_player!);
      if (success) {
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error creating player: $e');
    }
    return false;
  }

  // Start quiz module
  void startQuiz(int module) {
    if (_player == null) return;

    final questions = QuestionsData.getQuestionsByModule(module);
    if (questions.isNotEmpty) {
      _currentQuestionIndex = 0;
      _currentQuestion = questions[0];
      _attempts = 0;
      notifyListeners();
    } else {
      print('No questions found for module $module');
    }
  }

  // Answer question
  Future<GameAnswer> answerQuestion(int selectedAnswer, {Question? question}) async {
    if (_player == null) {
      throw Exception('No player found');
    }

    // Use the provided question or fall back to current question
    final currentQuestion = question ?? _currentQuestion;
    if (currentQuestion == null) {
      throw Exception('No active question');
    }

    _attempts++;
    final isCorrect = selectedAnswer == currentQuestion.correctAnswer;
    
    int xpEarned = 0;
    if (isCorrect) {
      // Calculate XP based on attempts
      switch (_attempts) {
        case 1:
          xpEarned = 150;
          break;
        case 2:
          xpEarned = 100;
          break;
        case 3:
          xpEarned = 50;
          break;
        default:
          xpEarned = 25;
      }

      // Add question to completed list
      final updatedCompleted = List<int>.from(_player!.completedQuestions);
      if (!updatedCompleted.contains(currentQuestion.id)) {
        updatedCompleted.add(currentQuestion.id);
      }

      // Update player XP and level
      final newXP = _player!.xp + xpEarned;
      final newLevel = (newXP / 500).floor() + 1;

      _player = _player!.copyWith(
        xp: newXP,
        level: newLevel,
        completedQuestions: updatedCompleted,
      );

      // Check for achievements
      await _checkAchievements();

      // Save player progress
      await StorageService.savePlayer(_player!);
    }

    final answer = GameAnswer(
      questionId: currentQuestion.id,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      attempts: _attempts,
      xpEarned: xpEarned,
    );

    notifyListeners();
    return answer;
  }

  // Move to next question
  bool nextQuestion() {
    if (_currentQuestion == null) return false;

    final questions = QuestionsData.getQuestionsByModule(_currentQuestion!.module);
    _currentQuestionIndex++;

    if (_currentQuestionIndex < questions.length) {
      _currentQuestion = questions[_currentQuestionIndex];
      _attempts = 0;
      notifyListeners();
      return true;
    } else {
      // Module completed
      _currentQuestion = null;
      _currentQuestionIndex = 0;
      _attempts = 0;
      notifyListeners();
      return false;
    }
  }

  // Check and unlock achievements
  Future<void> _checkAchievements() async {
    if (_player == null) return;

    List<Achievement> updatedAchievements = List.from(_achievements);
    bool hasNewAchievements = false;

    // First question achievement
    if (_player!.completedQuestions.length == 1) {
      final achievement = updatedAchievements.firstWhere(
        (a) => a.id == 'first_question',
        orElse: () => Achievement(id: '', title: '', description: '', icon: ''),
      );
      if (achievement.id.isNotEmpty && !achievement.unlocked) {
        updatedAchievements = updatedAchievements.map((a) {
          if (a.id == 'first_question') {
            return a.copyWith(unlocked: true);
          }
          return a;
        }).toList();
        hasNewAchievements = true;
      }
    }

    // Module completion achievements
    final module1Questions = QuestionsData.getQuestionsByModule(1);
    final module2Questions = QuestionsData.getQuestionsByModule(2);
    
    final module1Completed = module1Questions.every(
      (q) => _player!.completedQuestions.contains(q.id),
    );
    final module2Completed = module2Questions.every(
      (q) => _player!.completedQuestions.contains(q.id),
    );

    if (module1Completed) {
      final achievement = updatedAchievements.firstWhere(
        (a) => a.id == 'module_1_complete',
        orElse: () => Achievement(id: '', title: '', description: '', icon: ''),
      );
      if (achievement.id.isNotEmpty && !achievement.unlocked) {
        updatedAchievements = updatedAchievements.map((a) {
          if (a.id == 'module_1_complete') {
            return a.copyWith(unlocked: true);
          }
          return a;
        }).toList();
        hasNewAchievements = true;
      }
    }

    if (module2Completed) {
      final achievement = updatedAchievements.firstWhere(
        (a) => a.id == 'module_2_complete',
        orElse: () => Achievement(id: '', title: '', description: '', icon: ''),
      );
      if (achievement.id.isNotEmpty && !achievement.unlocked) {
        updatedAchievements = updatedAchievements.map((a) {
          if (a.id == 'module_2_complete') {
            return a.copyWith(unlocked: true);
          }
          return a;
        }).toList();
        hasNewAchievements = true;
      }
    }

    // Level achievements
    if (_player!.level >= 10) {
      final achievement = updatedAchievements.firstWhere(
        (a) => a.id == 'level_10',
        orElse: () => Achievement(id: '', title: '', description: '', icon: ''),
      );
      if (achievement.id.isNotEmpty && !achievement.unlocked) {
        updatedAchievements = updatedAchievements.map((a) {
          if (a.id == 'level_10') {
            return a.copyWith(unlocked: true);
          }
          return a;
        }).toList();
        hasNewAchievements = true;
      }
    }

    // Tax legend achievement
    if (module1Completed && module2Completed && _player!.level >= 20) {
      final achievement = updatedAchievements.firstWhere(
        (a) => a.id == 'tax_legend',
        orElse: () => Achievement(id: '', title: '', description: '', icon: ''),
      );
      if (achievement.id.isNotEmpty && !achievement.unlocked) {
        updatedAchievements = updatedAchievements.map((a) {
          if (a.id == 'tax_legend') {
            return a.copyWith(unlocked: true);
          }
          return a;
        }).toList();
        hasNewAchievements = true;
      }
    }

    if (hasNewAchievements) {
      _achievements = updatedAchievements;
      await StorageService.saveAchievements(_achievements);
    }
  }

  // Get module progress
  double getModuleProgress(int module) {
    if (_player == null) return 0.0;
    
    final questions = QuestionsData.getQuestionsByModule(module);
    final completedInModule = questions.where(
      (q) => _player!.completedQuestions.contains(q.id),
    ).length;
    
    return questions.isEmpty ? 0.0 : completedInModule / questions.length;
  }

  // Check if module is completed
  bool isModuleCompleted(int module) {
    return getModuleProgress(module) >= 1.0;
  }

  // Reset game progress
  Future<bool> resetProgress() async {
    try {
      final success = await StorageService.clearAllData();
      if (success) {
        _player = null;
        _achievements = AchievementsData.allAchievements;
        _currentQuestion = null;
        _currentQuestionIndex = 0;
        _attempts = 0;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error resetting progress: $e');
    }
    return false;
  }

  // Reset game progress but keep the existing player (name/avatar)
  Future<bool> resetProgressKeepPlayer() async {
    try {
      if (_player == null) {
        // Try to load existing player from storage first
        _player = await StorageService.loadPlayer();
        if (_player == null) return false;
      }

      final preservedName = _player!.name;
      final preservedAvatar = _player!.avatarType;

      _player = Player(
        name: preservedName,
        avatarType: preservedAvatar,
        level: 1,
        xp: 0,
        currentModule: 1,
        completedQuestions: [],
        achievements: [],
      );

      // Reset in-memory state
      _achievements = AchievementsData.allAchievements;
      _currentQuestion = null;
      _currentQuestionIndex = 0;
      _attempts = 0;

      // Persist the reset player
      final saved = await StorageService.savePlayer(_player!);
      if (!saved) return false;

      // Also update the per-user progress snapshot if we have a username
      try {
        final storageService = StorageService();
        final currentUser = await storageService.loadData('current_user');
        if (currentUser != null && currentUser.toString().isNotEmpty) {
          await saveUserProgress(currentUser.toString());
        }
      } catch (_) {}

      notifyListeners();
      return true;
    } catch (e) {
      print('Error resetting progress while keeping player: $e');
      return false;
    }
  }

  // User Progress Tracking Methods
  
  // Save user progress
  Future<bool> saveUserProgress(String username) async {
    if (_player == null) return false;
    
    try {
      final storageService = StorageService();
      final progressData = {
        'username': username,
        'player_name': _player!.name,
        'player_avatar': _player!.avatarType,
        'level': _player!.level,
        'xp': _player!.xp,
        'current_module': _player!.currentModule,
        'total_score': _player!.xp,
        'completed_questions': _player!.completedQuestions,
        'modules_completed': _getCompletedModules(),
        'achievements': _achievements.where((a) => a.unlocked).map((a) => a.id).toList(),
        'last_played': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await storageService.saveData('user_progress_$username', progressData);
      return true;
    } catch (e) {
      print('Error saving user progress: $e');
      return false;
    }
  }

  // Load user progress
  Future<bool> loadUserProgress(String username) async {
    try {
      final storageService = StorageService();
      final progressData = await storageService.loadData('user_progress_$username');
      
      if (progressData != null) {
        // Restore player data
        _player = Player(
          name: progressData['player_name'] ?? username,
          avatarType: progressData['player_avatar'] ?? 'warrior',
          level: progressData['level'] ?? 1,
          xp: progressData['xp'] ?? 0,
          currentModule: progressData['current_module'] ?? 1,
          completedQuestions: List<int>.from((progressData['completed_questions'] ?? []).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).where((e) => e > 0)),
          achievements: List<String>.from(progressData['achievements'] ?? []),
        );
        
        // Update achievements
        final unlockedAchievementIds = List<String>.from(progressData['achievements'] ?? []);
        _achievements = AchievementsData.allAchievements.map((a) {
          return a.copyWith(unlocked: unlockedAchievementIds.contains(a.id));
        }).toList();
        
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }
    return false;
  }

  // Get completed modules list
  List<int> _getCompletedModules() {
    if (_player == null) return [];
    
    List<int> completedModules = [];
    for (int module = 1; module <= 4; module++) { // Assuming 4 modules
      if (isModuleCompleted(module)) {
        completedModules.add(module);
      }
    }
    return completedModules;
  }

  // Get current user from storage
  Future<String?> getCurrentUser() async {
    try {
      final storageService = StorageService();
      return await storageService.loadData('current_user');
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Update user progress after quiz completion
  Future<void> updateUserProgressAfterQuiz(String username, int moduleCompleted, int score) async {
    try {
      final storageService = StorageService();
      final progressData = await storageService.loadData('user_progress_$username');
      
      if (progressData != null) {
        final updatedProgress = Map<String, dynamic>.from(progressData);
        
        // Update total score
        updatedProgress['total_score'] = (updatedProgress['total_score'] ?? 0) + score;
        
        // Add completed module if not already present
        final completedModules = List<int>.from(updatedProgress['modules_completed'] ?? []);
        if (!completedModules.contains(moduleCompleted)) {
          completedModules.add(moduleCompleted);
          updatedProgress['modules_completed'] = completedModules;
        }
        
        // Update player data
        if (_player != null) {
          updatedProgress['level'] = _player!.level;
          updatedProgress['xp'] = _player!.xp;
          updatedProgress['current_module'] = _player!.currentModule;
          updatedProgress['completed_questions'] = _player!.completedQuestions;
          updatedProgress['achievements'] = _achievements.where((a) => a.unlocked).map((a) => a.id).toList();
        }
        
        updatedProgress['last_played'] = DateTime.now().toIso8601String();
        
        await storageService.saveData('user_progress_$username', updatedProgress);
      }
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }
}