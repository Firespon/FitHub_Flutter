import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RatingsScreen extends StatefulWidget {
  @override
  _RatingsScreenState createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  late Future<List<Map<String, dynamic>>> _feedbacks;

  @override
  void initState() {
    super.initState();
    _feedbacks = fetchTrainerFeedbacks();
  }

  Future<List<Map<String, dynamic>>> fetchTrainerFeedbacks() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final snapshot = await FirebaseFirestore.instance.collection('feedbacks').get();
    final List<Map<String, dynamic>> feedbackList = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final appointmentId = doc.id;

      if (data['trainerName'] == null) continue;

      // Fetch appointment to check trainer ID
      final appointmentDoc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (appointmentDoc.exists &&
          appointmentDoc.data()?['trainerId'] == currentUser.uid) {
        final feedbackText = data['feedback'] ?? '';
        final parts = feedbackText.split('\n');
        final rating = double.tryParse(parts.first.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final review = parts.length > 1 ? parts.sublist(1).join('\n') : '';

        feedbackList.add({
          'client': appointmentDoc.data()?['customerName'] ?? 'Client',
          'session': appointmentDoc.data()?['sessionType'] ?? 'Session',
          'rating': rating,
          'review': review,
          'solved': false,
        });
      }
    }

    return feedbackList;
  }

  Widget buildStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        IconData icon = i < rating.floor()
            ? Icons.star
            : (i < rating ? Icons.star_half : Icons.star_border);
        return Icon(icon, color: Colors.amber, size: 22);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Client Ratings & Feedback')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _feedbacks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No feedback available."));
          }

          final reviews = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['client'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text('Session: ${review['session']}'),
                      SizedBox(height: 10),
                      buildStars(review['rating']),
                      SizedBox(height: 10),
                      Text(
                        '"${review['review']}"',
                        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
