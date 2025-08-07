import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  late Future<DocumentSnapshot> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture =
        FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null || user == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${user!.uid}.jpg');

      await storageRef.putFile(File(pickedFile.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'photoUrl': downloadUrl});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile picture updated!")));

      setState(() {
        userFuture =
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      });
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile picture.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<DocumentSnapshot>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("My Profile")),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text("My Profile")),
            body: Center(child: Text("Error loading profile")),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String? photoUrl = userData['photoUrl'];

        return Scaffold(
          appBar: AppBar(title: Text("My Profile")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          photoUrl != null
                              ? NetworkImage(
                                "$photoUrl?ts=${DateTime.now().millisecondsSinceEpoch}",
                              )
                              : AssetImage('assets/avatar.png')
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              isDark ? Colors.grey[900] : Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: theme.iconTheme.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "${userData['firstName']} ${userData['lastName']}",
                  style: theme.textTheme.titleLarge,
                ),
                Text(user?.email ?? "", style: theme.textTheme.bodyMedium),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/editProfile');
                  },
                  child: Text('Edit Profile'),
                ),
                Divider(height: 40),
                ListTile(
                  leading: Icon(Icons.bookmark_border),
                  title: Text("My Bookmarks"),
                  subtitle: Text("View saved content"),
                  onTap: () {
                    Navigator.pushNamed(context, '/Bookmarks');
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  icon: Icon(Icons.logout),
                  label: Text("Log Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
