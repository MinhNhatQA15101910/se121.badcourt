import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = const User(
    id: '',
    username: '',
    email: '',
    password: '',
    imageUrl: '',
    role: '',
    token: '',
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}