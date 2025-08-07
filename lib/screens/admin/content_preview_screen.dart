import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ContentPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> content;

  const ContentPreviewScreen({super.key, required this.content, required contentUrl});

  @override
  State<ContentPreviewScreen> createState() => _ContentPreviewScreenState();
}

class _ContentPreviewScreenState extends State<ContentPreviewScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    final type = widget.content['type'] ?? '';
    final contentUrl = widget.content['content'] ?? '';

    if (type == 'Video' && contentUrl.isNotEmpty) {
      _videoController = VideoPlayerController.network(contentUrl)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String type = widget.content['type'] ?? 'Unknown';
    final String title = widget.content['title'] ?? 'No Title';
    final String user = widget.content['user'] ?? 'Unknown';
    final String time = widget.content['time'] ?? 'Unknown';
    final String contentData = widget.content['content'] ?? '';
    final String description = widget.content['description'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Preview'),
        backgroundColor: const Color(0xFF373F51),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFD8DBE2),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $type', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Title: $title', style: const TextStyle(fontSize: 16, color: Color(0xFFA9BCD0))),
            const SizedBox(height: 10),
            Text('Posted by $user • $time', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            if (description.isNotEmpty)
              Text('Description: $description', style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: _buildPreviewContent(type, contentData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(String type, String contentData) {
    if (type == 'Article' || type == 'Text') {
      return SingleChildScrollView(
        child: Text(contentData, style: const TextStyle(fontSize: 16)),
      );
    } else if (type == 'Image') {
      return Image.network(contentData, fit: BoxFit.cover);
    } else if (type == 'Video') {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Column(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
              child: Icon(
                _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ],
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      return const Text('Unknown content type or unsupported preview.', style: TextStyle(fontSize: 16));
    }
  }
}