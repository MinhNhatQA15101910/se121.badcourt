import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';

class AuthFormProvider extends ChangeNotifier {
  Widget _authForm = LoginForm();
  String _resentEmail = "";
  Widget _previousForm = LoginForm();

  Widget get authForm => _authForm;
  String get resentEmail => _resentEmail;
  Widget get previousForm => _previousForm;

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
}
