import 'package:barber_shop/screens/navbar/slider_drawer/notification/controller/notification_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificacionPageDrawer extends StatefulWidget {
  const NotificacionPageDrawer({super.key});

  @override
  State<NotificacionPageDrawer> createState() => _NotificacionPageDrawerState();
}

class _NotificacionPageDrawerState extends State<NotificacionPageDrawer> {
  String getDayGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final compare = DateTime(date.year, date.month, date.day);

    if (compare == today) return "HOY";
    if (compare == yesterday) return "AYER";
    return "ANTERIORES";
  }

  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget notificationTile(NotificationController n) {
    final DateTime date = (n.createdAt as Timestamp).toDate();
    final String hour = DateFormat('hh:mm a').format(date);
    final String day = DateFormat('dd MMM yyyy', 'es').format(date);

    return GestureDetector(
      onTap: () async {
        if (!n.isRead) {
          await NotificationController.markAsRead(n.id);
          setState(() {
            n.isRead = true;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : Colors.cyan.withOpacity(0.05),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.cyan,
                  backgroundImage:
                      n.userPhotoUrl != null
                          ? NetworkImage(n.userPhotoUrl!)
                          : null,
                  child:
                      n.userPhotoUrl == null
                          ? Text(
                            (n.userName != null && n.userName!.isNotEmpty)
                                ? n.userName![0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                          : null,
                ),
                if (!n.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.cyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.userName ?? "Cliente",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hour,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.cyan,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List<NotificationController>>(
          future: NotificationController.getAllNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Error al cargar notificaciones'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No hay notificaciones aún',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
              );
            }

            final notifications = snapshot.data!;
            notifications.sort(
              (a, b) => (b.createdAt as Timestamp).compareTo(
                a.createdAt as Timestamp,
              ),
            );
            final Map<String, List<NotificationController>> grouped = {};

            for (var n in notifications) {
              final date = (n.createdAt as Timestamp).toDate();
              final key = getDayGroup(date);
              grouped.putIfAbsent(key, () => []).add(n);
            }

            return ListView(
              children:
                  grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader(entry.key),
                        ...entry.value.map(notificationTile).toList(),
                      ],
                    );
                  }).toList(),
            );
          },
        ),
      ),
    );
  }
}
