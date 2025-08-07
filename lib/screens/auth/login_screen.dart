import 'package:fithub_user/screens/admin/admin_navigation_screen.dart';
import 'package:fithub_user/screens/customer/navigation_screen.dart';
// import 'package:fithub_user/screens/admin/admin_dashboard.dart';
import 'package:fithub_user/screens/trainer/navigation_screen.dart';
import 'package:fithub_user/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_customer_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Step 1: Static Admin Login
    if (email == 'admin@fithub.com' && password == 'admin123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminNavigationScreen(),
        ), // Replace with AdminDashboard if needed
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Step 2: Regular Firebase Login
    final error = await _firebaseService.loginUser(
      email: email,
      password: password,
    );

    if (error != null) {
      setState(() {
        _error = error;
        _isLoading = false;
      });
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final role = doc['role'];

      Widget targetScreen;
      if (role == 'customer') {
        targetScreen = NavigationScreen();
      } else if (role == 'trainer') {
        targetScreen = TrainerNavigationScreen();
      } else {
        setState(() {
          _error = "Unknown role: $role";
        });
        _isLoading = false;
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } catch (e) {
      setState(() {
        _error = 'Unable to retrieve user role. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('FitHub Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/fithub_logo.png', height: 120),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text('Login'),
                ),
            SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterCustomerScreen()),
                );
              },
              child: Text('Don’t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
