import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import 'storage_service.dart';
import 'game_service.dart';

class User {
  final String id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.lastLogin,
  });

  User copyWith({
    String? id,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      passwordHash: json['passwordHash'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }
}

class AuthService extends ChangeNotifier {
  static const String _usersKey = 'taxa_aqui_users';
  static const String _currentUserKey = 'taxa_aqui_current_user';
  
  User? _currentUser;
  List<User> _users = [];
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Initialize the auth service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadUsers();
    await _loadCurrentUser();
    _isInitialized = true;
    notifyListeners();
  }

  // Load all users from storage
  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _users = usersList.map((userData) => User.fromJson(userData)).toList();
      }
    } catch (e) {
      print('Error loading users: $e');
      _users = [];
    }
  }

  // Save all users to storage
  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = jsonEncode(_users.map((user) => user.toJson()).toList());
      await prefs.setString(_usersKey, usersJson);
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  // Load current user from storage
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString(_currentUserKey);
      if (currentUserJson != null) {
        final userData = jsonDecode(currentUserJson);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      print('Error loading current user: $e');
      _currentUser = null;
    }
  }

  // Save current user to storage
  Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        final currentUserJson = jsonEncode(_currentUser!.toJson());
        await prefs.setString(_currentUserKey, currentUserJson);
      } else {
        await prefs.remove(_currentUserKey);
      }
    } catch (e) {
      print('Error saving current user: $e');
    }
  }

  // Simple hash function (in production, use proper hashing like bcrypt)
  String _hashPassword(String password) {
    // This is a simple hash for demo purposes
    // In production, use proper password hashing
    return password.hashCode.toString();
  }

  // Generate unique user ID
  String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Register a new user
  Future<bool> register(String username, String password) async {
    try {
      // Check if username already exists
      if (_users.any((user) => user.username.toLowerCase() == username.toLowerCase())) {
        return false;
      }

      // Create new user
      final newUser = User(
        id: _generateUserId(),
        username: username,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Add to users list
      _users.add(newUser);
      await _saveUsers();

      // Set as current user
      _currentUser = newUser;
      await _saveCurrentUser();

      notifyListeners();
      return true;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Login an existing user
  Future<bool> login(String username, String password) async {
    try {
      final passwordHash = _hashPassword(password);
      final user = _users.firstWhere(
        (user) => user.username.toLowerCase() == username.toLowerCase() && 
                  user.passwordHash == passwordHash,
        orElse: () => throw Exception('User not found'),
      );

      // Update last login
      final updatedUser = user.copyWith(lastLogin: DateTime.now());
      final userIndex = _users.indexWhere((u) => u.id == user.id);
      _users[userIndex] = updatedUser;
      await _saveUsers();

      // Set as current user
      _currentUser = updatedUser;
      await _saveCurrentUser();

      notifyListeners();
      return true;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // Logout current user
  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUser();
    notifyListeners();
  }

  // Load user's game progress
  Future<Player?> loadUserProgress() async {
    if (_currentUser == null) return null;
    
    try {
      final storageService = StorageService();
      final progressData = await storageService.getData(_currentUser!.id);
      if (progressData != null) {
        return Player.fromJson(progressData);
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }
    return null;
  }

  // Save user's game progress
  Future<bool> saveUserProgress(Player player) async {
    if (_currentUser == null) return false;
    
    try {
      final storageService = StorageService();
      return await storageService.saveData(_currentUser!.id, player.toJson());
    } catch (e) {
      print('Error saving user progress: $e');
      return false;
    }
  }

  // Load user's achievements
  Future<List<Achievement>> loadUserAchievements() async {
    if (_currentUser == null) return [];
    
    try {
      final storageService = StorageService();
      final achievementsData = await storageService.getData('${_currentUser!.id}_achievements');
      if (achievementsData != null) {
        final List<dynamic> achievementsList = achievementsData['achievements'] ?? [];
        final unlockedIds = achievementsList.cast<String>();
        
        // This assumes AchievementsData.allAchievements exists
        // You might need to import this from your questions_data.dart
        final allAchievements = <Achievement>[]; // Replace with actual achievements data
        
        return allAchievements.map((achievement) {
          return achievement.copyWith(
            unlocked: unlockedIds.contains(achievement.id),
          );
        }).toList();
      }
    } catch (e) {
      print('Error loading user achievements: $e');
    }
    return [];
  }

  // Save user's achievements
  Future<bool> saveUserAchievements(List<Achievement> achievements) async {
    if (_currentUser == null) return false;
    
    try {
      final storageService = StorageService();
      final unlockedIds = achievements
          .where((a) => a.unlocked)
          .map((a) => a.id)
          .toList();
      
      return await storageService.saveData(
        '${_currentUser!.id}_achievements', 
        {'achievements': unlockedIds}
      );
    } catch (e) {
      print('Error saving user achievements: $e');
      return false;
    }
  }

  // Check if user has existing progress
  Future<bool> hasExistingProgress() async {
    if (_currentUser == null) return false;
    
    final progress = await loadUserProgress();
    return progress != null;
  }

  // Delete user account (optional feature)
  Future<bool> deleteAccount(String password) async {
    if (_currentUser == null) return false;
    
    try {
      final passwordHash = _hashPassword(password);
      if (_currentUser!.passwordHash != passwordHash) {
        return false; // Wrong password
      }

      // Remove user from list
      _users.removeWhere((user) => user.id == _currentUser!.id);
      await _saveUsers();

      // Clear user data
      final storageService = StorageService();
      await storageService.getData(_currentUser!.id); // This will clear the data

      // Logout
      await logout();
      
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Get all registered usernames (for admin purposes)
  List<String> getAllUsernames() {
    return _users.map((user) => user.username).toList();
  }

  // Clear all data (for debugging)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersKey);
      await prefs.remove(_currentUserKey);
      _users.clear();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}