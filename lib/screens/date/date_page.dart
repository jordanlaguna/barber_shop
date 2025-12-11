import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> horas = [
    "10:00 AM",
    "11:00 AM",
    "1:00 PM",
    "2:00 PM",
    "3:00 PM",
    "4:00 PM",
  ];

  final List<String> horasOcupadas = ["3:00 PM"];

  String? horaSeleccionada;

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(height: 30),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TableCalendar(
                            locale: 'es_ES',
                            firstDay: DateTime.utc(2020),
                            lastDay: DateTime.utc(2030),
                            focusedDay: _focusedDay,
                            selectedDayPredicate:
                                (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selected, focused) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                                horaSeleccionada = null;
                              });
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
                              titleTextStyle: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Horas disponibles",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          children:
                              horas.map((hora) {
                                bool ocupada = horasOcupadas.contains(hora);
                                bool seleccionada = horaSeleccionada == hora;
                                return GestureDetector(
                                  onTap:
                                      ocupada
                                          ? null
                                          : () {
                                            setState(
                                              () => horaSeleccionada = hora,
                                            );
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
                                          ocupada
                                              ? Colors.grey[300]
                                              : seleccionada
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
                                              ocupada
                                                  ? Colors.grey
                                                  : seleccionada
                                                  ? Colors.white
                                                  : Colors.cyan,
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          hora,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Montserrat",
                                            color:
                                                ocupada
                                                    ? Colors.grey
                                                    : seleccionada
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (ocupada)
                                          const Text(
                                            "Ocupada",
                                            style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                        if (seleccionada)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                (horaSeleccionada != null &&
                                        _selectedDay != null)
                                    ? () {}
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              disabledBackgroundColor: Colors.cyan.withOpacity(
                                0.4,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Confirmar cita",
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
