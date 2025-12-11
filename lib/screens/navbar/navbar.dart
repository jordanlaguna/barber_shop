import 'package:barber_shop/authentication/screen/login.dart';
import 'package:barber_shop/screens/navbar/slider_drawer/help/help.dart';
import 'package:barber_shop/screens/navbar/slider_drawer/notification/notification.dart';
import 'package:barber_shop/screens/navbar/slider_drawer/prices/prices.dart';
import 'package:barber_shop/screens/navbar/slider_drawer/settings/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(user?.uid),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        String displayName =
            userData != null && userData['name'] != null
                ? userData['name']
                : 'Nombre de usuario';
        String email =
            userData != null && userData['email'] != null
                ? userData['email']
                : 'Correo electrónico';
        String? photoUrl =
            userData != null && userData['photoUrl'] != null
                ? userData['photoUrl']
                : null;

        return Theme(
          data: Theme.of(context),
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child:
                        photoUrl == null
                            ? const Icon(Icons.account_circle, size: 50)
                            : null,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan, Colors.cyan, Colors.cyan],
                    ),
                  ),
                ),
                buildListTile(
                  context,
                  Icons.attach_money,
                  'Precios',
                  const PricesPage(),
                ),
                buildListTile(
                  context,
                  Icons.notification_add_rounded,
                  'Notificaciones',
                  const NotificationPage(),
                ),
                buildListTile(context, Icons.help, 'Ayuda', const HelpPage()),
                buildListTile(
                  context,
                  Icons.settings,
                  'Configuración',
                  const SettingsPage(),
                ),
                const Divider(height: 30, color: Color.fromARGB(255, 0, 0, 0)),
                buildListTile(
                  context,
                  Icons.logout_rounded,
                  'Salir',
                  null,
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

ListTile buildListTile(
  BuildContext context,
  IconData icon,
  String title,
  Widget? page, {
  Function()? onTap,
}) {
  return ListTile(
    leading: getIconWithShader(icon),
    title: buildTextStyle(title),
    onTap:
        onTap ??
        () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
  );
}

Text buildTextStyle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

ShaderMask getIconWithShader(IconData icon) {
  return ShaderMask(
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        colors: [Colors.cyan[900]!, Colors.cyan[800]!, Colors.cyan[400]!],
      ).createShader(bounds);
    },
    child: Icon(icon, size: 30, color: Colors.white),
  );
}
