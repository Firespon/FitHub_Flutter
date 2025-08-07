import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user
  Future<String?> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        ...additionalData,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // Login
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user profile
  Future<DocumentSnapshot?> getUserProfile() async {
    if (_auth.currentUser == null) return null;
    return await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
  }

  // Upload trainer file
  Future<String?> uploadTrainerFile(File file, String fileName) async {
    try {
      final userId = _auth.currentUser?.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('trainer_uploads')
          .child(userId!)
          .child(fileName);

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Upload content (with trainer name)
  Future<String?> uploadContent({
    required String title,
    required String description,
    required String category,
    required String type,
    String? youtubeUrl,
    String? fileUrl,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return 'User not logged in.';

      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();
      if (data == null) return 'User data not found';

      final name =
          "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
      final trainerName = name.isNotEmpty ? name : data['email'] ?? 'Trainer';

      await _firestore.collection('posts').add({
        'trainerId': uid,
        'trainerName': trainerName,
        'title': title,
        'description': description,
        'category': category,
        'type': type,
        'youtubeUrl': youtubeUrl,
        'fileUrl': fileUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return null;
    } catch (e) {
      return 'Failed to upload content.';
    }
  }

  // Submit booking
  Future<String?> submitBooking({
    required String sessionType,
    required String trainerId,
    required String trainerName,
    required DateTime date,
    required TimeOfDay time,
    required String paymentMethod,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Not logged in';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final customerData = userDoc.data()!;
      final customerName =
          "${customerData['firstName'] ?? ''} ${customerData['lastName'] ?? ''}"
              .trim();

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final formattedTime =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

      await _firestore.collection('appointments').add({
        'customerId': user.uid,
        'customerName':
            customerName.isEmpty
                ? customerData['email'] ?? 'Anonymous'
                : customerName,
        'trainerId': trainerId,
        'trainerName': trainerName,
        'sessionType': sessionType,
        'date': formattedDate,
        'time': formattedTime,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to submit booking.';
    }
  }

  // Get trainer appointments
  Future<List<QueryDocumentSnapshot>> getTrainerAppointments() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return [];

      final snapshot =
          await _firestore
              .collection('appointments')
              .where('trainerId', isEqualTo: uid)
              .orderBy('date')
              .get();

      return snapshot.docs;
    } catch (e) {
      return [];
    }
  }

  // Get customer bookings
  Future<List<QueryDocumentSnapshot>> getCustomerBookings() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return [];

      final snapshot =
          await _firestore
              .collection('appointments')
              .where('customerId', isEqualTo: uid)
              .orderBy('date')
              .get();

      return snapshot.docs;
    } catch (e) {
      return [];
    }
  }

  // Get all trainers
  Future<List<Map<String, dynamic>>> getAllTrainers() async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'trainer')
              .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String docId, String status) async {
    await _firestore.collection('appointments').doc(docId).update({
      'status': status,
    });
  }

  // Add comment to post
  Future<void> addComment(String postId, String comment) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
          'userId': user.uid,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> toggleUserBookmark(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final doc = await userDocRef.get();
    final data = doc.data();

    if (data == null) return;

    List bookmarks = data['bookmarkedPosts'] ?? [];

    if (bookmarks.contains(postId)) {
      // Remove bookmark
      await userDocRef.update({
        'bookmarkedPosts': FieldValue.arrayRemove([postId]),
      });
    } else {
      // Add bookmark
      await userDocRef.update({
        'bookmarkedPosts': FieldValue.arrayUnion([postId]),
      });
    }
  }

  Future<List> getUserBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return doc.data()?['bookmarkedPosts'] ?? [];
  }

  Future<void> saveFeedback({
    required String bookingId,
    required String trainerName,
    required String feedback,
  }) async {
    final feedbackDoc = FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(bookingId);

    await feedbackDoc.set({
      'trainerName': trainerName,
      'feedback': feedback,
      'submittedAt': Timestamp.now(),
    });
  }

  Future<bool> getFeedbackExists(String bookingId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(bookingId)
            .get();
    return doc.exists;
  }

  // Fetch chat threads where the trainer is involved
  Stream<QuerySnapshot> getTrainerChats(String trainerId) {
    return _firestore
        .collection('chats')
        .where('trainerId', isEqualTo: trainerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Fetch messages from a specific chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Send a message
  Future<void> sendChatMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    final now = Timestamp.now();

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': message,
      'lastTimestamp': now,
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': senderId,
          'receiverId': receiverId,
          'text': message,
          'timestamp': now,
        });
  }

  // Get trainer's uploaded posts (approved or pending)
  Future<List<Map<String, dynamic>>> getTrainerUploadedPosts() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot =
        await _firestore
            .collection('posts')
            .where('trainerId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
