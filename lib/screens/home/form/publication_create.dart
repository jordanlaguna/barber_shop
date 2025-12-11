import 'package:flutter/material.dart';

class PublicationCreate extends StatelessWidget {
  const PublicationCreate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crear Publicación",
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
      body: const Center(
        child: Text('Aquí va el formulario para crear una publicación'),
      ),
    );
  }
}
