import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _user;

  bool get isLoggedIn => _user != null;
  UserModel? get user => _user;

  Future<void> login(String email, String password) async {
    // TEMP: Simula login (reemplazar con llamada real a API)
    await Future.delayed(Duration(seconds: 2));
    _user = UserModel(email: email, token: 'fake-jwt-token');
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
