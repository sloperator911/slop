import 'package:blowjobboard/data/auth_api.dart';
import 'package:blowjobboard/data/result.dart';
import 'package:blowjobboard/data/user.dart';
import 'package:flutter/foundation.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._api);

  final AuthApi _api;

  bool _isAuthenticated = false;
  bool _isSubmitting = false;
  bool _isLoadingProfile = false;
  User? _user;
  String? _errorMessage;
  int _session = 0;

  bool get isAuthenticated => _isAuthenticated;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingProfile => _isLoadingProfile;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _isAuthenticated = await _api.tokens.read() != null;
    notifyListeners();
  }

  Future<void> authenticate(
    String email,
    String password, {
    String? name,
  }) async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = name == null
        ? await _api.login(email, password)
        : await _api.register(email, password, name);

    _isSubmitting = false;
    switch (result) {
      case Ok(value: final user):
        _session++;
        _user = user;
        _isAuthenticated = true;
      case Err(message: final message):
        _errorMessage = message;
    }
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (!_isAuthenticated || _isLoadingProfile) return;

    final session = _session;
    _isLoadingProfile = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _api.me();
    final hasToken = await _api.tokens.read() != null;
    if (session != _session) return;

    _isLoadingProfile = false;
    _isAuthenticated = hasToken;
    switch (result) {
      case Ok(value: final user):
        _user = user;
      case Err(message: final message):
        _errorMessage = message;
        if (!hasToken) _user = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _session++;
    await _api.logout();
    _isAuthenticated = false;
    _isLoadingProfile = false;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
