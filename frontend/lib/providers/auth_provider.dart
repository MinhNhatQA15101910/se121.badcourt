import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/models/user.dart';

class AuthProvider extends ChangeNotifier {
  Widget _authForm = LoginForm();
  String _resentEmail = "";
  Widget _previousForm = LoginForm();
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
  String get resentEmail => _resentEmail;
  Widget get previousForm => _previousForm;
  User get signUpUser => _signUpUser;

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
}
