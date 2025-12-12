import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 12);
  }

  DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  List<String> bookedHours = [];
  String? selectedHour;
  String? errorHour;

  final List<String> hours = [
    "8:00 AM",
    "9:00 AM",
    "10:00 AM",
    "11:00 AM",
    "1:00 PM",
    "2:00 PM",
    "3:00 PM",
    "4:00 PM",
    "5:00 PM",
    "6:00 PM",
  ];

  Future<void> fetchBookedHours(DateTime date) async {
    final start = normalizeDate(date);
    final end = start.add(const Duration(days: 1));

    final query =
        await _firestore
            .collection('appointments')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .where('status', isEqualTo: 'pendiente')
            .get();

    setState(() {
      bookedHours = query.docs.map((doc) => doc['hour'] as String).toList();
    });
  }

  Future<Map<String, dynamic>?> getUserData(String? uid) async {
    if (uid == null) return null;
    try {
      DocumentSnapshot<Map<String, dynamic>> userData =
          await _firestore.collection('user').doc(uid).get();
      return userData.data();
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  Future<bool> isHourBooked(DateTime day, String hour) async {
    final normalizedDate = DateTime(day.year, day.month, day.day, 12);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    final query =
        await _firestore
            .collection('appointments')
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate),
            )
            .where('date', isLessThan: Timestamp.fromDate(nextDay))
            .where('hour', isEqualTo: hour)
            .where('status', isEqualTo: 'pendiente')
            .limit(1)
            .get();

    return query.docs.isNotEmpty;
  }

  DateTime hourStringToDateTime(DateTime day, String hour) {
    final parts = hour.split(' ');
    final time = parts[0];
    final period = parts[1];

    final hourMinute = time.split(':');
    int h = int.parse(hourMinute[0]);
    final int m = int.parse(hourMinute[1]);

    if (period == 'PM' && h != 12) h += 12;
    if (period == 'AM' && h == 12) h = 0;

    return DateTime(day.year, day.month, day.day, h, m);
  }

  bool isDayInPast(DateTime selectedDay) {
    final today = onlyDate(DateTime.now());
    final day = onlyDate(selectedDay);
    return day.isBefore(today);
  }

  bool isHourInPast(DateTime selectedDay, String hour) {
    if (isDayInPast(selectedDay)) return true;
    final now = DateTime.now();
    if (!isSameDay(selectedDay, now)) return false;
    final hourDate = hourStringToDateTime(selectedDay, hour);
    return hourDate.isBefore(now);
  }

  Future<void> confirmAppointment() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_selectedDay == null || selectedHour == null) return;

    try {
      final normalizedDate = normalizeDate(_selectedDay!);
      final nextDay = normalizedDate.add(const Duration(days: 1));
      final hourExists =
          await _firestore
              .collection('appointments')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate),
              )
              .where('date', isLessThan: Timestamp.fromDate(nextDay))
              .where('hour', isEqualTo: selectedHour)
              .where('status', isEqualTo: 'pendiente')
              .limit(1)
              .get();

      if (hourExists.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Esta hora ya fue reservada"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final userDayQuery =
          await _firestore
              .collection('appointments')
              .where('clientId', isEqualTo: user.uid)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate),
              )
              .where('date', isLessThan: Timestamp.fromDate(nextDay))
              .where('status', isEqualTo: 'pendiente')
              .limit(1)
              .get();

      if (userDayQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ya tienes una cita pendiente para este día"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final userData = await getUserData(user.uid);
      final clientName = userData?['name'] ?? 'Cliente';

      await _firestore.collection('appointments').add({
        "clientId": user.uid,
        "clientName": clientName,
        "date": Timestamp.fromDate(normalizedDate),
        "hour": selectedHour,
        "status": "pendiente",
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cita reservada con éxito"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedHour = null;
      });

      fetchBookedHours(_selectedDay!);
    } catch (e) {
      debugPrint("Error guardando cita: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al guardar la cita"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f9ff),
      body: Stack(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Reservar Cita",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TableCalendar(
                            locale: 'es_ES',
                            firstDay: DateTime.utc(2020),
                            lastDay: DateTime.utc(2030),
                            enabledDayPredicate: (day) {
                              return !isDayInPast(day);
                            },
                            focusedDay: _focusedDay,
                            selectedDayPredicate:
                                (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selected, focused) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                                selectedHour = null;
                                errorHour = null;
                              });
                              fetchBookedHours(selected);
                            },

                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: Colors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Horas disponibles",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          children:
                              hours
                                  .where(
                                    (hour) =>
                                        _selectedDay != null &&
                                        !isHourInPast(_selectedDay!, hour),
                                  )
                                  .map((hour) {
                                    final bool isSelected =
                                        selectedHour == hour;
                                    final bool isError = errorHour == hour;

                                    return GestureDetector(
                                      onTap: () async {
                                        if (_selectedDay == null) return;

                                        // Extra: si es una hora pasada (por si acaso), no dejes tocarla
                                        if (isHourInPast(_selectedDay!, hour)) {
                                          setState(() {
                                            selectedHour = null;
                                            errorHour = hour;
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Esta hora ya pasó",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        final booked = await isHourBooked(
                                          _selectedDay!,
                                          hour,
                                        );

                                        setState(() {
                                          if (booked) {
                                            selectedHour = null;
                                            errorHour = hour;
                                          } else {
                                            selectedHour = hour;
                                            errorHour = null;
                                          }
                                        });

                                        if (booked) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Esta hora ya fue reservada",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isError
                                                  ? Colors.red.shade50
                                                  : isSelected
                                                  ? Colors.cyan
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color:
                                                  isError
                                                      ? Colors.redAccent
                                                      : isSelected
                                                      ? Colors.white
                                                      : Colors.cyan,
                                            ),
                                            const SizedBox(width: 14),
                                            Text(
                                              hour,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    isError
                                                        ? Colors.redAccent
                                                        : isSelected
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (isError)
                                              const Icon(
                                                Icons.error,
                                                color: Colors.redAccent,
                                              )
                                            else if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),

                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                selectedHour != null && _selectedDay != null
                                    ? () async {
                                      debugPrint("Confirmar cita pressed");
                                      await confirmAppointment();
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Confirmar cita",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
