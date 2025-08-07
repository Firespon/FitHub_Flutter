import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart'; // <-- Make sure this import points to your login screen file

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String adminName = 'Admin FitHub';
  String adminEmail = 'admin@example.com';
  String? profileImageUrl;
  String adminUID = 'UID123456789';

  // Uncomment when using Firestore
  /*
  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      adminEmail = user.email ?? 'No email';
      adminUID = user.uid;

      final doc = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
      final data = doc.data();
      setState(() {
        adminName = data?['name'] ?? 'Admin FitHub';
        profileImageUrl = data?['profileImageUrl'];
      });
    }
  }
  */

  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context); // Close dialog first
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD8DBE2);
    const dark = Color(0xFF373F51);
    const black = Color(0xFF1B1B1E);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: dark,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage('assets/avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              adminName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: black,
              ),
            ),
            const SizedBox(height: 6),
            Text(adminEmail, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              'UID: $adminUID',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const Spacer(),

            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }
}
