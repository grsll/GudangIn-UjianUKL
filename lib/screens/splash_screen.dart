import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
// import 'dashboard/admin_dashboard.dart';
// import 'dashboard/user_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // We wait for the stream listener in AuthProvider to likely fire
    // But since that's async, we might want to check currentUser directly here for speed
    // Or rely on the provider state if it's already initialized.
    // For simplicity given the simple provider:

    // Actually, the provider init is async.
    // Let's just check the service directly or wait a bit.
    // Better: AuthProvider could have a 'isInitialized' future or similar.
    // For now, let's use a simple approach:
    // If user is null but we just started, we might be loading.

    // Let's defer to the auth provider's state after a brief moment.
    // Or simpler: listen to the stream here?
    // No, let's use the current user from auth service via provider if possible, or direct.

    // Re-evaluating: standard way is checking currentUser.
    // If currentUser is null -> Login
    // If not null -> fetch role -> Dashboard.

    // We can rely on AuthProvider having the user if we wait slightly or if we check explicit instantiation.
    // Let's just redirect to Login for now, and if the user is actually logged in,
    // the AuthProvider will update and we can handle that or we just implement the check here.

    // Implementation:
    // Since AuthProvider listens to authStateChanges, it updates _userModel.
    // But fetching user data takes time.

    // Let's try attempting a silent check/fetch here.

    // Temporary redirect until dashboards are ready
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              'Gudangin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
