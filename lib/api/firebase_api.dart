import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final FCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $FCMToken');
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification}');
  }

  Future<void> initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
  }

  // this method is send a notification push
  Future<void> sendNotificationToAllUsers(String title, String message) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('user').get();
    final tokens =
        userSnapshot.docs
            .map((doc) => doc.data()['fcmToken'] as String?)
            .where((token) => token != null)
            .toList();
    for (String? token in tokens) {
      if (token != null) {
        final playload = constructFCMPayload(token, title, message);
        try {
          final accessToken = await _getAccessToken();
          await http.post(
            Uri.parse(
              'https://fcm.googleapis.com/v1/projects/labo-6-817ed/messages:send',
            ),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
            body: playload,
          );
          print('Notification sent to $token');
        } catch (e) {
          print('Error sending notification: $e');
        }
      }
    }
  }

  String constructFCMPayload(String token, String senderName, String message) {
    return jsonEncode({
      'message': {
        'token': token,
        'notification': {
          'title': '$senderName Una nueva cita ha sido agendada',
          'body': message,
        },
        'data': {'via': 'FlutterFire Cloud Messaging!!!'},
      },
    });
  }

  String constructGeneralFCMPayload(
    String token,
    String title,
    String message,
  ) {
    return jsonEncode({
      'message': {
        'token': token,
        'notification': {'title': title, 'body': message},
        'data': {'via': 'FlutterFire Cloud Messaging!!!'},
      },
    });
  }

  Future<String> _getAccessToken() async {
    const serviceAccountPath = 'assets/services_account_file.json';
    try {
      final serviceAccountJson = await rootBundle.loadString(
        serviceAccountPath,
      );
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );
      final authClient = await clientViaServiceAccount(
        serviceAccountCredentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );
      return authClient.credentials.accessToken.data;
    } catch (e) {
      print('Error reading service account file: $e');
      rethrow;
    }
  }
}
