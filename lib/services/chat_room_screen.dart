import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomScreen extends StatefulWidget {
  final String trainerId;
  final String customerId;

  const ChatRoomScreen({
    super.key,
    required this.trainerId,
    required this.customerId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final String chatId;
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    chatId = generateChatId(widget.trainerId, widget.customerId);
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  String generateChatId(String id1, String id2) =>
      id1.compareTo(id2) < 0 ? '$id1\_$id2' : '$id2\_$id1';

  void sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final now = Timestamp.now();

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [widget.trainerId, widget.customerId],
      'lastMessage': message,
      'lastTimestamp': now,
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'receiverId':
              currentUserId == widget.trainerId
                  ? widget.customerId
                  : widget.trainerId,
          'text': message,
          'timestamp': now,
        });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isMe
                                  ? Colors.deepPurple.shade100
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
