import 'package:barber_shop/api/firebase_api.dart';
import 'package:barber_shop/services/appointment/appointment_service.dart';
import 'package:barber_shop/services/appointment/barber_service.dart';
import 'package:barber_shop/services/appointment/user_service.dart';
import 'package:barber_shop/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AppointmentService _appointmentService = AppointmentService();
  final UserService _userService = UserService();
  final BarberService _barberService = BarberService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String? selectedBarberId;
  String? selectedHour;
  String? errorHour;

  List<String> bookedHours = [];

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
    final result = await _appointmentService.getBookedHours(date);
    setState(() => bookedHours = result);
  }

  Future<void> confirmAppointment() async {
    final user = _auth.currentUser;
    if (user == null ||
        _selectedDay == null ||
        selectedHour == null ||
        selectedBarberId == null) {
      return;
    }

    try {
      final hasAppointment = await _appointmentService
          .userHasPendingAppointment(user.uid, _selectedDay!);

      if (hasAppointment) {
        _showSnack("Ya tienes una cita pendiente para este día", Colors.orange);
        return;
      }

      final hourBooked = await _appointmentService.isHourBooked(
        _selectedDay!,
        selectedHour!,
      );

      if (hourBooked) {
        _showSnack("Esta hora ya fue reservada", Colors.red);
        return;
      }

      final userData = await _userService.getUserData(user.uid);
      final clientName = userData?['name'] ?? 'Cliente';

      await _appointmentService.createAppointment(
        barberId: selectedBarberId!,
        clientId: user.uid,
        clientName: clientName,
        day: _selectedDay!,
        hour: selectedHour!,
      );

      _showSnack("Cita reservada con éxito", Colors.green);

      final apiFirebase = FirebaseApi();
      await apiFirebase.sendNotificationToAllUsers(
        "Nueva cita reservada",
        "El cliente $clientName ha reservado una nueva cita.",
        "Para el día ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} a las $selectedHour",
      );

      setState(() => selectedHour = null);
      fetchBookedHours(_selectedDay!);
    } catch (e) {
      debugPrint("Error guardando cita: $e");
      _showSnack("Error al guardar la cita", Colors.red);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f9ff),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton(
        backgroundColor:
            (_selectedDay != null &&
                    selectedHour != null &&
                    selectedBarberId != null)
                ? Colors.cyan
                : Colors.grey.shade400,
        elevation: 6,
        onPressed:
            (_selectedDay != null &&
                    selectedHour != null &&
                    selectedBarberId != null)
                ? confirmAppointment
                : null,
        child: const Icon(Icons.check, color: Colors.white, size: 28),
      ),

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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      children: [
                        _buildCalendar(),
                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Seleccione un barbero",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildBarbers(),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Horas disponibles",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildHours(),
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

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TableCalendar(
        locale: 'es_ES',
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: _focusedDay,
        enabledDayPredicate: (day) => !DateUtilsHelper.isDayInPast(day),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
    );
  }

  Widget _buildBarbers() {
    return StreamBuilder<QuerySnapshot>(
      stream: _barberService.barbersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No hay barberos disponibles"),
          );
        }

        return Column(
          children:
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final barberId = data['uid'];
                final barberName = data['name'] ?? 'Barbero';
                final photoUrl = data['photoUrl'];

                final isSelected = selectedBarberId == barberId;

                return GestureDetector(
                  onTap: () => setState(() => selectedBarberId = barberId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.cyan.withOpacity(0.08)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? Colors.cyan : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.cyan,
                          backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl) : null,
                          child:
                              photoUrl == null
                                  ? Text(
                                    barberName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                barberName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Barbero",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: isSelected ? 1 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.cyan,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildHours() {
    if (_selectedDay == null) return const SizedBox();

    return Column(
      children:
          hours
              .where(
                (hour) => !DateUtilsHelper.isHourInPast(_selectedDay!, hour),
              )
              .map((hour) {
                final isSelected = selectedHour == hour;
                final isError = errorHour == hour;

                return GestureDetector(
                  onTap: () async {
                    final booked = await _appointmentService.isHourBooked(
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
                      _showSnack("Esta hora ya fue reservada", Colors.red);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
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
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
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
                          const Icon(Icons.error, color: Colors.redAccent)
                        else if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.white),
                      ],
                    ),
                  ),
                );
              })
              .toList(),
    );
  }
}
