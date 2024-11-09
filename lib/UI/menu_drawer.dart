import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  final VoidCallback onClearCanvas;
  final VoidCallback onClearConnections;
  final VoidCallback onClearAlgorithm; // Nuevo callback
  final VoidCallback onExit;

  const MenuDrawer({
    Key? key,
    required this.onClearCanvas,
    required this.onClearConnections,
    required this.onClearAlgorithm, // Añadir aquí
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal.shade900),
            child: Text(
              'Opciones',
              style: TextStyle(color: Colors.white, fontSize: 24),

            ),
          ),
          ListTile(
            leading: Icon(Icons.clear),
            title: Text('Limpiar Lienzo'),
            onTap: onClearCanvas,
          ),
          ListTile(
            leading: Icon(Icons.remove_circle_outline),
            title: Text('Limpiar Conexiones'),
            onTap: onClearConnections,
          ),
          ListTile(
            leading: Icon(Icons.refresh), // Nuevo ícono
            title: Text('Limpiar Algoritmo'), // Nueva opción
            onTap: onClearAlgorithm, // Asigna el nuevo callback
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Salir'),
            onTap: onExit,
          ),
        ],
      ),
    );
  }
}
