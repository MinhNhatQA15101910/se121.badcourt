import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';

class AuthFormProvider extends ChangeNotifier {
  Widget _authForm = LoginForm();

  Widget get authForm => _authForm;

  void setForm(Widget authForm) {
    _authForm = authForm;
    notifyListeners();
  }
}
