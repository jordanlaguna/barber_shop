import 'package:cloud_firestore/cloud_firestore.dart';

class BarberService {
  Stream<QuerySnapshot> barbersStream() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('role', isEqualTo: 'barber')
        .snapshots();
  }
}
