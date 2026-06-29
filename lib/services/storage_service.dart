import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import '../models/simulation_models.dart';
import '../data/questions_data.dart';

class StorageService {
  static const String _playerKey = 'tax_aqui_player';
  static const String _achievementsKey = 'tax_aqui_achievements';
  static const String _simulationPlayerKey = 'tax_aqui_simulation_player';
  static const String _gameStatePrefix = 'tax_aqui_game_state_';

  static Future<Player?> loadPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = prefs.getString(_playerKey);
      if (playerJson != null) {
        final playerData = jsonDecode(playerJson);
        return Player.fromJson(playerData);
      }
    } catch (e) {
      print('Error loading player: $e');
    }
    return null;
  }

  static Future<bool> savePlayer(Player player) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = jsonEncode(player.toJson());
      return await prefs.setString(_playerKey, playerJson);
    } catch (e) {
      print('Error saving player: $e');
      return false;
    }
  }

  static Future<List<Achievement>> loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);
      if (achievementsJson != null) {
        final List<dynamic> achievementsData = jsonDecode(achievementsJson);
        final unlockedIds = achievementsData.cast<String>();
        
        return AchievementsData.allAchievements.map((achievement) {
          return achievement.copyWith(
            unlocked: unlockedIds.contains(achievement.id),
          );
        }).toList();
      }
    } catch (e) {
      print('Error loading achievements: $e');
    }
    return AchievementsData.allAchievements;
  }

  static Future<bool> saveAchievements(List<Achievement> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlockedIds = achievements
          .where((a) => a.unlocked)
          .map((a) => a.id)
          .toList();
      final achievementsJson = jsonEncode(unlockedIds);
      return await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('Error saving achievements: $e');
      return false;
    }
  }

  static Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playerKey);
      await prefs.remove(_achievementsKey);
      await prefs.remove(_simulationPlayerKey);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
  
  // Simulation model methods
  static Future<SimulationPlayer?> loadSimulationPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = prefs.getString(_simulationPlayerKey);
      if (playerJson != null) {
        final playerData = jsonDecode(playerJson);
        return SimulationPlayer.fromJson(playerData);
      }
    } catch (e) {
      print('Error loading simulation player: $e');
    }
    return null;
  }

  static Future<bool> saveSimulationPlayer(SimulationPlayer player) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = jsonEncode(player.toJson());
      return await prefs.setString(_simulationPlayerKey, playerJson);
    } catch (e) {
      print('Error saving simulation player: $e');
      return false;
    }
  }
  
  // Generic data storage methods
  Future<bool> saveData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String jsonData;
      if (data is String) {
        jsonData = data;
      } else {
        jsonData = jsonEncode(data);
      }
      return await prefs.setString(_gameStatePrefix + key, jsonData);
    } catch (e) {
      print('Error saving data for $key: $e');
      return false;
    }
  }
  
  Future<dynamic> loadData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_gameStatePrefix + key);
      if (jsonData != null) {
        try {
          return jsonDecode(jsonData);
        } catch (e) {
          // If it's not valid JSON, return as string
          return jsonData;
        }
      }
    } catch (e) {
      print('Error loading data for $key: $e');
    }
    return null;
  }
  
  Future<Map<String, dynamic>?> getData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_gameStatePrefix + key);
      if (jsonData != null) {
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading data for $key: $e');
    }
    return null;
  }
}