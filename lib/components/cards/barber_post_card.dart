import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarberPostCard extends StatelessWidget {
  final String name;
  final String type;
  final String imageUrl;
  final String barberName;
  final String barberAvatar;
  final DateTime createdAt;
  final int likes;

  const BarberPostCard({
    super.key,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.barberName,
    required this.barberAvatar,
    required this.createdAt,
    required this.likes,
  });

  String timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);

    if (duration.inMinutes < 60) return "Hace ${duration.inMinutes} min";
    if (duration.inHours < 24) return "Hace ${duration.inHours} horas";
    if (duration.inDays < 7) return "Hace ${duration.inDays} días";

    return DateFormat('dd MMM, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage(barberAvatar),
                ),
                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barberName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat",
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      timeAgo(createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              imageUrl,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Montserrat",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              type,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 22,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$likes Me encanta",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat",
                      ),
                    ),
                  ],
                ),

                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Comentarios",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
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
