import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_room_screen.dart';

class TrainerChatListScreen extends StatelessWidget {
  final String trainerId;

  const TrainerChatListScreen({super.key, required this.trainerId});

  Future<String> _getCustomerName(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      return "${data?['firstName'] ?? ''} ${data?['lastName'] ?? ''}".trim();
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: trainerId)
                .orderBy('lastTimestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final chats = snapshot.data!.docs;
          if (chats.isEmpty) return Center(child: Text("No messages yet"));

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;
              final chatId = chat.id;
              final lastMessage = data['lastMessage'] ?? '';
              final timestamp = (data['lastTimestamp'] as Timestamp).toDate();
              final receiverId = (data['participants'] as List).firstWhere(
                (id) => id != trainerId,
                orElse: () => 'Unknown',
              );

              return FutureBuilder<String>(
                future: _getCustomerName(receiverId),
                builder: (context, snapshot) {
                  final customerName = snapshot.data ?? receiverId;
                  return ListTile(
                    title: Text("Customer: $customerName"),
                    subtitle: Text(lastMessage),
                    trailing: Text(
                      TimeOfDay.fromDateTime(timestamp).format(context),
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatRoomScreen(
                                trainerId: trainerId,
                                customerId: receiverId,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
