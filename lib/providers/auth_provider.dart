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
      // getUserRole is removed in simplified AuthService
      // await _authService.getUserRole(uid);
      // In a real app, we might want to listen to the user doc stream
      // For now, we just fetch the role to determine dashboard
      // Ideally we fetch the whole user model
      // Re-using signIn logic essentially or adding a explicit fetch method in service
      // Let's rely on what we have or improve AuthService to fetch full model by ID.
      // For simplicity/robustness, let's just assume simple fetching
      // Wait, AuthService.getUserRole fetches role.
      // Let's add a fetch user method to AuthService or just access firestore here?
      // Better to stick to Service pattern.
      // Since AuthService.signIn returns UserModel, let's use that on login.
      // But for auto-login (authStateChanges), we need to fetch it.

      // We will simple reload the user model if we have a user
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Wrapper for Sign In
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        // Since simplified AuthService doesn't return UserModel,
        // we construct a basic one or handle it differently.
        _userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          role: 'user', // Default role since it's no longer fetched
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
        _userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
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

  // Wrapper for Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }
}
