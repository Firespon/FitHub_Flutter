import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'login_screen.dart';

class TrainerRegisterScreen extends StatefulWidget {
  @override
  _TrainerRegisterScreenState createState() => _TrainerRegisterScreenState();
}

class _TrainerRegisterScreenState extends State<TrainerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  String firstName = '';
  String lastName = '';
  String username = '';
  String email = '';
  String contact = '';
  String? gender;
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;
  String? error;

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final additionalData = {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.trim(),
      'contact': contact.trim(),
      'gender': gender,
      'role': 'trainer',
    };

    final result = await _firebaseService.registerUser(
      email: email.trim(),
      password: password.trim(),
      additionalData: additionalData,
    );

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trainer registered successfully!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      setState(() => error = result);
    }

    setState(() => isLoading = false);
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged, {
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
        ),
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Trainer Register")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        "First Name",
                        (v) => firstName = v,
                        validator:
                            (v) => v!.isEmpty ? 'Enter first name' : null,
                      ),
                      _buildTextField(
                        "Last Name",
                        (v) => lastName = v,
                        validator: (v) => v!.isEmpty ? 'Enter last name' : null,
                      ),
                      _buildTextField(
                        "Username",
                        (v) => username = v,
                        validator: (v) => v!.isEmpty ? 'Enter username' : null,
                      ),
                      _buildTextField(
                        "Email",
                        (v) => email = v,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter email';
                          if (!v.contains('@') || !v.contains('.'))
                            return 'Enter valid email';
                          return null;
                        },
                      ),
                      _buildTextField(
                        "Contact Number",
                        (v) => contact = v,
                        keyboardType: TextInputType.phone,
                        validator:
                            (v) => v!.isEmpty ? 'Enter contact number' : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Gender",
                            border: OutlineInputBorder(),
                          ),
                          value: gender,
                          onChanged: (val) => setState(() => gender = val),
                          validator:
                              (val) => val == null ? 'Select gender' : null,
                          items:
                              ['Male', 'Female']
                                  .map(
                                    (g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      _buildTextField(
                        "Password",
                        (v) => password = v,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter password';
                          if (v.length < 6) return 'Minimum 6 characters';
                          if (!RegExp(
                            r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
                          ).hasMatch(v)) {
                            return 'Include letters and numbers';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password must include both letters and numbers",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ),
                      _buildTextField(
                        "Confirm Password",
                        (v) => confirmPassword = v,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Confirm your password';
                          if (v != password) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            error!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: register,
                        child: Text("Register"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
