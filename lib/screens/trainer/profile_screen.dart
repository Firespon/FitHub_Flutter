import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isEditing = false;
  late String uid;
  Map<String, dynamic>? trainerData;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTrainerData();
  }

  Future<void> fetchTrainerData() async {
    final user = _auth.currentUser;
    if (user != null) {
      uid = user.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        trainerData = doc.data();
        _usernameController.text = trainerData?['username'] ?? '';
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> updateUsername() async {
    await _firestore.collection('users').doc(uid).update({
      'username': _usernameController.text.trim(),
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Username updated')));
    setState(() {
      _isEditing = false;
      trainerData?['username'] = _usernameController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trainer Profile')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : trainerData == null
              ? Center(child: Text('No profile data found.'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Username",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _isEditing
                        ? TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Enter new username',
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(trainerData?['username'] ?? '-'),
                        ),
                    SizedBox(height: 16),

                    Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(trainerData?['email'] ?? '-'),
                    ),
                    SizedBox(height: 16),

                    Text(
                      "Full Name",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${trainerData?['firstName'] ?? ''} ${trainerData?['lastName'] ?? ''}',
                      ),
                    ),
                    SizedBox(height: 16),

                    Text(
                      "Contact",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(trainerData?['contact'] ?? '-'),
                    ),
                    SizedBox(height: 16),

                    Text(
                      "Gender",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(trainerData?['gender'] ?? '-'),
                    ),
                    SizedBox(height: 24),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isEditing = !_isEditing);
                          },
                          child: Text(_isEditing ? 'Cancel' : 'Edit Username'),
                        ),
                        SizedBox(width: 12),
                        if (_isEditing)
                          ElevatedButton.icon(
                            onPressed: updateUsername,
                            icon: Icon(Icons.save),
                            label: Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
