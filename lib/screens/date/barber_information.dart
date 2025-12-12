import 'package:cloud_firestore/cloud_firestore.dart';
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

  final _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> dates = [];
  bool loading = false;

  int _hourToMinutes(String hour) {
    final parts = hour.trim().split(' ');
    if (parts.length != 2) return 0;

    final timePart = parts[0];
    final ampm = parts[1].toUpperCase();

    final hm = timePart.split(':');
    if (hm.length != 2) return 0;

    int h = int.tryParse(hm[0]) ?? 0;
    final m = int.tryParse(hm[1]) ?? 0;

    if (ampm == 'PM' && h != 12) h += 12;
    if (ampm == 'AM' && h == 12) h = 0;

    return h * 60 + m;
  }

  Future<void> fetchDates(DateTime day) async {
    setState(() => loading = true);

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    try {
      // IMPORTANTE:
      // - Mantén SOLO orderBy('date') para evitar índice compuesto extra.
      // - Ordenamos por hora en memoria.
      final snapshot =
          await _firestore
              .collection('appointments')
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
              .where('date', isLessThan: Timestamp.fromDate(end))
              .orderBy('date')
              .get();

      final docs = snapshot.docs;

      // Orden por hora (string) convertido a minutos
      docs.sort((a, b) {
        final ha = (a.data()['hour'] ?? '').toString();
        final hb = (b.data()['hour'] ?? '').toString();
        return _hourToMinutes(ha).compareTo(_hourToMinutes(hb));
      });

      if (!mounted) return;
      setState(() {
        dates = docs;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      debugPrint('ERROR FETCH CITAS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error cargando citas: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<DateTime> getWeekDays(DateTime day) {
    final start = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    fetchDates(selectedDay);
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

  Future<void> _updateStatus(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String newStatus,
  ) async {
    try {
      await doc.reference.update({"status": newStatus});
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cita marcada como ${newStatus.capitalize()}"),
          backgroundColor: Colors.green,
        ),
      );

      await fetchDates(selectedDay);
    } catch (e) {
      if (!mounted) return;
      debugPrint("ERROR UPDATE STATUS: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error actualizando cita: $e"),
          backgroundColor: Colors.red,
        ),
      );
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

                // días
                SizedBox(
                  height: 85,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: diasSemana.length,
                    itemBuilder: (context, index) {
                      final day = diasSemana[index];
                      final isSelected =
                          DateFormat('yyyy-MM-dd').format(day) ==
                          DateFormat('yyyy-MM-dd').format(selectedDay);

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedDay = day);
                          fetchDates(day);
                        },
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

                // citas
                Expanded(
                  child:
                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : dates.isEmpty
                          ? const Center(
                            child: Text(
                              "No hay citas para este día",
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: dates.length,
                            itemBuilder: (context, index) {
                              final data = dates[index].data();
                              final estado =
                                  (data["status"] ?? "")
                                      .toString()
                                      .toLowerCase();
                              final estadoColor = getEstadoColor(estado);

                              final hour = (data["hour"] ?? "").toString();
                              final clientName =
                                  (data["clientName"] ?? "Cliente").toString();

                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 300 + index * 80,
                                ),
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
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.cyan,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          hour,
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
                                            color: estadoColor.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                      clientName,
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
                                            onPressed:
                                                () => _updateStatus(
                                                  dates[index],
                                                  "atendida",
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: const Text(
                                              "Atender",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed:
                                                () => _updateStatus(
                                                  dates[index],
                                                  "cancelada",
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                            ),
                                            child: const Text(
                                              "Cancelar",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
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
