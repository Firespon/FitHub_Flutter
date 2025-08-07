import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/firebase_service.dart';

class FeedbackFormScreen extends StatefulWidget {
  final String bookingId;
  final String trainerName;

  const FeedbackFormScreen({
    super.key,
    required this.bookingId,
    required this.trainerName,
  });

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  double _rating = 0.0;
  bool _isSubmitting = false;

  void _submitFeedback() async {
    final feedbackText = _feedbackController.text.trim();

    if (_rating == 0.0 || feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and feedback')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _firebaseService.saveFeedback(
        bookingId: widget.bookingId,
        trainerName: widget.trainerName,
        feedback: 'Rating: $_rating\n$feedbackText',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Feedback sent')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send feedback. Please try again.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback for ${widget.trainerName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Rate your session",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              allowHalfRating: true,
              itemBuilder:
                  (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => _rating = rating,
            ),
            SizedBox(height: 24),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text(_isSubmitting ? "Submitting..." : "Submit Feedback"),
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
