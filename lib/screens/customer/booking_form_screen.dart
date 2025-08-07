import 'package:flutter/material.dart';
import 'package:fithub_user/services/firebase_service.dart';

class BookingFormScreen extends StatefulWidget {
  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String? selectedSessionType;
  String? selectedTrainerId;
  String? selectedTrainerName;
  String? selectedPaymentMethod;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<Map<String, dynamic>> trainers = [];
  List<String> sessionTypes = [
    'Strength',
    'Yoga',
    'Dance-Fitness',
    'Workout',
    'Nutrition and Wellness Support',
  ];
  List<String> paymentMethods = ['Online Transfer', 'Cash'];

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    final results = await _firebaseService.getAllTrainers();
    setState(() {
      trainers =
          results.map((data) {
            String fullName =
                "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
            return {
              'id': data['uid'],
              'name': fullName.isEmpty ? data['email'] : fullName,
            };
          }).toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null) {
      final res = await _firebaseService.submitBooking(
        sessionType: selectedSessionType!,
        trainerId: selectedTrainerId!,
        trainerName: selectedTrainerName!,
        date: selectedDate!,
        time: selectedTime!,
        paymentMethod: selectedPaymentMethod!,
      );

      if (res == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Session booked successfully!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book a Session')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedSessionType,
                hint: Text("Select Session Type"),
                items:
                    sessionTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedSessionType = val),
                validator: (val) => val == null ? "Required" : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedTrainerId,
                hint: Text("Select Trainer"),
                items:
                    trainers
                        .map(
                          (trainer) => DropdownMenuItem<String>(
                            value: trainer['id'],
                            child: Text(trainer['name']),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  final name =
                      trainers.firstWhere((t) => t['id'] == val)['name'];
                  setState(() {
                    selectedTrainerId = val;
                    selectedTrainerName = name;
                  });
                },
                validator: (val) => val == null ? "Required" : null,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        selectedDate == null
                            ? "Pick Date"
                            : "${selectedDate!.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(
                        selectedTime == null
                            ? "Pick Time"
                            : selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                hint: Text("Select Payment Method"),
                items:
                    paymentMethods
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedPaymentMethod = val),
                validator: (val) => val == null ? "Required" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitBooking,
                icon: Icon(Icons.check),
                label: Text("Book Session"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
