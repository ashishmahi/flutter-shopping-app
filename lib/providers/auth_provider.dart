import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/providers/network_exception.dart';

class AuthProvider extends ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userID;
  Timer _authTimer;

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userID;
  }

  bool get isAuthenticate {
    return token != null;
  }

  Future<void> signUp(String email, String password) async {
    return authenticate(email, password, "signUp");
  }

  Future<void> logIn(String email, String password) async {
    return authenticate(email, password, "signInWithPassword");
  }

  Future<void> authenticate(String email, String password, String path) async {
    const API_KEY = String.fromEnvironment("API_KEY");
    print("API_KEY");
    print(API_KEY);
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$path?key=$API_KEY");
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw NetworkException(responseData['error']['message']);
      }
      _token = responseData["idToken"];
      _userID = responseData["localId"];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      autoLogout();
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void logout() {
    _token = null;
    _expiryDate = null;
    _userID = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final duration = _expiryDate.difference(DateTime.now());
    _authTimer = Timer(duration, logout);
  }
}
