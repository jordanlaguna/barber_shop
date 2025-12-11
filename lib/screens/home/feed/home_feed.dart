import 'package:barber_shop/components/cards/barber_post_card.dart';
import 'package:flutter/material.dart';

class HomeFeed extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  const HomeFeed({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final p = posts[index];
        return BarberPostCard(
          name: p["name"],
          type: p["type"],
          imageUrl: p["image"],
          barberName: p["barberName"],
          barberAvatar: p["avatar"],
          createdAt: p["createdAt"],
          likes: p["likes"],
        );
      },
    );
  }
}
