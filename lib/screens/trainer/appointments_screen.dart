import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fithub_user/services/firebase_service.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> allAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final docs = await _firebaseService.getTrainerAppointments();
    setState(() {
      allAppointments =
          docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {...data, 'id': doc.id};
          }).toList();
      isLoading = false;
    });
  }

  Future<void> updateStatus(int index, String newStatus) async {
    final docId = allAppointments[index]['id'];
    await _firebaseService.updateAppointmentStatus(docId, newStatus);

    setState(() {
      allAppointments[index]['status'] = newStatus;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Trainer Appointments")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Trainer Appointments")),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: allAppointments.length,
        itemBuilder: (context, index) {
          final appt = allAppointments[index];
          final date = appt['date'] ?? '';
          final time = appt['time'] ?? '';
          final name = appt['customerName'] ?? 'Unknown';
          final session = appt['sessionType'] ?? '';
          final payment = appt['paymentMethod'] ?? '';
          final status = appt['status'] ?? '';

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Divider(),
                  Text("🕒 Time: $date at $time"),
                  Text("📘 Session: $session"),
                  Text("💳 Payment: $payment"),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Status: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (status == 'pending') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.check),
                          label: Text("Confirm"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () => updateStatus(index, 'confirmed'),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.close),
                          label: Text("Reject"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => updateStatus(index, 'rejected'),
                        ),
                      ],
                    ),
                  ] else if (status == 'confirmed') ...[
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check_circle_outline),
                        label: Text("Mark Completed"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () => updateStatus(index, 'completed'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
