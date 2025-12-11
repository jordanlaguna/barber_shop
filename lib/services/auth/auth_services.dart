import 'package:barber_shop/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_shop/main.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<UserCredential?> singInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('El usuario canceló el inicio de sesión con Google');
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // sign in to Firebase with the Google
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName ?? 'No Name',
      );

      final userDoc = _firestore.collection('user').doc(user.uid);
      final docSnapshot = await userDoc.get();
      await updateFCMToken();
      if (!docSnapshot.exists) {
        await userDoc.set(user.toMap());
        print('Usuario creado en Firestore');
      } else {
        print('El usuario ya existe en Firestore');
      }

      print('Inicio de sesión con Google exitoso');
      return userCredential;
    } catch (e) {
      print('Error durante el inicio de sesión con Google: $e');
      return null;
    }
  }

  Future<void> singOutGoogle() async {
    await googleSignIn.signOut();
    await _auth.signOut();
    print('Usuario desconectado de Google y Firebase');
  }
}
