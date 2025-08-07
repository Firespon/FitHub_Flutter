import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_manage_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8DBE2),
      appBar: AppBar(
        title: const Text('FitHub Admin Dashboard'),
        backgroundColor: const Color(0xFF373F51),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Image.asset('assets/fithub_logo.png', height: 70),
              const SizedBox(height: 10),
              const Text(
                'Welcome back, Admin!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1E),
                ),
              ),
              const SizedBox(height: 25),
              FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'customer').get(),
                  FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'trainer').get(),
                  FirebaseFirestore.instance.collection('posts').where('status', isEqualTo: 'pending').get(),
                ]),
                builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final totalCustomers = snapshot.data![0].docs.length;
                  final totalTrainers = snapshot.data![1].docs.length;
                  final totalPending = snapshot.data![2].docs.length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(Icons.person, 'Customers', '$totalCustomers', Colors.teal),
                      _buildStatCard(Icons.fitness_center, 'Trainers', '$totalTrainers', Colors.orange),
                      _buildStatCard(Icons.pending_actions, 'Pending', '$totalPending', Colors.blue),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              _buildActionButton(
                label: 'Manage Users',
                icon: Icons.group,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminManageUsersScreen()),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String count, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF373F51)),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF373F51),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFF373F51), width: 1.2),
        ),
      ),
    );
  }
}
