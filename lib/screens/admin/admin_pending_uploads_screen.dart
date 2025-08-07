import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_preview_screen.dart';

class AdminPendingUploadsScreen extends StatelessWidget {
  const AdminPendingUploadsScreen({super.key});

  void _showActionDialog(
    BuildContext context,
    String action,
    DocumentSnapshot doc,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action Upload'),
        content: Text('Are you sure you want to $action this upload?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (action.toLowerCase() == 'delete') {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(doc.id)
                      .delete();
                } else {
                  final statusValue =
                      action.toLowerCase() == 'approve' ? 'approved' : 'rejected';

                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(doc.id)
                      .update({'status': statusValue});
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Upload ${action.toLowerCase()}d successfully!')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'Delete' ? Colors.red : null,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const lightGrey = Color(0xFFD8DBE2);
    const mutedBlue = Color(0xFFA9BCD0);
    const darkBlueGrey = Color(0xFF373F51);
    const charcoalBlack = Color(0xFF1B1B1E);

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: darkBlueGrey,
        foregroundColor: Colors.white,
        title: const Text('Pending Uploads'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('status', isEqualTo: 'pending')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending uploads"));
          }

          final uploads = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uploads.length,
            itemBuilder: (context, index) {
              final doc = uploads[index];
              final data = doc.data() as Map<String, dynamic>;

              final type = data['type'] ?? 'Unknown';
              final title = data['title'] ?? 'No Title';
              final trainer = data['trainer'] ?? 'Unknown';
              final timestamp = data['timestamp']?.toDate();
              final formattedTime = timestamp != null
                  ? '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                  : 'No Date';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            type == "Video"
                                ? Icons.play_circle_fill
                                : Icons.description,
                            color: mutedBlue,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: charcoalBlack,
                                  ),
                                ),
                                Text(
                                  title,
                                  style: const TextStyle(color: mutedBlue),
                                ),
                                Text(
                                  'Trainer: $trainer',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Submitted on: $formattedTime',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye, color: Colors.grey),
                            tooltip: 'Preview Content',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContentPreviewScreen(
                                    content: {
                                      'type': type,
                                      'title': title,
                                      'user': trainer,
                                      'time': formattedTime,
                                      'description': data['description'] ?? '',
                                      'content': data['content'] ?? '',
                                    },
                                    contentUrl: data['contentUrl'] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _showActionDialog(context, 'Reject', doc),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                            ),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () =>
                                _showActionDialog(context, 'Approve', doc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () =>
                                _showActionDialog(context, 'Delete', doc),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
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
