import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fithub_user/services/firebase_service.dart';
import 'booking_form_screen.dart';
import 'package:intl/intl.dart';
import 'feedback_form_screen.dart';

class BookingScreen extends StatefulWidget {
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> userBookings = [];
  String selectedStatus = 'all';

  final List<String> statusOptions = [
    'all',
    'confirmed',
    'pending',
    'completed',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();
    fetchUserBookings();
  }

  Future<void> fetchUserBookings() async {
    final docs = await _firebaseService.getCustomerBookings();
    setState(() {
      userBookings =
          docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['bookingId'] = doc.id;
            return data;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings =
        userBookings.where((booking) {
          if (selectedStatus == 'all') return true;
          return booking['status']?.toLowerCase() ==
              selectedStatus.toLowerCase();
        }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF2F3F5),
      appBar: AppBar(title: Text('Your Bookings'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Bookings",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    icon: Icon(Icons.arrow_drop_down),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    items:
                        statusOptions
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status[0].toUpperCase() + status.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => selectedStatus = val!);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (filteredBookings.isEmpty)
              Center(child: Text("No bookings match this filter."))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: filteredBookings.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = filteredBookings[index];
                    final dateTime =
                        session['date'] != null
                            ? DateTime.parse(session['date'])
                            : DateTime.now();
                    final formattedDate = DateFormat(
                      'MMMM d, y',
                    ).format(dateTime);
                    final formattedTime = session['time'] ?? 'Unknown';

                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${session['sessionType']} with ${session['trainerName']}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "$formattedDate at $formattedTime",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      session['status'] == 'confirmed'
                                          ? Colors.green.shade100
                                          : session['status'] == 'completed'
                                          ? Colors.blue.shade100
                                          : session['status'] == 'rejected'
                                          ? Colors.red.shade100
                                          : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  session['status']?.toUpperCase() ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        session['status'] == 'confirmed'
                                            ? Colors.green.shade800
                                            : session['status'] == 'completed'
                                            ? Colors.blue.shade800
                                            : session['status'] == 'rejected'
                                            ? Colors.red.shade800
                                            : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (session['status'] == 'completed') ...[
                            SizedBox(height: 10),
                            FutureBuilder<bool>(
                              future: _firebaseService.getFeedbackExists(
                                session['bookingId'],
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return SizedBox();
                                final feedbackExists = snapshot.data!;
                                if (feedbackExists) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Chip(
                                      label: Text("Feedback given"),
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                  );
                                } else {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => FeedbackFormScreen(
                                                  bookingId:
                                                      session['bookingId'],
                                                  trainerName:
                                                      session['trainerName'] ??
                                                      'Trainer',
                                                ),
                                          ),
                                        ).then((_) => fetchUserBookings());
                                      },
                                      icon: Icon(Icons.feedback_outlined),
                                      label: Text("Give Feedback"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.deepPurple,
                                        side: BorderSide(
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingFormScreen()),
                ).then((_) => fetchUserBookings());
              },
              icon: Icon(Icons.add),
              label: Text("Book Appointment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
