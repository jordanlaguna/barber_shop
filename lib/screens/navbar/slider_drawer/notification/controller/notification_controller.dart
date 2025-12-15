import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationController {
  final String id;
  final String title;
  final String message;
  final String userName;
  final String? userPhotoUrl;
  final String uid;

  final Timestamp? createdAt;

  bool isRead;

  NotificationController({
    required this.id,
    required this.title,
    required this.message,
    required this.userName,
    required this.userPhotoUrl,
    required this.isRead,
    required this.uid,
    this.createdAt,
  });

  static Future<List<NotificationController>> getAllNotifications() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    final currentUserUid = auth.currentUser?.uid;
    if (currentUserUid == null) return [];

    final snapshot =
        await firestore
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return NotificationController(
        id: doc.id,
        title: (data['title'] ?? '') as String,
        message: (data['body'] ?? 'Message unknown') as String,
        createdAt: data['createdAt'] as Timestamp?,
        userName: (data['name'] ?? 'Nombre desconocido') as String,
        userPhotoUrl: data['userPhotoUrl'] as String?,
        isRead: (data['isRead'] ?? false) as bool,
        uid: (data['userId'] ?? '') as String,
      );
    }).toList();
  }

  static Future<void> markAsRead(String notificationDocId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationDocId)
        .update({'isRead': true, 'readAt': FieldValue.serverTimestamp()});
  }
}
