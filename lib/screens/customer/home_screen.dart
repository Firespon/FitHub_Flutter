import 'package:fithub_user/screens/customer/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../main.dart'; // ThemeController
import '../../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String selectedCategory = 'All';
  Set<String> bookmarkedPosts = {};

  final List<String> categories = [
    'All',
    'Workout',
    'Nutrition',
    'Wellness',
    'Guidance',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final saved = await _firebaseService.getUserBookmarks();
    setState(() {
      bookmarkedPosts = Set<String>.from(saved);
    });
  }

  Future<String> fetchFirstName() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
    return doc.data()?['firstName'] ?? 'User';
  }

  Stream<QuerySnapshot> getFilteredPosts() {
    final query = FirebaseFirestore.instance
        .collection('posts')
        .where('status', isEqualTo: 'approved');

    if (selectedCategory != 'All') {
      return query.where('category', isEqualTo: selectedCategory).snapshots();
    } else {
      return query.snapshots();
    }
  }

  bool isBookmarked(String postId) => bookmarkedPosts.contains(postId);

  void toggleBookmark(String postId) async {
    await _firebaseService.toggleUserBookmark(postId);
    setState(() {
      if (bookmarkedPosts.contains(postId)) {
        bookmarkedPosts.remove(postId);
      } else {
        bookmarkedPosts.add(postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("FitHub"),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: fetchFirstName(),
              builder: (context, snapshot) {
                final name = snapshot.data ?? '👋';
                return Text(
                  "Hi, $name",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              },
            ),
            Text("Ready to train today?"),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: categories.map(_filterChip).toList()),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getFilteredPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final posts = snapshot.data?.docs ?? [];
                  if (posts.isEmpty) {
                    return Center(child: Text("No posts available"));
                  }
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final doc = posts[index];
                      final post = doc.data() as Map<String, dynamic>;
                      final postId = doc.id;
                      return _postCard(post, postId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Color(0xFF373F51),
        backgroundColor: Colors.grey[300],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        onSelected: (_) => setState(() => selectedCategory = label),
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post, String postId) {
    final String type = (post['type'] ?? '').toString().toLowerCase();
    final String? youtubeUrl = post['youtubeUrl'];
    final String? fileUrl = post['fileUrl'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post["trainerName"] ?? "Unknown Trainer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (type.contains('youtube') && youtubeUrl != null)
                Image.network(
                  'https://img.youtube.com/vi/${extractYouTubeId(youtubeUrl)}/0.jpg',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _noPreview(),
                )
              else if (fileUrl != null)
                Image.network(
                  fileUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _noPreview(),
                )
              else
                _noPreview(),
              SizedBox(height: 8),
              Text(
                post["title"] ?? "No Title",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.comment_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Comment feature coming soon!')),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked(postId)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.blue,
                    ),
                    onPressed: () => toggleBookmark(postId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noPreview() => Container(
    height: 160,
    color: Colors.grey[300],
    alignment: Alignment.center,
    child: Text("No preview"),
  );
}

String? extractYouTubeId(String url) {
  try {
    url = url.trim();
    if (url.contains("youtu.be/")) {
      return url.split("youtu.be/").last.split('?').first;
    } else if (url.contains("youtube.com/watch")) {
      final uri = Uri.parse(url);
      return uri.queryParameters['v'];
    } else if (url.contains("youtube.com/embed/")) {
      return url.split("embed/").last.split('?').first;
    }
  } catch (_) {}
  return null;
}
