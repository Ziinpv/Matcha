import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blocked_user.dart';

class BlocklistService extends ChangeNotifier {
  static const String _blocklistKey = 'blocked_users';
  
  List<BlockedUser> _blockedUsers = [];
  
  List<BlockedUser> get blockedUsers => List.unmodifiable(_blockedUsers);
  
  int get blockedCount => _blockedUsers.length;
  
  BlocklistService() {
    _loadBlocklist();
  }
  
  Future<void> _loadBlocklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blocklistJson = prefs.getString(_blocklistKey);
      
      if (blocklistJson != null) {
        final List<dynamic> blocklistList = json.decode(blocklistJson);
        _blockedUsers = blocklistList
            .map((json) => BlockedUser.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading blocklist: $e');
    }
  }
  
  Future<void> _saveBlocklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blocklistJson = json.encode(
        _blockedUsers.map((user) => user.toJson()).toList(),
      );
      await prefs.setString(_blocklistKey, blocklistJson);
    } catch (e) {
      debugPrint('Error saving blocklist: $e');
    }
  }
  
  Future<bool> blockUser({
    required String id,
    required String username,
    required String email,
    String? profileImageUrl,
    String? reason,
  }) async {
    try {
      // Kiểm tra xem user đã bị chặn chưa
      if (isUserBlocked(id)) {
        return false; // User đã bị chặn
      }
      
      final blockedUser = BlockedUser(
        id: id,
        username: username,
        email: email,
        profileImageUrl: profileImageUrl,
        blockedAt: DateTime.now(),
        reason: reason,
      );
      
      _blockedUsers.add(blockedUser);
      await _saveBlocklist();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error blocking user: $e');
      return false;
    }
  }
  
  Future<bool> unblockUser(String userId) async {
    try {
      final initialLength = _blockedUsers.length;
      _blockedUsers.removeWhere((user) => user.id == userId);
      
      if (_blockedUsers.length < initialLength) {
        await _saveBlocklist();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      return false;
    }
  }
  
  bool isUserBlocked(String userId) {
    return _blockedUsers.any((user) => user.id == userId);
  }
  
  BlockedUser? getBlockedUser(String userId) {
    try {
      return _blockedUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
  
  List<BlockedUser> searchBlockedUsers(String query) {
    if (query.isEmpty) return _blockedUsers;
    
    final lowercaseQuery = query.toLowerCase();
    return _blockedUsers.where((user) {
      return user.username.toLowerCase().contains(lowercaseQuery) ||
             user.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  Future<void> clearAllBlockedUsers() async {
    try {
      _blockedUsers.clear();
      await _saveBlocklist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing blocklist: $e');
    }
  }
}
