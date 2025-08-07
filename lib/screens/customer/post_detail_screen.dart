import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  YoutubePlayerController? _youtubeController;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    final url = widget.post['youtubeUrl'] ?? '';
    _videoId = extractYouTubeId(url);
    if (_videoId != null && _videoId!.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final type = (post['type'] ?? '').toString().toLowerCase();
    final fileUrl = post['fileUrl'];

    return Scaffold(
      appBar: AppBar(title: Text(post['title'] ?? 'Post Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post['title'] ?? 'Untitled',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("By ${post['trainerName'] ?? 'Trainer'}"),
              const SizedBox(height: 16),

              //  YouTube Video
              if (type.contains('youtube') && _youtubeController != null)
                YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                )
              //  Image preview
              else if (fileUrl != null)
                Image.network(
                  fileUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text("Media unavailable"),
                      ),
                )
              //  No preview
              else
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Text("No preview available"),
                ),

              const SizedBox(height: 16),
              Text(
                post['description'] ?? 'No description available.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.category),
                  SizedBox(width: 8),
                  Text(post['category'] ?? ''),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 8),
                  Text(post['duration'] ?? '0 min'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// YouTube link parser
String? extractYouTubeId(String url) {
  try {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      if (uri.pathSegments.contains('embed')) {
        return uri.pathSegments.last;
      }
      return uri.queryParameters['v'];
    } else if (!url.contains('/') && url.length == 11) {
      return url;
    }
  } catch (_) {
    return null;
  }
  return null;
}
