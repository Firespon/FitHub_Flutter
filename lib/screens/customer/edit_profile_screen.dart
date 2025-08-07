import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    var data = userDoc.data()!;
    fullNameController.text = "${data['firstName']} ${data['lastName']}";
    emailController.text = user.email ?? '';
    setState(() {
      _photoUrl = data['photoUrl'];
    });
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child('${user.uid}.jpg');

    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoUrl': downloadUrl,
    });

    setState(() {
      _photoUrl = downloadUrl;
      _selectedImage = file;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile photo updated')));
  }

  void saveChanges() async {
    List<String> nameParts = fullNameController.text.trim().split(' ');
    String first = nameParts.first;
    String last = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': first,
      'lastName': last,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Changes saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (_photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : AssetImage('assets/avatar.png')) as ImageProvider,
            ),
            TextButton.icon(
              onPressed: _pickAndUploadImage,
              icon: Icon(Icons.camera_alt),
              label: Text("Change Photo"),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.lock_outline, color: theme.iconTheme.color),
              title: Text("Change Password", style: theme.textTheme.bodyLarge),
              subtitle: Text("Update your password"),
              onTap: () => Navigator.pushNamed(context, '/changePassword'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveChanges,
              child: Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
