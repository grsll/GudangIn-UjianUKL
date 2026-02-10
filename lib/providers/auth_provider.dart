import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserModel? _userModel;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    _init();
  }

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAdmin => _userModel?.role == 'admin';

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final role = await _authService.getUserRole(uid);
      if (role != null) {
        // If we have an existing model, update it, otherwise create new
        if (_userModel != null) {
          _userModel = UserModel(
            uid: _userModel!.uid,
            email: _userModel!.email,
            name: _userModel!.name,
            role: role,
            createdAt: _userModel!.createdAt,
          );
        } else {
          // Need basic info if model is null, try getting from auth service current user if matches
          final currentUser = _authService.currentUser;
          if (currentUser != null && currentUser.uid == uid) {
            _userModel = UserModel(
              uid: uid,
              email: currentUser.email ?? '',
              name: currentUser.displayName ?? '',
              role: role,
              createdAt: DateTime.now(), // approximation
            );
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // Wrapper for Sign In
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        final role = await _authService.getUserRole(user.uid);
        _userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          role: role ?? 'user',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Wrapper for Sign Up
  Future<void> signUp(
    String email,
    String password,
    String name,
    String role,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.registerWithEmail(email, password);
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );
        // PERSIST TO FIRESTORE
        await _authService.saveUserProfile(newUser);
        _userModel = newUser;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Wrapper for Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  // Wrapper for Admin Create User
  Future<void> createUserByAdmin(
    String email,
    String password,
    String name, {
    String role = 'user',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.createUserByAdmin(email, password, name, role: role);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Ensure Default Admin
  Future<void> ensureDefaultAdmin() async {
    await _authService.ensureDefaultAdmin();
  }
}
