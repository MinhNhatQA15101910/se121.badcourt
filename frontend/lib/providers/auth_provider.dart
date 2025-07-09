import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/login_form.dart';
import 'package:frontend/features/auth/widgets/pinput_form.dart';
import 'package:frontend/models/user.dart';

class AuthProvider extends ChangeNotifier {
  Widget _authForm = LoginForm();
  Widget? _previousForm = LoginForm();
  bool _isPlayer = false;
  String _resentEmail = "";
  String _password = "";
  String _authToken = "";
  User _signUpUser = User.empty();
  
  // Thêm properties mới để handle change password flow
  bool _isFromChangePassword = false;
  bool _shouldResetToLogin = false;

  // Getters
  Widget get authForm => _authForm;
  Widget? get previousForm => _previousForm;
  String get resentEmail => _resentEmail;
  String get password => _password;
  String get authToken => _authToken;
  User get signUpUser => _signUpUser;
  bool get isPlayer => _isPlayer;
  bool get isFromChangePassword => _isFromChangePassword;
  bool get shouldResetToLogin => _shouldResetToLogin;

  // Setters
  void setForm(Widget authForm, {bool fromChangePassword = false}) {
    _authForm = authForm;
    _isFromChangePassword = fromChangePassword;
    
    // If setting pinput form from change password, mark it
    if (authForm.runtimeType.toString().contains('Pinput') && fromChangePassword) {
      _isFromChangePassword = true;
    }
    
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
    notifyListeners();
  }

  void setIsPlayer(bool isPlayer) {
    _isPlayer = isPlayer;
    notifyListeners();
  }

  void setAuthToken(String token) {
    _authToken = token;
    notifyListeners();
  }

  // Thêm methods mới để handle reset state
  void resetAuthState() {
    _authForm = LoginForm();
    _previousForm = LoginForm();
    _authToken = '';
    _resentEmail = '';
    _password = '';
    _signUpUser = User.empty();
    _isFromChangePassword = false;
    _shouldResetToLogin = false;
    
    // Reset static variables
    PinputForm.isUserChangePassword = false;
    
    notifyListeners();
  }

  void forceResetToLogin() {
    _authForm = LoginForm();
    _previousForm = LoginForm();
    _isFromChangePassword = false;
    _shouldResetToLogin = false;
    
    // Reset static variables
    PinputForm.isUserChangePassword = false;
    
    notifyListeners();
  }

  void handlePinputBack() {
    if (_isFromChangePassword) {
      // If from change password, reset the flag
      _isFromChangePassword = false;
      PinputForm.isUserChangePassword = false;
    } else {
      // Normal navigation
      if (_previousForm != null) {
        _authForm = _previousForm!;
        _previousForm = LoginForm();
      } else {
        _authForm = LoginForm();
      }
    }
    notifyListeners();
  }

  bool shouldShowLoginForm() {
    return _shouldResetToLogin || 
           (_isFromChangePassword && !PinputForm.isUserChangePassword);
  }

  void initializeAuth() {
    _authForm = LoginForm();
    _previousForm = null;
    _isFromChangePassword = false;
    _shouldResetToLogin = false;
    notifyListeners();
  }
}
