import 'package:fithub_user/screens/customer/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarksScreen extends StatefulWidget {
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "Videos", "Articles", "Youtube Links"];
  final user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> fetchBookmarkedPosts() async {
    if (user == null) return [];

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

    List bookmarkedIds = userDoc.data()?['bookmarkedPosts'] ?? [];

    List<Map<String, dynamic>> results = [];

    for (var postId in bookmarkedIds) {
      final postDoc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
      if (postDoc.exists) {
        final data = postDoc.data()!;
        results.add({...data, 'postId': postId});
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children:
                  filters.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      onSelected: (_) {
                        setState(() => selectedFilter = filter);
                      },
                    );
                  }).toList(),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchBookmarkedPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No bookmarks found."));
                }

                final allPosts = snapshot.data!;
                final filtered =
                    allPosts.where((post) {
                      if (selectedFilter == "All") return true;
                      if (selectedFilter == "Videos")
                        return post['type'] == 'Video';
                      if (selectedFilter == "Articles")
                        return post['type'] == 'Article';
                      return true;
                    }).toList();

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final post = filtered[index];
                    final isVideo = post['type'] == 'Video';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(post: post),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isVideo ? Icons.play_circle_fill : Icons.article,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['title'] ?? 'Untitled',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "By ${post['trainerName'] ?? 'Trainer'}",
                                    style: TextStyle(
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (isVideo && post['duration'] != null)
                                    Text(post['duration'])
                                  else
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        post['type'] ?? '',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
