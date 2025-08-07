import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'login_screen.dart';
import 'register_trainer_screen.dart';

class RegisterCustomerScreen extends StatefulWidget {
  @override
  _RegisterCustomerScreenState createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  String? _error;

  void _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final additionalData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': 'customer',
    };

    final result = await _firebaseService.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      additionalData: additionalData,
    );

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User registered successfully!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      setState(() => _error = result);
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    ThemeData theme, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('FitHub Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/fithub_logo.png', height: 100),
            SizedBox(height: 20),
            _buildTextField(_firstNameController, "First Name", theme),
            _buildTextField(_lastNameController, "Last Name", theme),
            _buildTextField(
              _phoneController,
              "Phone Number",
              theme,
              keyboard: TextInputType.phone,
            ),
            _buildTextField(_emailController, "Email", theme),
            _buildTextField(
              _passwordController,
              "Password",
              theme,
              obscure: true,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _register,
                  child: Text('Register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text('Already have an account? Login here'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => TrainerRegisterScreen()),
                );
              },
              child: Text('Register as a Trainer'),
            ),
          ],
        ),
      ),
    );
  }
}
