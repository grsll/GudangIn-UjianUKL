import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 Login Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // 📝 Registrasi Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // 👤 Login Anonim
  Future<User?> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }

  // 🚪 Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 📌 Ambil user saat ini
  User? get currentUser => _auth.currentUser;

  // 👤 Ambil role user dari Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['role'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  // 📝 Simpan profil user ke Firestore
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  // 🛰 Get Auth State Changes (Added for Provider)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 👑 Admin Create User (Secondary App)
  Future<void> createUserByAdmin(
    String email,
    String password,
    String name, {
    String role = 'user',
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // Initialize secondary app to avoid affecting current auth state
      secondaryApp = await Firebase.initializeApp(
        name: 'secondaryApp',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // Create the user
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Save user data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      debugPrint('Error creating user by admin: $e');
      rethrow;
    } finally {
      // Clean up the secondary app
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  // 🛡 Ensure Default Admin exists
  Future<void> ensureDefaultAdmin() async {
    try {
      // Check if any admin exists or specifically our default
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@gudang.in')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        debugPrint('Admin account not found, creating default admin...');
        await createUserByAdmin(
          'admin@gudang.in',
          'admin123',
          'Super Admin',
          role: 'admin',
        );
      }
    } catch (e) {
      debugPrint('Error ensuring default admin: $e');
    }
  }
}

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // 🔐 Login
  Future<void> loginWithEmailPassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = null;
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Navigation will be handled outside
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e.code);
    } finally {
      isLoading = false;
    }
  }

  // 📝 Registrasi
  Future<void> registerWithEmailPassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = null;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Navigation after register can be handled here or outside
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e.code);
    } finally {
      isLoading = false;
    }
  }

  // 🔐 Login Google
  Future<void> loginWithGoogle(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    try {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      if (kIsWeb) {
        await _auth.signInWithPopup(provider);
      } else {
        await _auth.signInWithProvider(provider);
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e.code);
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading = false;
    }
  }

  // 🧾 Pesan Error
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi';
    }
  }
}
