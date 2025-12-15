import 'package:barber_shop/utils/date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getBookedHours(DateTime day) async {
    final start = DateUtilsHelper.normalizeDate(day);
    final end = start.add(const Duration(days: 1));

    final query =
        await _firestore
            .collection('appointments')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .where('status', isEqualTo: 'pendiente')
            .get();

    return query.docs.map((d) => d['hour'] as String).toList();
  }

  Future<bool> isHourBooked(DateTime day, String hour) async {
    final start = DateUtilsHelper.normalizeDate(day);
    final end = start.add(const Duration(days: 1));

    final query =
        await _firestore
            .collection('appointments')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .where('hour', isEqualTo: hour)
            .where('status', isEqualTo: 'pendiente')
            .limit(1)
            .get();

    return query.docs.isNotEmpty;
  }

  Future<bool> userHasPendingAppointment(String userId, DateTime day) async {
    final start = DateUtilsHelper.normalizeDate(day);
    final end = start.add(const Duration(days: 1));

    final query =
        await _firestore
            .collection('appointments')
            .where('clientId', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .where('status', isEqualTo: 'pendiente')
            .limit(1)
            .get();

    return query.docs.isNotEmpty;
  }

  Future<void> createAppointment({
    required String barberId,
    required String clientId,
    required String clientName,
    required DateTime day,
    required String hour,
  }) async {
    await _firestore.collection('appointments').add({
      "barberId": barberId,
      "clientId": clientId,
      "clientName": clientName,
      "date": Timestamp.fromDate(DateUtilsHelper.normalizeDate(day)),
      "hour": hour,
      "status": "pendiente",
      "createdAt": Timestamp.now(),
    });
  }
}
