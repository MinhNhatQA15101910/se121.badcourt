import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/models/user.dart';

class AuthProvider extends ChangeNotifier {
  Widget _authForm = LoginForm();
  Widget _previousForm = LoginForm();
  bool _isPlayer = false;
  String _resentEmail = "";
  User _signUpUser = User(
    id: '',
    username: '',
    email: '',
    password: '',
    imageUrl: '',
    role: '',
    token: '',
  );

  Widget get authForm => _authForm;
  Widget get previousForm => _previousForm;
  String get resentEmail => _resentEmail;
  User get signUpUser => _signUpUser;
  bool get isPlayer => _isPlayer;

  void setForm(Widget authForm) {
    _authForm = authForm;
    notifyListeners();
  }

  void setResentEmail(String resentEmail) {
    _resentEmail = resentEmail;
    notifyListeners();
  }

  void setPreviousForm(Widget previousForm) {
    _previousForm = previousForm;
    notifyListeners();
  }

  void setSignUpUser(User user) {
    _signUpUser = user;
  }

  void setIsPlayer(bool isPlayer) {
    _isPlayer = isPlayer;
  }
}
