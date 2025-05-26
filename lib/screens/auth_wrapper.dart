import 'package:flutter/material.dart';
import '../utils/token_manager.dart';
import 'main_screen.dart';
import 'login_screen.dart'; // Correct import

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenManager.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    }
  }

  void refreshAuthStatus() {
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE15A46),
          ),
        ),
      );
    }

    return _isLoggedIn ? const MainScreen() : const LoginScreen(); // Correct reference
  }
}