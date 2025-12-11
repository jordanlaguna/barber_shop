import 'package:barber_shop/screens/date/barber_information.dart';
import 'package:barber_shop/screens/date/date_page.dart';
import 'package:barber_shop/screens/home/form/publication_create.dart';
import 'package:barber_shop/screens/navbar/navbar.dart';
import 'package:barber_shop/screens/profile/profile_page.dart';
import 'package:barber_shop/screens/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:barber_shop/screens/home/feed/home_feed.dart';

import '../button_nav.dart';

class HomePage extends StatefulWidget {
  final String role;
  const HomePage({super.key, required this.role});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final posts = [
    {
      "name": "Degradado alto",
      "type": "Corte moderno",
      "image": "assets/cuts/degradado_alto.png",
      "barberName": "Popa Laguna",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 24,
    },
    {
      "name": "Degradado bajo",
      "type": "Tradicional",
      "image": "assets/cuts/degradado_bajo.png",
      "barberName": "Popa Barber",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 16,
    },
    {
      "name": "Degradado conico",
      "type": "Estilo clásico",
      "image": "assets/cuts/degradado_conico.png",
      "barberName": "Popa Barber",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 32,
    },
    {
      "name": "Degradado Mohicano",
      "type": "Corte elegante",
      "image": "assets/cuts/degradado_mohicano.png",
      "barberName": "Popa Barber",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 18,
    },
    {
      "name": "Degradado Peindado Hacia Atrás",
      "type": "Corte fresco",
      "image": "assets/cuts/degradado_peinado.png",
      "barberName": "Popa Barber",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 45,
    },
    {
      "name": "Corte Mullet",
      "type": "Corte sofisticado",
      "image": "assets/cuts/mullet.png",
      "barberName": "Popa Barber",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 30,
    },
    {
      "name": "Corte Diseño",
      "type": "Corte clásico",
      "image": "assets/cuts/degradado_diseño.png",
      "barberName": "Popa Barber",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 19,
    },
    {
      "name": "Corte Riso",
      "type": "Corte simple",
      "image": "assets/cuts/degradado_riso.png",
      "barberName": "Popa Barber",
      "avatar": "assets/logos/Logo_splash.png",
      "createdAt": DateTime.now().subtract(Duration(hours: 3)),
      "likes": 12,
    },
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeFeed(posts: posts),
      widget.role == "barber" ? const BarberInformation() : const DatePage(),
      const SearchPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Colors.blueGrey[50],

      appBar: AppBar(
        title: const Text(
          "PopaBarber Shop",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.cyan,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 35),
      ),

      body: _pages[_selectedIndex],

      floatingActionButton:
          widget.role == "barber" && _selectedIndex == 0
              ? FloatingActionButton(
                backgroundColor: Colors.cyan,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PublicationCreate(),
                    ),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      bottomNavigationBar: ButtonNav(
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
