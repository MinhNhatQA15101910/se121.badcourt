import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/models/user.dart';

class AuthProvider extends ChangeNotifier {
  Widget _authForm = LoginForm();
  Widget? _previousForm = LoginForm();
  bool _isPlayer = false;
  String _resentEmail = "";
  String _password = "";
  String _authToken = "";
  User _signUpUser = User.empty();

  // Getters
  Widget get authForm => _authForm;
  Widget? get previousForm => _previousForm;
  String get resentEmail => _resentEmail;
  String get password => _password;
  String get authToken => _authToken;
  User get signUpUser => _signUpUser;
  bool get isPlayer => _isPlayer;

  // Setters
  void setForm(Widget authForm) {
    _authForm = authForm;
    notifyListeners();
  }

  void setResentEmail(String resentEmail) {
    _resentEmail = resentEmail;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setPreviousForm(Widget? previousForm) {
    _previousForm = previousForm;
    notifyListeners();
  }

  void setSignUpUser(User user) {
    _signUpUser = user;
  }

  void setIsPlayer(bool isPlayer) {
    _isPlayer = isPlayer;
  }

  void setAuthToken(String token) {
    _authToken = token;
    notifyListeners();
  }
}
