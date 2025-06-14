import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User.empty();

  User get user => _user;

  void setUser(String? userJson) {
    if (userJson == null || userJson.trim().isEmpty) {
      _user = User.empty();
    } else {
      final Map<String, dynamic> userMap = json.decode(userJson);
      _user = User.fromJson(userMap); // ✅ sử dụng fromJson(Map)
    }
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
