import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminInsightsScreen extends StatefulWidget {
  const AdminInsightsScreen({super.key});

  @override
  State<AdminInsightsScreen> createState() => _AdminInsightsScreenState();
}

class _AdminInsightsScreenState extends State<AdminInsightsScreen> {
  final Color lightGrey = const Color(0xFFD8DBE2);
  final Color mutedBlue = const Color(0xFFA9BCD0);
  final Color darkBlueGrey = const Color(0xFF373F51);
  final Color charcoalBlack = const Color(0xFF1B1B1E);

  int totalUsers = 0;
  int totalPosts = 0;
  int newSignups = 0;

  @override
  void initState() {
    super.initState();
    fetchInsights();
  }

  Future<void> fetchInsights() async {
    try {
      // Fetch total users
      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      totalUsers = userSnapshot.docs.length;

      // Fetch total posts
      QuerySnapshot postSnapshot =
          await FirebaseFirestore.instance.collection('posts').get();
      totalPosts = postSnapshot.docs.length;

      // Calculate new signups this week
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      newSignups = userSnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['createdAt'];
            if (timestamp is Timestamp) {
              final date = timestamp.toDate();
              return date.isAfter(oneWeekAgo);
            }
            return false;
          })
          .length;

      setState(() {});
    } catch (e) {
      print("Error fetching insights: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text("Admin Insights"),
        backgroundColor: darkBlueGrey,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/fithub_logo.png', height: 80),
            const SizedBox(height: 20),
            const Text(
              'Admin Insights',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1E),
              ),
            ),
            const SizedBox(height: 25),
            _buildInsightCard(Icons.people, 'Total Users',
                totalUsers.toString(), Colors.blue),
            _buildInsightCard(Icons.post_add, 'Total Posts',
                totalPosts.toString(), Colors.indigo),
            _buildInsightCard(Icons.person_add, 'New Signups This Week',
                newSignups.toString(), Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
      IconData icon, String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
