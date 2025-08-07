import 'package:flutter/material.dart';
import 'package:fithub_user/services/firebase_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _formKey = GlobalKey<FormState>();
  String contentType = 'Article';
  String category = 'Workout';
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final youtubeLinkController = TextEditingController();

  File? selectedFile;
  String? pickedFileName;

  final List<String> contentTypes = ['Article', 'Video', 'YouTube Link'];
  final List<String> categories = [
    'Workout',
    'Nutrition',
    'Wellness',
    'Guidance',
  ];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: contentType == 'Video' ? FileType.video : FileType.custom,
      allowedExtensions: contentType == 'Article' ? ['pdf'] : null,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        pickedFileName = result.files.single.name;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final service = FirebaseService();

      String? fileUrl;
      if (selectedFile != null && pickedFileName != null) {
        fileUrl = await service.uploadTrainerFile(
          selectedFile!,
          pickedFileName!,
        );
        if (fileUrl == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('File upload failed')));
          return;
        }
      }

      final result = await service.uploadContent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: category,
        type: contentType.toLowerCase(),
        youtubeUrl:
            contentType == 'YouTube Link'
                ? youtubeLinkController.text.trim()
                : null,
        fileUrl: fileUrl,
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Content submitted for admin verification')),
        );
        _formKey.currentState!.reset();
        titleController.clear();
        descriptionController.clear();
        youtubeLinkController.clear();
        setState(() {
          selectedFile = null;
          pickedFileName = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Content',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Trainer Content Hub',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: contentType,
                items:
                    contentTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => contentType = val!),
                decoration: InputDecoration(labelText: 'Content Type'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                items:
                    categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => category = val!),
                decoration: InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a title'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              if (contentType == 'YouTube Link')
                TextFormField(
                  controller: youtubeLinkController,
                  decoration: InputDecoration(labelText: 'YouTube URL'),
                  validator:
                      (value) =>
                          contentType == 'YouTube Link' &&
                                  (value == null || value.isEmpty)
                              ? 'Enter a YouTube URL'
                              : null,
                ),
              if (contentType != 'YouTube Link') ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.attach_file),
                  label: Text(
                    'Attach ${contentType == 'Video' ? 'Video' : 'PDF'}',
                  ),
                  onPressed: _pickFile,
                ),
                if (pickedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Selected: $pickedFileName'),
                  ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text('Submit Content'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
