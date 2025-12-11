// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barber_shop/main.dart';
import 'package:barber_shop/model/user.dart';

class RegisterServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        role: 'client',
      );

      await _firestore.collection('user').doc(user.uid).set(user.toMap());

      await updateFCMToken();

      return true;
    } catch (e) {
      print("Error al registrar usuario: $e");
      return false;
    }
  }

  // Method to login with email and password
  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error en login: $e");
      throw e;
    }
  }
}
