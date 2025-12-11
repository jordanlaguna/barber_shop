import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barber_shop/utils/string_extensions.dart';

class BarberInformation extends StatefulWidget {
  const BarberInformation({super.key});

  @override
  State<BarberInformation> createState() => _BarberInformationState();
}

class _BarberInformationState extends State<BarberInformation>
    with SingleTickerProviderStateMixin {
  DateTime selectedDay = DateTime.now();

  List<Map<String, dynamic>> citas = [
    {"hora": "10:00 AM", "cliente": "Javier López", "estado": "pendiente"},
    {"hora": "11:00 AM", "cliente": "María Pérez", "estado": "pendiente"},
    {"hora": "1:00 PM", "cliente": "Luis Campos", "estado": "atendida"},
    {"hora": "2:00 PM", "cliente": "Daniela Mora", "estado": "cancelada"},
  ];

  List<DateTime> getWeekDays(DateTime day) {
    final start = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  Color getEstadoColor(String estado) {
    switch (estado) {
      case "pendiente":
        return Colors.orange;
      case "atendida":
        return Colors.green;
      case "cancelada":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diasSemana = getWeekDays(selectedDay);
    return Scaffold(
      backgroundColor: const Color(0xfff4f9ff),
      body: Stack(
        children: [
          Container(
            height: 180,
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
                const SizedBox(height: 10),
                const Text(
                  "Agenda de Citas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // date display
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    DateFormat(
                      "EEEE d 'de' MMMM",
                      "es_ES",
                    ).format(selectedDay).capitalize(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: "Montserrat",
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // selectable days list
                SizedBox(
                  height: 85,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: diasSemana.length,
                    itemBuilder: (context, index) {
                      final day = diasSemana[index];
                      final bool isSelected =
                          DateFormat('yyyy-MM-dd').format(day) ==
                          DateFormat('yyyy-MM-dd').format(selectedDay);

                      return GestureDetector(
                        onTap: () => setState(() => selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 75,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white60,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.cyan : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat(
                                  'E',
                                  'es_ES',
                                ).format(day).substring(0, 3).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.cyan[700],
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${day.day}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // list of citas
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];
                      final estado =
                          (cita["estado"] ?? "").toString().toLowerCase();
                      final estadoColor = getEstadoColor(estado);
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + index * 80),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hour and status
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.cyan),
                                const SizedBox(width: 10),
                                Text(
                                  cita["hora"],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: estadoColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    estado.capitalize(),
                                    style: TextStyle(
                                      color: estadoColor,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cita["cliente"],
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Montserrat",
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (estado == "pendiente")
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Atender",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
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
