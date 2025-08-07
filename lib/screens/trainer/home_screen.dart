import 'package:fithub_user/screens/auth/login_screen.dart';
import 'package:fithub_user/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({Key? key}) : super(key: key);

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  String? fullName;
  List<Map<String, dynamic>> mySessions = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.chat, 'label': 'Chat', 'route': '/trainerChats'},
    {
      'icon': Icons.calendar_today,
      'label': 'Appointments',
      'route': '/trainerAppointments',
    },
    {'icon': Icons.star_rate, 'label': 'Rate', 'route': '/trainerRatings'},
    {'icon': Icons.upload_file, 'label': 'Upload', 'route': '/trainerUpload'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTrainerData();
  }

  Future<void> _loadTrainerData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      setState(() {
        fullName = '${userDoc['firstName']}';
      });

      final uploadedPosts = await FirebaseService().getTrainerUploadedPosts();

      setState(() {
        mySessions =
            uploadedPosts
                .map(
                  (data) => {
                    'title': data['title'] ?? 'Untitled',
                    'category': data['category'] ?? 'N/A',
                    'status': data['status'] ?? 'N/A',
                  },
                )
                .toList();

        isLoading = false;
      });
    } catch (e) {
      print('Error loading trainer data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome back, ${fullName ?? ''}!'),
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What would you like to work on?",
                      style: theme.textTheme.titleLarge,
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          categories.map((cat) {
                            return GestureDetector(
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    cat['route'],
                                  ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.primaryColor,
                                    child: Icon(
                                      cat['icon'],
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(cat['label']),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "My Posts",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child:
                          mySessions.isEmpty
                              ? Center(child: Text("No posts uploaded yet."))
                              : ListView.builder(
                                itemCount: mySessions.length,
                                itemBuilder: (context, index) {
                                  final s = mySessions[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text(s['title']),
                                      subtitle: Text(
                                        "Category: ${s['category']}",
                                      ),
                                      trailing: Text(
                                        "Status: ${s['status']}",
                                        style: TextStyle(
                                          color:
                                              s['status'] == 'approved'
                                                  ? Colors.green
                                                  : s['status'] == 'pending'
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
